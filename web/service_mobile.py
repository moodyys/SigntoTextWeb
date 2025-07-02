import cv2
import numpy as np
import time
from keras.models import load_model
import arabic_reshaper
from bidi.algorithm import get_display
from PIL import Image, ImageDraw, ImageFont
import mediapipe as mp
from flask import Flask, jsonify, request
import base64

app = Flask(__name__)

# Load Model
modelLSTM = load_model('../Sign Language Model/AsL_detection.h5')

# Initialize MediaPipe
mp_hands = mp.solutions.hands
mp_drawing = mp.solutions.drawing_utils
mp_drawing_styles = mp.solutions.drawing_styles
hands = mp_hands.Hands(static_image_mode=True, min_detection_confidence=0.7, max_num_hands=2)

# Define Label Mapping (Arabic Letters)
label_map = {
    0: 'ع', 1: 'ا', 2: 'ب', 3: 'ض', 4: 'د', 5: 'ف',
    6: 'غ', 7: 'ح', 8: 'ه', 9: 'ج', 10: 'ك', 11: 'خ',
    12: 'ل', 13: 'م', 14: 'ن', 15: 'ق', 16: 'ر', 17: 'ص',
    18: 'س', 19: 'ش', 20: 'ط', 21: 'ت', 22: 'ذ', 23: 'ث',
    24: 'و', 25: 'ي', 26: 'ظ', 27: 'ز'
}

# Global variables
letter_buffer = []
word_buffer = []
last_letter = None
current_word = ""
current_sentence = ""
last_detected_time = time.time()
detection_count = {}

# Accuracy & Delay Settings
CONFIDENCE_THRESHOLD = 0.85
DETECTION_REPEAT = 3
LETTER_DELAY = 0.5

# Load Arabic Font
ARABIC_FONT_PATH = "/System/Library/Fonts/Supplemental/Arial Unicode.ttf"

def render_arabic_text(text):
    reshaped_text = arabic_reshaper.reshape(text)
    bidi_text = get_display(reshaped_text)
    return bidi_text

def extract_keypoints(results):
    data_aux = []
    x_ = []
    y_ = []

    if results.multi_hand_landmarks:
        hand_landmarks = results.multi_hand_landmarks[0]
        for i in range(len(hand_landmarks.landmark)):
            x = hand_landmarks.landmark[i].x
            y = hand_landmarks.landmark[i].y
            x_.append(x)
            y_.append(y)

        for i in range(len(hand_landmarks.landmark)):
            x = hand_landmarks.landmark[i].x
            y = hand_landmarks.landmark[i].y
            data_aux.append(x - min(x_))
            data_aux.append(y - min(y_))
    else:
        for i in range(42):
            data_aux.append(0.0)
    return data_aux

def process_frame_from_mobile(base64_image):
    global last_detected_time, letter_buffer, word_buffer, last_letter, current_word, current_sentence, detection_count
    # Decode base64 image
    img_bytes = base64.b64decode(base64_image)
    np_arr = np.frombuffer(img_bytes, np.uint8)
    frame = cv2.imdecode(np_arr, cv2.IMREAD_COLOR)
    
    # Save the received image for debugging
    cv2.imwrite('debug_received_frame.jpg', frame)
    print(f"Saved debug image with shape: {frame.shape}")
    
    # Check if image is valid
    if frame is None:
        print("ERROR: Failed to decode image")
        return {'letter': '', 'word': '', 'sentence': ''}

    # Perform Hand Detection
    image = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    image.flags.writeable = False
    results = hands.process(image)
    image.flags.writeable = True
    frame = cv2.cvtColor(image, cv2.COLOR_RGB2BGR)

    # Debug hand detection
    print(f"Hand landmarks detected: {results.multi_hand_landmarks is not None}")
    if results.multi_hand_landmarks:
        print(f"Number of hands detected: {len(results.multi_hand_landmarks)}")

    predicted_character = ""
    backspace_detected = False

    if results.multi_hand_landmarks:
        keypoints = extract_keypoints(results)
        keypoints = np.array(keypoints).reshape(1, -1)

        if len(results.multi_hand_landmarks) > 1:
            backspace_detected = True

        prediction = modelLSTM.predict(keypoints)
        predicted_class = np.argmax(prediction)
        confidence = prediction[0, predicted_class]

        print(f"Predicted class: {predicted_class}, Confidence: {confidence}")

        if confidence > CONFIDENCE_THRESHOLD:
            predicted_character = label_map[int(predicted_class)]

            if predicted_character in detection_count:
                detection_count[predicted_character] += 1
            else:
                detection_count[predicted_character] = 1

            if detection_count[predicted_character] >= DETECTION_REPEAT:
                if predicted_character != last_letter and (time.time() - last_detected_time) > LETTER_DELAY:
                    letter_buffer.append(predicted_character)
                    last_detected_time = time.time()
                    last_letter = predicted_character
                    detection_count.clear()

    if backspace_detected:
        if letter_buffer:
            letter_buffer.pop()
        elif word_buffer:
            word_buffer.pop()
        last_detected_time = time.time()

    current_time = time.time()
    if current_time - last_detected_time > 3:
        if letter_buffer:
            current_word = "".join(letter_buffer)
            word_buffer.append(current_word)
            letter_buffer.clear()

    current_sentence = " ".join(word_buffer)

    display_word = render_arabic_text(current_word)
    display_sentence = render_arabic_text(current_sentence)
    display_letter = render_arabic_text(predicted_character)

    result = {
        'letter': display_letter,
        'word': display_word,
        'sentence': display_sentence
    }
    
    print(f"Returning result: {result}")
    return result

@app.route('/process_mobile_frame', methods=['POST'])
def process_mobile_frame():
    data = request.get_json()
    base64_image = data.get('image')
    if not base64_image:
        return jsonify({'status': 'error', 'message': 'No image provided'}), 400
    result = process_frame_from_mobile(base64_image)
    return jsonify(result)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080) 
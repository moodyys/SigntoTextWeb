import cv2
import numpy as np
import time
from keras.models import load_model
import arabic_reshaper
from bidi.algorithm import get_display
from PIL import Image, ImageDraw, ImageFont
import mediapipe as mp
from flask import Flask, jsonify, request, render_template_string
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
detection_running = False
cap = None
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
    """Fixes Arabic text rendering for OpenCV using Pillow."""
    reshaped_text = arabic_reshaper.reshape(text)
    bidi_text = get_display(reshaped_text)
    return bidi_text

def draw_text_with_pil(image, text, position, font_path, font_size=32, color=(255, 255, 255)):
    """Draw Arabic text on an OpenCV image using PIL."""
    pil_image = Image.fromarray(cv2.cvtColor(image, cv2.COLOR_BGR2RGB))
    draw = ImageDraw.Draw(pil_image)
    font = ImageFont.truetype(font_path, font_size)
    draw.text(position, text, font=font, fill=color)
    return cv2.cvtColor(np.array(pil_image), cv2.COLOR_RGB2BGR)

def mediapipe_detection(image, model):
    image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
    image.flags.writeable = False
    results = model.process(image)
    image.flags.writeable = True
    image = cv2.cvtColor(image, cv2.COLOR_RGB2BGR)
    return image, results

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

def draw_styled_landmarks(image, results):
    if results.multi_hand_landmarks:
        for hand_landmarks in results.multi_hand_landmarks:
            mp_drawing.draw_landmarks(
                image,
                hand_landmarks,
                mp_hands.HAND_CONNECTIONS,
                mp_drawing_styles.get_default_hand_landmarks_style(),
                mp_drawing_styles.get_default_hand_connections_style()
            )

def process_frame(frame):
    global last_detected_time, letter_buffer, word_buffer, last_letter, current_word, current_sentence, detection_count

    # Perform Hand Detection
    image, results = mediapipe_detection(frame, hands)

    predicted_character = ""
    backspace_detected = False

    if results.multi_hand_landmarks:
        draw_styled_landmarks(frame, results)

        keypoints = extract_keypoints(results)
        keypoints = np.array(keypoints).reshape(1, -1)

        if len(results.multi_hand_landmarks) > 1:
            backspace_detected = True

        prediction = modelLSTM.predict(keypoints)
        predicted_class = np.argmax(prediction)
        confidence = prediction[0, predicted_class]

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

    #cv2.rectangle(frame, (0, 0), (640, 120), (0, 0, 0), -1)

    ##frame = draw_text_with_pil(frame, f"Sentence: {display_sentence}", (50, 10), ARABIC_FONT_PATH, 32, (255, 255, 255))
    #frame = draw_text_with_pil(frame, f"Word: {display_word}", (50, 50), ARABIC_FONT_PATH, 32, (255, 255, 255))
    #frame = draw_text_with_pil(frame, f"Letter: {display_letter}", (50, 90), ARABIC_FONT_PATH, 32, (0, 255, 0))

    return frame

@app.route('/start_detection', methods=['POST'])
def start_detection():
    global detection_running, cap
    if not detection_running:
        detection_running = True
        letter_buffer.clear()
        word_buffer.clear()
        global last_letter, current_word, current_sentence, last_detected_time, detection_count
        last_letter = None
        current_word = ""
        current_sentence = ""
        last_detected_time = time.time()
        detection_count = {}

        cap = cv2.VideoCapture(0)
        cap.set(cv2.CAP_PROP_FRAME_WIDTH, 640)
        cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)
        cap.set(cv2.CAP_PROP_FPS, 30)

        if not cap.isOpened():
            detection_running = False
            return jsonify({'status': 'error', 'message': 'Could not open camera'})

        return jsonify({'status': 'started'})
    return jsonify({'status': 'already running'})

@app.route('/process_frame', methods=['GET'])
def process_frame_route():
    global detection_running, cap
    if not detection_running or cap is None:
        return jsonify({'status': 'not running'})

    ret, frame = cap.read()
    if not ret:
        return jsonify({'status': 'error', 'message': 'Could not read frame'})

    processed_frame = process_frame(frame)
    _, buffer = cv2.imencode('.jpg', processed_frame)
    frame_base64 = base64.b64encode(buffer).decode('utf-8')

    return jsonify({
        'status': 'success',
        'frame': frame_base64,
        'sentence': current_sentence,
        'word': current_word,
        'letter': last_letter if last_letter else ""
    })

@app.route('/stop_detection', methods=['POST'])
def stop_detection():
    global detection_running, cap
    if detection_running:
        detection_running = False
        if cap is not None:
            cap.release()
        return jsonify({'status': 'stopped'})
    return jsonify({'status': 'not running'})

HTML_TEMPLATE = '''
<!DOCTYPE html>
<html>
<head>
    <title>Sign Language Recognition</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
            background-color: #f0f0f0;
            text-align: center;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
            background-color: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        h1 {
            color: #333;
            margin-bottom: 20px;
        }
        .video-container {
            margin: 20px 0;
        }
        #videoFeed {
            max-width: 100%;
            border-radius: 5px;
        }
        .text-display {
            margin: 20px 0;
            padding: 15px;
            background-color: #f8f9fa;
            border-radius: 5px;
            text-align: left;
        }
        .button {
            padding: 10px 20px;
            margin: 10px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
        }
        .start {
            background-color: #4CAF50;
            color: white;
        }
        .stop {
            background-color: #f44336;
            color: white;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Sign Language Recognition</h1>
        <div class="video-container">
            <img id="videoFeed" src="" alt="Video Feed">
        </div>
        <div class="text-display">
            <h3>Recognized Text:</h3>
            <p id="sentence"></p>
            <p id="word"></p>
            <p id="letter"></p>
        </div>
        <button class="button start" onclick="startDetection()">Start Real-time Detection</button>
        <button class="button stop" onclick="stopDetection()">Stop Detection</button>
    </div>
    <script>
        let isRunning = false;
        let frameInterval;

        function startDetection() {
            if (!isRunning) {
                fetch('/start_detection', {method: 'POST'})
                    .then(r => r.json())
                    .then(data => {
                        if (data.status === 'started') {
                            isRunning = true;
                            startFrameCapture();
                        }
                    });
            }
        }

        function stopDetection() {
            if (isRunning) {
                fetch('/stop_detection', {method: 'POST'})
                    .then(r => r.json())
                    .then(data => {
                        if (data.status === 'stopped') {
                            isRunning = false;
                            clearInterval(frameInterval);
                            document.getElementById('videoFeed').src = '';
                            document.getElementById('sentence').textContent = '';
                            document.getElementById('word').textContent = '';
                            document.getElementById('letter').textContent = '';
                        }
                    });
            }
        }

        function startFrameCapture() {
            frameInterval = setInterval(() => {
                if (isRunning) {
                    fetch('/process_frame')
                        .then(r => r.json())
                        .then(data => {
                            if (data.status === 'success') {
                                document.getElementById('videoFeed').src = 'data:image/jpeg;base64,' + data.frame;
                                document.getElementById('sentence').textContent = 'Sentence: ' + data.sentence;
                                document.getElementById('word').textContent = 'Word: ' + data.word;
                                document.getElementById('letter').textContent = 'Letter: ' + data.letter;
                            }
                        });
                }
            }, 100);
        }
    </script>
</body>
</html>
'''

@app.route('/')
def index():
    return render_template_string(HTML_TEMPLATE)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080) 
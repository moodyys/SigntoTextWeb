#!/usr/bin/env python3
"""
Simple HTTP server for hosting sign language videos
Run this script and your videos will be available at http://localhost:8000
"""

import http.server
import socketserver
import os
import webbrowser
from pathlib import Path

# Change to the video directory
video_dir = Path("lib/assets/video")
os.chdir(video_dir)

PORT = 8000

class MyHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        # Add CORS headers to allow web access
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        super().end_headers()

    def do_OPTIONS(self):
        self.send_response(200)
        self.end_headers()

print(f"🚀 Starting video server on http://localhost:{PORT}")
print(f"📁 Serving videos from: {video_dir.absolute()}")
print("")
print("📋 Your video URLs will be:")
print(f"http://localhost:{PORT}/months.mp4")
print(f"http://localhost:{PORT}/learning.mp4")
print(f"http://localhost:{PORT}/time.mp4")
print(f"http://localhost:{PORT}/ill.mp4")
print(f"http://localhost:{PORT}/weekdays.mp4")
print(f"http://localhost:{PORT}/SOS.mp4")
print(f"http://localhost:{PORT}/health.mp4")
print(f"http://localhost:{PORT}/family.mp4")
print("")
print("🌐 To make this accessible from anywhere, use ngrok:")
print("   pip install ngrok")
print("   ngrok http 8000")
print("")

# Open browser to show the files
webbrowser.open(f"http://localhost:{PORT}")

with socketserver.TCPServer(("", PORT), MyHTTPRequestHandler) as httpd:
    print(f"✅ Server running at http://localhost:{PORT}")
    print("Press Ctrl+C to stop the server")
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\n�� Server stopped") 
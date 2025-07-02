// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui_web;
import 'dart:html' as html;
import 'package:flutter/material.dart';

class FlutterUnityPage extends StatefulWidget {
  const FlutterUnityPage({Key? key}) : super(key: key);

  @override
  State<FlutterUnityPage> createState() => _FlutterUnityPageState();
}

class _FlutterUnityPageState extends State<FlutterUnityPage> {
  final TextEditingController _controller = TextEditingController();
  late html.IFrameElement _iframeElement;

  @override
  void initState() {
    super.initState();
    _iframeElement = html.IFrameElement()
      ..src = 'http://localhost:8081/index.html'
      ..style.border = 'none'
      ..width = '800'
      ..height = '600';
    // No conditional needed since this is web-only
    // ignore: undefined_prefixed_name
    ui_web.platformViewRegistry.registerViewFactory(
      'unity-iframe',
      (int viewId) => _iframeElement,
    );
  }

 void _sendMessageToUnity(String message) {
  print("Flutter is sending: [$message]");
  _iframeElement.contentWindow?.postMessage(message, '*');
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Unity + Input')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Enter word or letter',
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _sendMessageToUnity(_controller.text);
                  },
                  child: const Text('Send to Unity'),
                ),
              ],
            ),
          ),
          Expanded(
            child: HtmlElementView(viewType: 'unity-iframe'),
          ),
        ],
      ),
    );
  }
}
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui_web;
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'assets/theme.dart';
import 'assets/helpbutton.dart';

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
      appBar: AppBar(
        leading: BackButton(color: AppColors.primary),
        title: const Text(
          'نص إلى إشارة',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          HelpButton(
            messages: [
              'اكتب النص في الأسفل واضغط على زر تحويل ليتم ترجمته إلى لغة الإشارة في النافذة أعلاه.',
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: HtmlElementView(viewType: 'unity-iframe'),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 18, color: AppColors.primary),
                    decoration: InputDecoration(
                      labelText: 'ادخل النص',
                      labelStyle: TextStyle(color: AppColors.primary),
                      hintText: 'ادخل النص هنا',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    _sendMessageToUnity(_controller.text);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    'تحويل',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
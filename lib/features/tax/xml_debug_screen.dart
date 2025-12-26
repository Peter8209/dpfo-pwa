import 'package:flutter/material.dart';

class XmlDebugScreen extends StatelessWidget {
  final String xml;

  const XmlDebugScreen({super.key, required this.xml});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('XML Debug Preview')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: SelectableText(
            xml,
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        ),
      ),
    );
  }
}



import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:phsyio_up/main.dart';

class WhatsAppQRCode extends StatefulWidget {
  final Response<dynamic> qrCodeBytes;
  const WhatsAppQRCode({super.key, required this.qrCodeBytes});

  @override
  State<WhatsAppQRCode> createState() => _WhatsAppQRCodeState();
}

class _WhatsAppQRCodeState extends State<WhatsAppQRCode> {
  @override
  Widget build(BuildContext context) { 
    // print(widget.qrCodeBytes.toString());
    return Scaffold(
      body: Row(
         mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            // crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.memory(widget.qrCodeBytes.data),
              const SizedBox(height: 10,),
              TextButton(onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => MainWidget()));
              }, child: Text("Scanned?"))
            ],
          ),
        ],
      ),
    );
  }
}
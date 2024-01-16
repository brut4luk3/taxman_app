import 'package:flutter/material.dart';
import 'screens/upload_vouchers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Taxman App',
      home: UploadVouchersPage(),
    );
  }
}
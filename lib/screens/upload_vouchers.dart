import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UploadVouchersPage extends StatefulWidget {
  @override
  _UploadVouchersPageState createState() => _UploadVouchersPageState();
}

class _UploadVouchersPageState extends State<UploadVouchersPage> {
  List<Map<String, dynamic>> savedVouchers = [];

  @override
  void initState() {
    super.initState();
    _loadSavedVouchers();
  }

  Future<void> _loadSavedVouchers() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getStringList('saved_vouchers') ?? [];
    setState(() {
      savedVouchers = savedData
          .map((e) => json.decode(e) as Map<String, dynamic>)
          .toList();
    });
  }

  Future<void> _pickAndUploadFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      final fileBytes = File(result.files.single.path!).readAsBytesSync();
      final base64Image = base64Encode(fileBytes);
      final response = await http.post(
        Uri.parse(
            'https://taxmanapi-production.up.railway.app/taxman/api/extract_data_from_image'),
        body: json.encode({"image_base64": base64Image}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success']) {
          _saveVoucher(responseData);
        }
      }
    }
  }

  Future<void> _saveVoucher(Map<String, dynamic> voucherData) async {
    final prefs = await SharedPreferences.getInstance();
    savedVouchers.add(voucherData);
    prefs.setStringList(
        'saved_vouchers', savedVouchers.map((e) => json.encode(e)).toList());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload Vouchers')),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue, Colors.white],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: savedVouchers.length,
                itemBuilder: (context, index) {
                  final voucher = savedVouchers[index];
                  return Card(
                    child: ListTile(
                      title: Text('Data da transação: ${voucher['date']}'),
                      onTap: () => showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Detalhes do Comprovante'),
                            content: SingleChildScrollView(
                              child: ListBody(
                                children: <Widget>[
                                  Text('Data da Transação: ${voucher['date']}'),
                                  Text('Valor: R\$ ${voucher['value']}'),
                                  Text('Destinatário: ${voucher['destiny']}'),
                                  Text('Remetente: ${voucher['origin']}'),
                                ],
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: Text('Fechar'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                onPressed: _pickAndUploadFile,
                child: Text('Carregar comprovante'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

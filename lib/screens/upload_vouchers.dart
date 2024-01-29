import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animate_do/animate_do.dart';

class UploadVouchersPage extends StatefulWidget {
  @override
  _UploadVouchersPageState createState() => _UploadVouchersPageState();
}

class _UploadVouchersPageState extends State<UploadVouchersPage> {
  List<Map<String, dynamic>> savedVouchers = [];
  int? _expandedIndex;

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
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileBytes = await file.readAsBytes();
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
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _saveVoucher(Map<String, dynamic> voucherData) async {
    final prefs = await SharedPreferences.getInstance();
    savedVouchers.add(voucherData);
    prefs.setStringList(
        'saved_vouchers', savedVouchers.map((e) => json.encode(e)).toList());
    setState(() {});
  }

  Widget _buildVoucherListItem(int index) {
    final voucher = savedVouchers[index];
    bool isExpanded = _expandedIndex == index;

    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(isExpanded ? Icons.arrow_drop_down : Icons.arrow_right),
            title: Text('Data da transação: ${voucher['date']}'),
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedIndex = null;
                } else {
                  _expandedIndex = index;
                }
              });
            },
          ),
          if (isExpanded) ...[
            Divider(
              color: Colors.grey,
              thickness: 1,
              indent: 20,
              endIndent: 20,
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  Text('Valor: R\$ ${voucher['value']}'),
                  Text('Destinatário: ${voucher['destiny']}'),
                  Text('Remetente: ${voucher['origin']}'),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVoucherList() {
    double screenHeight = MediaQuery.of(context).size.height;
    double appBarHeight = kToolbarHeight;
    double topPadding = 50;
    double bottomPadding = 150;

    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: FadeInDown(
        duration: Duration(milliseconds: 1600),
        child: Container(
          height: screenHeight - appBarHeight - topPadding - bottomPadding,
          child: ListView.builder(
            physics: ScrollPhysics(),
            itemCount: savedVouchers.length,
            itemBuilder: (context, index) => _buildVoucherListItem(index),
          ),
        ),
      ),
    );
  }

  Widget _buildUploadButton() {
    return FadeInUp(
      duration: Duration(milliseconds: 1900),
      child: Container(
        width: MediaQuery.of(context).size.width - 60,
        padding: EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.symmetric(vertical: 15),
          ),
          onPressed: _pickAndUploadFile,
          child: Text('Carregar comprovante', style: TextStyle(fontSize: 20)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FadeInDown(
            duration: Duration(milliseconds: 1400),
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background2.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.only(top: 50, bottom: 80),
                    child: _buildVoucherList(),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: FadeInUp(
                  duration: Duration(milliseconds: 1900),
                  child: Container(
                    width: MediaQuery.of(context).size.width - 60,
                    padding: EdgeInsets.all(16.0),
                    child: _buildUploadButton(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
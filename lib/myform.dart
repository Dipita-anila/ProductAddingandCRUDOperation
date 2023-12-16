// myform.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/database_helper.dart';

class MyForm extends StatefulWidget {
  final Function(String, String) onSave;

  MyForm({required this.onSave});

  @override
  _MyFormState createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  List<Map<String, dynamic>> _allData = [];

  bool _isLoading = true;

  //ALL Data From database
  void _refreshData() async {
    final data = await DatabaseHelper.getAllData();
    setState(() {
      _allData = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  //Future<void> _addData() async {
  // await DatabaseHelper.createData(
  //     productNameController.text, productPriceController.text);
  // _refreshData();
  //}

  Future<void> _updateData(int id) async {
    await DatabaseHelper.updateData(
        id, productNameController.text, productPriceController.text);
  }

  void _deleteData(int id) async {
    await DatabaseHelper.deleteData(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      backgroundColor: Colors.redAccent,
      content: Text("Data Deleted"),
    ));
    _refreshData();
  }

  final TextEditingController productNameController = TextEditingController();
  final TextEditingController productPriceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFECEAF4),
      appBar: AppBar(
        title: const Text('Product Information',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 16, 99, 74),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: productNameController,
                decoration: InputDecoration(
                  labelText: 'Product Name',
                  focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 9, 46, 32)),
                  ),
                ),
                cursorColor: Color.fromARGB(255, 9, 46, 32),
                style: TextStyle(color: Colors.black),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: productPriceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Product Price',
                  focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 9, 46, 32)),
                  ),
                ),
                cursorColor: Color.fromARGB(255, 9, 46, 32),
                style: TextStyle(color: Colors.black),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  // await _addData();

                  String productName = productNameController.text.trim();
                  String productPrice = productPriceController.text.trim();

                  if (productName.isNotEmpty && productPrice.isNotEmpty) {
                    widget.onSave(productName, productPrice);

                    productNameController.clear();
                    productPriceController.clear();
                  }
                },
                style: ElevatedButton.styleFrom(
                  primary: Color.fromARGB(255, 16, 99, 74),
                ),
                child: Text(
                  'Save',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_application_1/productlist.dart';
import 'package:flutter_application_1/myform.dart';
import 'package:flutter_application_1/database_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //List<Productlist> names = List.empty(growable: true);
  //List<Productlist> names = [];
  List<Map<String, dynamic>> names = [];

  @override
  void initState() {
    super.initState();
    _loadDataFromDatabase();
  }

  // Load data from the database
  void _loadDataFromDatabase() async {
    final data = await DatabaseHelper.getAllData();
    setState(() {
      names = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title:
            const Text('Product List', style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 16, 99, 74),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(height: 15),
            if (names.isEmpty)
              const Text(
                'No Product Available..',
                style: TextStyle(fontSize: 22),
              )
            else
              Flexible(
                child: ListView.builder(
                  itemCount: names.length,
                  itemBuilder: (context, index) => getRow(index),
                ),
              )
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Color.fromARGB(255, 16, 99, 74),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyForm(
                      onSave: (productName, productPrice) async {
                        await _addDataToDatabase(productName, productPrice);
                        // Callback to save the product
                        //setState(() {
                        //names.add(Productlist(
                        // name: productName,
                        // price: productPrice,
                        //));
                      },
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.white,
                onPrimary: Color.fromARGB(255, 16, 99, 74),
              ),
              child: const Text(
                'Add New Product',
                style: TextStyle(color: Color.fromARGB(255, 16, 99, 74)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Add data to the database and refresh the UI
  Future<void> _addDataToDatabase(
      String productName, String productPrice) async {
    await DatabaseHelper.createData(productName, productPrice);
    _loadDataFromDatabase();
  }

  Future<void> _updateDataInDatabase(BuildContext context, int id,
      String productName, String productPrice) async {
    try {
      await DatabaseHelper.updateData(id, productName, productPrice);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Color.fromARGB(255, 16, 99, 74),
        content: Text(
          "Data Updated",
          style: TextStyle(color: Colors.white),
        ),
      ));

      // Refresh the UI after the update
      _loadDataFromDatabase();
    } catch (e) {
      print("Error updating data: $e");
      // Handle error, show a snackbar, etc.
    }
  }

  Widget getRow(int index) {
    if (names[index]['isVisible'] == false) {
      return Visibility(
        key: UniqueKey(), // Add this line to fix the error
        visible: false,
        child: Container(),
      );
    }

    return Card(
      child: Column(
        children: [
          Text('Product Name: ${names[index]['name']}'),
          Text('Product Price: ${names[index]['price']}'),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  // Add your update logic here
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyForm(
                        onSave: (productName, productPrice) async {
                          await _updateDataInDatabase(context,
                              names[index]['id'], productName, productPrice);
                        },
                        //initialProductName: names[index]['name'],
                        //initialProductPrice: names[index]['price'],
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: Color.fromARGB(255, 144, 191, 230),
                ),
                child: const Text('Update',
                    style: TextStyle(color: Color.fromARGB(255, 9, 46, 32))),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () async {
                  await _deleteDataFromDatabase(names[index]['id']);
                },
                style: ElevatedButton.styleFrom(
                  primary: Color.fromARGB(255, 231, 105, 105),
                ),
                child: const Text('Delete',
                    style: TextStyle(color: Color.fromARGB(255, 9, 46, 32))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _deleteDataFromDatabase(int id) async {
    try {
      await DatabaseHelper.deleteData(id);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Color.fromARGB(255, 231, 105, 105),
        content: Text("Data Deleted"),
      ));
    } catch (e) {
      print("Error deleting data: $e");
    }
    _loadDataFromDatabase();
  }
}

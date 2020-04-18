import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo list',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController taskTitleInputController;
  TextEditingController taskAmountInputController;

  String _currentType;
  List<DropdownMenuItem<String>> _dropdownMenuItems;

  @override
  initState() {
    super.initState();

    taskTitleInputController = new TextEditingController();
    taskAmountInputController = new TextEditingController();
    _dropdownMenuItems = <String>['литры', 'килограммы', 'упаковки', 'бутылки']
        .map((String value) {
      return new DropdownMenuItem<String>(
        value: value,
        child: new Text(value),
      );
    }).toList();
    _currentType = _dropdownMenuItems[0].value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text('Todo list')),
      body: _buildBody(context),
      floatingActionButton: FloatingActionButton(
        onPressed: _showDialog,
        tooltip: 'Add',
        child: Icon(Icons.add),
      ),
    );
  }

  _showDialog() async {
    await showDialog<String>(
      context: context,
      child: AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        content: Column(
          children: <Widget>[
            Text("Please fill all fields to create a new item"),
            Column(children: <Widget>[
              TextField(
                autofocus: true,
                decoration: InputDecoration(labelText: 'Item Title*'),
                controller: taskTitleInputController,
              ),
            ]),
            Row(
              children: <Widget>[
                Flexible(
                    child: TextField(
                  decoration: new InputDecoration(labelText: "Item amount"),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  controller: taskAmountInputController,
                )),
                _buildDropdownButton(context)
              ],
            )
          ],
        ),
        actions: <Widget>[
          FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                taskTitleInputController.clear();
                taskAmountInputController.clear();
                _currentType = _dropdownMenuItems[0].value;
                Navigator.pop(context);
              }),
          FlatButton(
              child: Text('Add'),
              onPressed: () {
                if (taskTitleInputController.text.isNotEmpty) {
                  Firestore.instance
                      .collection('items')
                      .add({
                        "item": taskTitleInputController.text,
                        "amount": taskAmountInputController.text,
                        "type": _currentType
                      })
                      .then((result) => {
                            Navigator.pop(context),
                            taskTitleInputController.clear(),
                            taskAmountInputController.clear(),
                            _currentType = _dropdownMenuItems[0].value
                          })
                      .catchError((err) => print(err));
                }
              })
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('items').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildDropdownButton(BuildContext context) {
    return DropdownButton<String>(
        items: _dropdownMenuItems,
        value: _currentType,
        onChanged: (val) {
          setState(() {
            _currentType = val;
          });
        });
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final record = Record.fromSnapshot(data);

    return Padding(
      key: ValueKey(record.item),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ListTile(
          title: Text(record.item),
          trailing: Text(record.amount + " " + record.type),
          onTap: () => record.reference.delete(),
        ),
      ),
    );
  }
}

class Record {
  final String item;
  final String amount;
  final String type;
  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['item'] != null),
        assert(map['amount'] != null),
        assert(map['type'] != null),
        item = map['item'],
        amount = map['amount'],
        type = map['type'];

  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Record<$item:$amount $type>";
}

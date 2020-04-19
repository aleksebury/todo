import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'entity/Record.dart';

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

  List<String> _dropdownMenuItems = <String>['', 'л', 'кг', 'уп', 'бут'];
  String _currentType;

  @override
  initState() {
    super.initState();

    taskTitleInputController = new TextEditingController();
    taskAmountInputController = new TextEditingController();
    _currentType = _dropdownMenuItems[0];
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
      builder: (BuildContext context) => AlertDialog(
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
                Flexible(
                  child: FormField(
                    builder: (FormFieldState state) {
                      return InputDecorator(
                        decoration: InputDecoration(
                          icon: const Icon(Icons.list),
                          labelText: 'Type',
                        ),
                        isEmpty: _currentType == '',
                        child: new DropdownButtonHideUnderline(
                            child: _buildDropdownButton(state)),
                      );
                    },
                  ),
                )
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
                _currentType = _dropdownMenuItems[0];
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
                            _currentType = _dropdownMenuItems[0]
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

  Widget _buildDropdownButton(FormFieldState state) {
    return DropdownButton(
      value: _currentType,
      isDense: true,
      onChanged: (String newValue) {
        setState(() {
          _currentType = newValue;
          state.didChange(newValue);
        });
      },
      items: _dropdownMenuItems.map((String value) {
        return new DropdownMenuItem(
          value: value,
          child: new Text(value),
        );
      }).toList(),
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    if (snapshot.isEmpty) {
      return Align(
        alignment: Alignment.center,
        child: Text("Nothing to buy. Relax!",
            style: TextStyle(
              fontSize: 16,
            )),
      );
    } else {
      return ListView(
        padding: const EdgeInsets.only(top: 20.0),
        children:
            snapshot.map((data) => _buildListItem(context, data)).toList(),
      );
    }
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'entity/Record.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Покупочки',
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

  List<String> _dropdownMenuItems = <String>[
    '',
    'мл',
    'л',
    'г',
    'кг',
    'уп',
    'бут',
    'шт'
  ];
  String _currentType;
  var isLargeScreen = false;

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
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(30.0),
          child: AppBar(
              centerTitle: true,
              backgroundColor: Colors.green,
              title: Text('Покупочки'))),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.jpeg"),
            fit: BoxFit.fill,
          ),
        ),
        child: _buildBody(context),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showDialog,
        tooltip: 'Добавить',
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
            Text("Заполните необходимые поля для добавления продукта"),
            Column(children: <Widget>[
              TextField(
                autofocus: true,
                decoration: InputDecoration(labelText: 'Название*'),
                controller: taskTitleInputController,
              ),
            ]),
            Row(
              children: <Widget>[
                Flexible(
                    child: TextField(
                  decoration: new InputDecoration(labelText: "количество"),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  controller: taskAmountInputController,
                )),
                Flexible(
                  child: FormField(
                    builder: (FormFieldState state) {
                      return InputDecorator(
                        decoration: InputDecoration(
                          icon: const Icon(Icons.list),
                          labelText: 'тип',
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
              child: Text('Отмена'),
              onPressed: () {
                taskTitleInputController.clear();
                taskAmountInputController.clear();
                _currentType = _dropdownMenuItems[0];
                Navigator.pop(context);
              }),
          FlatButton(
              child: Text('Добавить'),
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
    ).then((val) {
      taskTitleInputController.clear();
      taskAmountInputController.clear();
      _currentType = _dropdownMenuItems[0];
    });
  }

  _showEditDialog(Record record) async {
    taskTitleInputController.value = TextEditingValue(text: record.item);
    taskAmountInputController.value = TextEditingValue(text: record.amount);
    _currentType = record.type;

    await showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        content: Column(
          children: <Widget>[
            Text("Отредактируйте необходимые поля"),
            Column(children: <Widget>[
              TextField(
                autofocus: true,
                decoration: InputDecoration(labelText: 'Название*'),
                controller: taskTitleInputController,
              ),
            ]),
            Row(
              children: <Widget>[
                Flexible(
                    child: TextField(
                  decoration: new InputDecoration(labelText: "количество"),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  controller: taskAmountInputController,
                )),
                Flexible(
                  child: FormField(
                    builder: (FormFieldState state) {
                      return InputDecorator(
                        decoration: InputDecoration(
                          icon: const Icon(Icons.list),
                          labelText: 'тип',
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
              child: Text('Отмена'),
              onPressed: () {
                taskTitleInputController.clear();
                taskAmountInputController.clear();
                _currentType = _dropdownMenuItems[0];
                Navigator.pop(context);
              }),
          FlatButton(
              child: Text('Править'),
              onPressed: () {
                if (taskTitleInputController.text.isNotEmpty) {
                  Firestore.instance
                      .collection('items')
                      .document(record.reference.documentID)
                      .updateData({
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
    ).then((val) {
      taskTitleInputController.clear();
      taskAmountInputController.clear();
      _currentType = _dropdownMenuItems[0];
    });
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
        child: Text("Корзина пуста. Наслаждайтесь отдыхом!",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      );
    } else {
      return ListView(
        padding:
            EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.07),
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
            child: Dismissible(
          key: Key(record.reference.documentID),
          background: _slideLeftBackground(),
          secondaryBackground: _slideRightBackground(),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              record.reference.delete();
              Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text(record.item + " куплено"),
                  backgroundColor: Colors.green));
              return true;
            } else if (direction == DismissDirection.endToStart) {
              _showEditDialog(record);
            }
            return false;
          },
          child: ListTile(
            title: Text(record.item,
                style: TextStyle(
                  fontSize: 24,
                )),
            trailing: Text(record.amount + " " + record.type,
                style: TextStyle(
                  fontSize: 24,
                )),
          ),
        )));
  }

  Widget _slideLeftBackground() {
    return Container(
      color: Colors.green,
      child: Align(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Icon(
              Icons.done_outline,
              color: Colors.white,
            ),
            Text(
              " Куплено",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.right,
            ),
            SizedBox(
              width: 20,
            ),
          ],
        ),
        alignment: Alignment.centerRight,
      ),
    );
  }

  Widget _slideRightBackground() {
    return Container(
      color: Colors.orange,
      child: Align(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            SizedBox(
              width: 20,
            ),
            Icon(
              Icons.edit,
              color: Colors.white,
            ),
            Text(
              " Править",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.left,
            ),
          ],
        ),
        alignment: Alignment.centerLeft,
      ),
    );
  }
}

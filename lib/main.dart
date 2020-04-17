
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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

  TextEditingController taskTitleInputController;
// TextEditingController taskDescripInputController;

@override
initState() {
  taskTitleInputController = new TextEditingController();
  // taskDescripInputController = new TextEditingController();
  super.initState();
}

  _showDialog() async {
  await showDialog<String>(
    context: context,
    child: AlertDialog(
      contentPadding: const EdgeInsets.all(16.0),
      content: Column(
        children: <Widget>[
          Text("Please fill all fields to create a new item"),
          Expanded(
            child: TextField(
              autofocus: true,
              decoration: InputDecoration(labelText: 'Item Title*'),
              controller: taskTitleInputController,
            ),
          ),
        ],
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('Cancel'),
          onPressed: () {
            taskTitleInputController.clear();
            // taskDescripInputController.clear();
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
                  // "description": taskDescripInputController.text
              })
              .then((result) => {
                Navigator.pop(context),
                taskTitleInputController.clear(),
                // taskDescripInputController.clear(),
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
          onTap: () => record.reference.delete(),
        ),
      ),
    );
  }
}

class Record {
  final String item;
  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['item'] != null),
        item = map['item'];

  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Record<$item>";
}


import 'package:cloud_firestore/cloud_firestore.dart';

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

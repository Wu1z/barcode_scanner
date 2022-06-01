import 'package:barcode_reader/repositories/interfaces/irepository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Repository implements IRepository {

  final FirebaseFirestore firestore;

  Repository(this.firestore);

  @override
  Future<void> delete(DocumentSnapshot doc) async {
    await firestore.collection("barcodes")
      .doc(doc.id)
      .delete();
  }

  @override
  Future<void> insert(String barcode) async {
    await firestore.collection("barcodes").add({
      'barcode': barcode,
    });
  }
}
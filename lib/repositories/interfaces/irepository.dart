import 'package:cloud_firestore/cloud_firestore.dart';

abstract class IRepository {
  Future<void> insert(String barcode);
  Future<void> delete(DocumentSnapshot doc);
}
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/billing_record_model.dart';
import 'authentication_service.dart';

class DatabaseHelper {
  // Append the username to the collection name
  final collectionName = '${BillingRecordModel.CollectionName}_${AuthenticationService.userName}';

  CollectionReference get collection =>
      FirebaseFirestore.instance.collection(collectionName);

  // insert a new billing record
  Future<DocumentReference> addBillingRecord(BillingRecordModel billingRecord) async {
    return await collection.add(billingRecord.toJson());
  }
  // update an existing billing record
  Future<void> updateBillingRecord(String id, BillingRecordModel billingRecord) async {
    return await collection.doc(id).update(billingRecord.toJson());
  }
  // delete a billing record
  Future<void> deleteBillingRecord(String id) async {
    return await collection.doc(id).delete();
  }
  // load all billing records
  Stream<QuerySnapshot> getStreamBillingRecords() {
    return collection.snapshots();
  }  
}

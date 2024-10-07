import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String uid;
  final String orderId;
  final String status;
  final double price;

  DatabaseService({
    required this.uid,
    required this.orderId,
    required this.status,
    required this.price,
  });

  final CollectionReference orderCollection =
      FirebaseFirestore.instance.collection('orders');

  // Method to add order data to Firestore
  Future<void> addOrder() async {
    await orderCollection.add({
      'uid': uid,
      'orderId': orderId,
      'status': status,
      'price': price,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Method to update order status
  Future<void> updateOrderStatus(String docId, String newStatus) async {
    return await orderCollection.doc(docId).update({
      'status': newStatus,
    });
  }
}

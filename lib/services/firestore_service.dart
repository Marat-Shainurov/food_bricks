import 'package:cloud_firestore/cloud_firestore.dart';

Stream<QuerySnapshot> getActiveOrders() {
  return FirebaseFirestore.instance
      .collection('orders')
      .where('status', isNotEqualTo: 'Done')
      .orderBy('timestamp', descending: true)
      .orderBy('status', descending: true)
      .orderBy('__name__', descending: true)
      .snapshots();
}

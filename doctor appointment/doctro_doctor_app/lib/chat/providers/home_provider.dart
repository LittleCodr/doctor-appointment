import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctro/chat/constants/firestore_constants.dart';

class HomeProvider {
  final FirebaseFirestore firebaseFirestore;

  HomeProvider({required this.firebaseFirestore});

  Future<void> updateDataFirestore(String collectionPath, String path, Map<String, String> dataNeedUpdate) {
    return firebaseFirestore.collection(collectionPath).doc(path).update(dataNeedUpdate);
  }

  Stream<QuerySnapshot> getStreamFireStore(String pathCollection, int limit) {
    return firebaseFirestore.collection(pathCollection).limit(limit).where(FirestoreConstants.userType, isEqualTo: "patient").snapshots();
  }

  Stream<QuerySnapshot> getStreamFireStoreSpecificUser(String pathCollection, int limit, String? textSearch) {
    return firebaseFirestore.collection(pathCollection).limit(limit).where(FirestoreConstants.userId, isEqualTo: textSearch).snapshots();
  }
}

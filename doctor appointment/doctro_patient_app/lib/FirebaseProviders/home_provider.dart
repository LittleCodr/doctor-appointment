import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctro_patient/const/prefConstatnt.dart';

class HomeProvider {
  final FirebaseFirestore firebaseFirestore;

  HomeProvider({required this.firebaseFirestore});

  Future<void> updateDataFirestore(String collectionPath, String path, Map<String, String> dataNeedUpdate) {
    return firebaseFirestore.collection(collectionPath).doc(path).update(dataNeedUpdate);
  }

  Stream<QuerySnapshot> getStreamFireStore(String pathCollection, int limit, String? textSearch) {
    return firebaseFirestore.collection(pathCollection).limit(limit).where(FirestoreConstants.doctorId, isEqualTo: textSearch).snapshots();
  }
}

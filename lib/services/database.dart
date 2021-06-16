import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Database {
  final FirebaseFirestore firestore;

  Database({this.firestore});

  Future<String> addBaby(String uid, String babyName, DateTime _birthDay, bool isGirl, double babyHeight, double babyWeight, int currentUnit) async {
    try {
      await firestore.collection(uid).doc(babyName).set({
        'birthday': _birthDay,
        'name': babyName,
        'gender': isGirl,
        'height': currentUnit == 0 ? babyHeight : (babyHeight * 2.54),
        'weight': currentUnit == 0 ? babyWeight : (babyWeight / 2.205),
        'date': DateTime.now(),
      });
      await firestore
          .collection(uid)
          .doc(babyName)
          .collection('entries')
          .doc(DateTime.fromMillisecondsSinceEpoch(
          _birthDay.millisecondsSinceEpoch)
          .toString())
          .set({
        'date': _birthDay,
        'height': currentUnit == 0 ? babyHeight : (babyHeight * 2.54),
        'weight': currentUnit == 0 ? babyWeight : (babyWeight / 2.205),
      });
      return 'Success';
    } on FirebaseException catch(e) {
      return e.message;
    } catch(e) {
      rethrow;
    }
  }

  Future<String> deleteData({User user}) async {
    try{
      firestore
          .collection(user.uid)
          .get()
          .then((snapshot) {
        for (DocumentSnapshot ds in snapshot.docs) {
          ds.reference
              .collection('entries')
              .get()
              .then((snapshot) {
            for (DocumentSnapshot ds in snapshot.docs) {
              ds.reference.delete();
            }
          });
        }
      });
      firestore
          .collection(user.uid)
          .get()
          .then((snapshot) {
        for (DocumentSnapshot ds in snapshot.docs) {
          ds.reference.delete();
        }
      });
      return 'Success';
    } on FirebaseAuthException catch(e) {
      return e.message;
    } catch(e) {
      rethrow;
    }
  }

  // used in add_entry page to add a new weight or height entry
  Future<String> newEntry({User user, String name, DateTime date, int currentUnit, double height, double weight}) async {
    try{
      firestore
          .collection(user.uid)
          .doc(name)
          .collection('entries')
          .doc(date.toString())
          .set({
        'date': date,
        'height': currentUnit == 0 ? height : height * 2.54,
        'weight': currentUnit == 0 ? weight : weight / 2.205,
      });
      return 'Success';
    }
    // on FirebaseAuthException catch(e) {
    //   return e.message;
    // }
    catch(e) {
      rethrow;
    }
  }

  Stream<QuerySnapshot> babyStream({User user, String name}) {
    try{
      Stream stream = firestore
          .collection(user.uid)
          .doc(name)
          .collection('entries')
          .snapshots();
      return stream;
    }  catch(e) {
      rethrow;
    }
  }

  DocumentReference babyData({User user, String name}) {
    try {
      DocumentReference documentReference = firestore.collection(user.uid).doc(name);
      return documentReference;
    } catch(e) {
      rethrow;
    }
}

  Future<String> deleteEntry({User user, String name, Timestamp date}) async {
    try{
      firestore
          .collection(user.uid)
          .doc(name)
          .collection('entries')
          .doc(date.toString())
          .delete();
      return 'Success';
    } on FirebaseAuthException catch(e) {
      return e.message;
    } catch(e) {
      rethrow;
    }
  }

}
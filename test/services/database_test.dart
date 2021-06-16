import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/mockito.dart';
import 'package:BabyGrowth/services/database.dart';
import 'package:flutter_test/flutter_test.dart';

class MockFirestore extends Mock implements FirebaseFirestore{}
class MockCollectionReference extends Mock implements CollectionReference{
}
class MockDocumentReference extends Mock implements DocumentReference{
  @override
  Future<void> set(Map<String, dynamic> data, [SetOptions options]) {
    // TODO: implement set
    throw UnimplementedError();
  }
}
class MockDocumentSnapshot extends Mock implements DocumentSnapshot{}


void main() {
    MockFirestore mockFirestore = MockFirestore();
    MockCollectionReference mockCollectionReference;
    MockDocumentReference mockDocumentReference;
    MockDocumentSnapshot mockDocumentSnapshot;
    final Database database = Database(firestore: mockFirestore);

    setUp(() {
      mockCollectionReference = MockCollectionReference();
      mockDocumentReference = MockDocumentReference();
      mockDocumentSnapshot = MockDocumentSnapshot();
    });
    tearDown(() {});

    test('user adds baby by inputting data', () async {
      Map<String, dynamic> data;
      when(mockFirestore.collection('uid')).thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc('babyName')).thenReturn(mockDocumentReference);
      when(mockDocumentReference.collection('entries')).thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc("2018-12-29 00:00:00.000")).thenReturn(mockDocumentReference);
      when(mockDocumentReference.set(data)).thenAnswer((realInvocation) => null);
      
      final result = await database.addBaby('uid', 'babyName', DateTime(2018, 12, 18), true, 50, 3.5, 1);
      expect(result, 'Success');
    });
}
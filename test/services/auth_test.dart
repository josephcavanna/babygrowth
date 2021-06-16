import 'package:BabyGrowth/services/auth.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

class MockUser extends Mock implements User{}
class MockCredential extends Mock implements UserCredential{}
class MockAuth extends Mock implements FirebaseAuth{
  @override
  Stream<User> authStateChanges() {
    return Stream.fromIterable([_mockUser]);
  }
}

final MockUser _mockUser = MockUser();

void main() {
  group('firebase auth tests', () {
    final MockAuth _mockFirebaseAuth = MockAuth();
    final Auth auth = Auth(auth: _mockFirebaseAuth);
    setUp(() {});
    tearDown(() {});

    test('auth changes are emitted', () async {
      expectLater(auth.user, emitsInOrder([_mockUser]));
    });

    test('user inputs correct email and password for login', () async {
      when(auth.signIn(email: 'email', password: 'password')).thenAnswer((realInvocation) => null);

      final result = await auth.signIn(email: 'email', password: 'password');
      expect(result, 'Success');
    });

    test('user inputs incorrect email and password', () async {
      when(auth.signIn(email: 'email', password: 'passwrod')).thenAnswer((realInvocation) => throw FirebaseAuthException(message: 'Wrong password'));

      final result = await auth.signIn(email: 'email', password: 'passwrod');
      expect(result, 'Wrong password');
    });
    
    test('creates new user correctly', () async {
      when(auth.createAccount(email: 'email', password: 'password')).thenAnswer((realInvocation) => null);

      final result = await auth.createAccount(email: 'email', password: 'password');
      expect(result, 'Success');
    });
    
    test('creates new user error', () async {
      when(auth.createAccount(email: 'email', password: '')).thenAnswer((realInvocation) => throw FirebaseAuthException(message: 'Email or Password missing'));

      final result = await auth.createAccount(email: 'email', password: '');
      expect(result, 'Email or Password missing');
    });

    test('user resets password correctly', () async {
      when(auth.resetPassword(email: 'email')).thenAnswer((realInvocation) => null);

      final result = await auth.resetPassword(email: 'email');
      expect(result, 'Success');
    });

    test('user resets password error', () async {
      when(auth.resetPassword(email: 'eamil')).thenAnswer((realInvocation) => throw FirebaseAuthException(message: 'This email does not exist'));

      final result = await auth.resetPassword(email: 'eamil');
      expect(result, 'This email does not exist');
    });

    test('user signs out', () async {
      when(auth.signOut()).thenAnswer((realInvocation) => null);

      final result = await auth.signOut();
      expect(result, 'Success');
    });

    test('user signs out error', () async {
      when(auth.signOut()).thenAnswer((realInvocation) => throw FirebaseAuthException(message: 'Error'));

      final result = await auth.signOut();
      expect(result, 'Error');
    });

    test('app checks whether user is signed in', () async {
      when(auth.currentUser()).thenAnswer((realInvocation) => null);

      final result = await auth.currentUser();
      expect(result, 'Success');
    });

    test('current user check exception', () async {
      when(auth.currentUser()).thenAnswer((realInvocation) => throw FirebaseAuthException(message: 'Error'));

      final result = await auth.currentUser();
      expect(result, 'Error');
    });

    test('re-authenticate user before deleting account', () async {
      when(auth.reauthenticate(user: _mockUser, email: 'email', password: 'password')).thenAnswer((realInvocation) => null);

      final result = await auth.reauthenticate(user: _mockUser, email: 'email', password: 'password');
      expect(result, 'Success');
    });

    test('user deletes account', () async {
      when(auth.delete(_mockUser)).thenAnswer((realInvocation) => null);

      final result = await auth.delete(_mockUser);
      expect(result, 'Success');
    });
    
    test('user account deletion exception', () async {
      when(auth.delete(_mockUser)).thenAnswer((realInvocation) => throw FirebaseAuthException(message: 'Error'));

      final result = await auth.delete(_mockUser);
      expect(result, 'Error');
    });
  });
}
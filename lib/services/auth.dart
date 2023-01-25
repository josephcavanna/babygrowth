import 'package:firebase_auth/firebase_auth.dart';

// this class contains all the Firebase Auth services used in the app
class Auth {
  final FirebaseAuth auth;

  Auth({required this.auth});

  Stream<User?> get user => auth.authStateChanges();

  // user can create and account with email and password and is able to proceed to the main page
  Future<String> createAccount({required String email, required String password}) async {
    try {
      await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
      ); return 'Success';
    } on FirebaseAuthException catch(e) {
      var futureString = Future.value(e.message);
      return futureString;
    } catch(e) {
      rethrow;
    }
  }

  // user can sign in with their email and password
  Future<String> signIn({required String email, required String password}) async {
    try {
      await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return 'Success';
    } on FirebaseAuthException catch (e) {
      var futureString = Future.value(e.message);
      return futureString;
    } catch(e) {
      rethrow;
    }
  }

  // user is able to reset password by receiving email with link
  Future<String> resetPassword({required String email}) async {
    try {
      await auth.sendPasswordResetEmail(
          email: email,
      );
      return 'Success';
    } on FirebaseAuthException catch(e) {
      var futureString = Future.value(e.message);
      return futureString;
    } catch(e){
      rethrow;
    }
  }

  // user signs out of the app and is moved to the welcome screen
  Future<String> signOut() async {
    try {
      await auth.signOut();
      return 'Success';
    } on FirebaseAuthException catch(e) {
      var futureString = Future.value(e.message);
      return futureString;
    } catch(e) {
      rethrow;
    }
  }

  // detect whether there is a user currently signed in
  Future<String> currentUser() async {
    try {
      await auth.currentUser;
      return 'Success';
    } on FirebaseAuthException catch(e) {
      var futureString = Future.value(e.message);
      return futureString;
    } catch(e) {
      rethrow;
    }
  }

  // user re-authentication in order to delete account from Firebase.
  Future<String> reauthenticate({required String email, required String password, required User user}) async {
    try{
      AuthCredential credential =
      EmailAuthProvider.credential(
          email: email, password: password);
      await user
          .reauthenticateWithCredential(credential);
      return 'Success';
    } on FirebaseAuthException catch(e) {
      var futureString = Future.value(e.message);
      return futureString;
    } catch(e) {
      rethrow;
    }
  }

  // user calls for deletion of their account
  Future<String> delete(User user) async {
    try{
      await user.delete();
      return 'Success';
    } on FirebaseAuthException catch(e) {
      var futureString = Future.value(e.message);
      return futureString;
    } catch(e) {
      rethrow;
    }
  }
}
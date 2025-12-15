import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../routes/app_pages.dart';

class ProfileController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Rx<User?> user = Rx<User?>(null);
  RxMap<String, dynamic> userData = RxMap<String, dynamic>();

  @override
  void onInit() {
    super.onInit();
    user.bindStream(_auth.authStateChanges());
    user.listen((User? currentUser) {
      if (currentUser != null) {
        _loadUserData(currentUser);
      } else {
        userData.clear();
      }
    });
  }

  Future<void> _loadUserData(User currentUser) async {
    try {
      final doc =
      await _firestore.collection('users').doc(currentUser.uid).get();
      if (doc.exists) {
        userData.value = doc.data()!;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load user data: $e');
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize();
      await googleSignIn.authorizationClient.authorizeScopes([
        'email',
        'https://www.googleapis.com/auth/userinfo.profile',
      ]);
      final GoogleSignInAccount? account = await googleSignIn.authenticate();

      if (account == null) {
        return; // user cancelled
      }

      final GoogleSignInAuthentication googleAuth =
      await account.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential =
      await _auth.signInWithCredential(credential);
      final User? currentUser = userCredential.user;

      if (currentUser != null) {
        // Check if user exists in Firestore
        final doc =
        await _firestore.collection('users').doc(currentUser.uid).get();
        if (!doc.exists) {
          // Create new user document
          await _firestore.collection('users').doc(currentUser.uid).set({
            'displayName': currentUser.displayName ?? 'User',
            'email': currentUser.email ?? '',
            'photoURL': currentUser.photoURL ?? '',
            'createdAt': FieldValue.serverTimestamp(),
            'lastLogin': FieldValue.serverTimestamp(),
          });
        } else {
          // Update last login time
          await _firestore.collection('users').doc(currentUser.uid).update({
            'lastLogin': FieldValue.serverTimestamp(),
          });
        }

        // Load user data
        await _loadUserData(currentUser);
        Get.snackbar('Success', 'Signed in successfully!');
      }
    } catch (e) {
      String errorMessage = 'Failed to sign in with Google';
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'account-exists-with-different-credential':
            errorMessage =
            'An account already exists with the same email address';
            break;
          case 'invalid-credential':
            errorMessage = 'Invalid credentials';
            break;
          case 'operation-not-allowed':
            errorMessage = 'Google sign-in is not enabled';
            break;
          case 'user-disabled':
            errorMessage = 'This account has been disabled';
            break;
          case 'user-not-found':
            errorMessage = 'User not found';
            break;
          case 'weak-password':
            errorMessage = 'Password is too weak';
            break;
          default:
            errorMessage = 'Authentication failed: ${e.message}';
        }
      }
      Get.snackbar('Error', errorMessage);
    }
  }

  Future<void> signOut() async {
    try {
      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {}
      await _auth.signOut();
      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      Get.snackbar('Error', 'Failed to sign out: $e');
    }
  }
}

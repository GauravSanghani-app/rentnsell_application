import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
import '../utils/shared_pref.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  // Future<Map<String, dynamic>?> signInWithGoogle() async {
  //   try {
  //     print('AuthService: Starting Google Sign-In...');
  //     final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
  //     if (googleUser == null) {
  //       print('AuthService: User cancelled Google Sign-In');
  //       return null;
  //     }
  //
  //     print('AuthService: Google user selected: ${googleUser.email}');
  //     final GoogleSignInAuthentication googleAuth =
  //         await googleUser.authentication;
  //
  //     print(
  //       'AuthService: Access token: ${googleAuth.accessToken != null ? "Present" : "NULL"}',
  //     );
  //     print(
  //       'AuthService: ID token: ${googleAuth.idToken != null ? "Present" : "NULL"}',
  //     );
  //
  //     if (googleAuth.accessToken == null || googleAuth.idToken == null) {
  //       print('AuthService: Missing access token or id token');
  //       print(
  //         'AuthService: This usually means OAuth client is not configured in Firebase.',
  //       );
  //       print(
  //         'AuthService: Please add SHA-1 and SHA-256 fingerprints to Firebase Console.',
  //       );
  //       print(
  //         'AuthService: SHA-1: 7B:1C:5A:2F:36:F6:14:A2:74:EC:9D:B1:7A:CC:BF:46:C6:15:4F:CF',
  //       );
  //       print(
  //         'AuthService: SHA-256: C1:BB:7A:22:3B:B8:AB:B3:29:61:6F:45:35:A7:E7:1C:8B:FD:89:C5:50:7B:A9:3E:8E:5D:06:C0:D4:02:79:28',
  //       );
  //       return null;
  //     }
  //
  //     final credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );
  //
  //     print('AuthService: Signing in with Firebase...');
  //     final UserCredential userCredential = await _auth.signInWithCredential(
  //       credential,
  //     );
  //
  //     final user = userCredential.user;
  //
  //     if (user != null) {
  //       print('AuthService: Firebase sign-in successful: ${user.email}');
  //       await preferences.putBool(SharedPreference.isLogIn, true);
  //       await preferences.putString(SharedPreference.userId, user.uid);
  //       await preferences.putString(
  //         SharedPreference.userEmail,
  //         user.email ?? '',
  //       );
  //
  //       final userData = {
  //         'id': user.uid,
  //         'email': user.email ?? '',
  //         'displayName': user.displayName ?? '',
  //         'photoUrl': user.photoURL ?? '',
  //       };
  //       print('AuthService: Returning user data: $userData');
  //       return userData;
  //     }
  //     print('AuthService: User is null after Firebase sign-in');
  //     return null;
  //   } catch (e, stackTrace) {
  //     print('AuthService: Google Sign-In error: $e');
  //     print('AuthService: Stack trace: $stackTrace');
  //     throw Exception('Google Sign-In failed: $e');
  //   }
  // }

  Future<void> signOut() async {
    try {
      // await _googleSignIn.signOut();
      await _auth.signOut();
      await preferences.putBool(SharedPreference.isLogIn, false);
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  bool isLoggedIn() {
    final isLoginFlagSet = preferences.getBool(
      SharedPreference.isLogIn,
      defValue: false,
    );
    final hasFirebaseUser = _auth.currentUser != null;
    final hasJwtToken =
        preferences.getString(SharedPreference.jwtToken) != null &&
        preferences.getString(SharedPreference.jwtToken)!.isNotEmpty;
    return isLoginFlagSet && (hasFirebaseUser || hasJwtToken);
  }

  String? getCurrentUserId() {
    return preferences.getString(SharedPreference.userId);
  }
}

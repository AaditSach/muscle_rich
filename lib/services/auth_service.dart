import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

// saare auth methods yahan hain  email, google, apple
class AuthService {
  final _auth = FirebaseAuth.instance;

  // normal email password login ya new account 
  Future<UserCredential> signInWithEmail(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> registerWithEmail(String email, String password) {
    return _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  // Google OAuth flow  token leke Firebase mein sign in kar
  Future<UserCredential?> signInWithGoogle() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return _auth.signInWithCredential(credential);
  }

  // Apple sign in security ke liye nonce zaroori hai
  Future<UserCredential> signInWithApple() async {
    final rawNonce = _generateNonce();
    final nonce = _sha256of(rawNonce); // Apple require karta hai hashed nonce

    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
      nonce: nonce,
    );

    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );

    return _auth.signInWithCredential(oauthCredential);
  }

  // random secure string bana nonce ke liye
  String _generateNonce([int length = 32]) {
    const chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final rng = Random.secure();
    return List.generate(length, (_) => chars[rng.nextInt(chars.length)]).join();
  }

  // nonce ko SHA-256 se hash karna hai
  String _sha256of(String input) {
    final bytes = utf8.encode(input);
    return sha256.convert(bytes).toString();
  }

  // sign out  Google aur Firebase dono se
  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;
}
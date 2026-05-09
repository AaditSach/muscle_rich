import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../home/home_screen.dart';
import '../login/login_screen.dart';
import '../onboarding/onboarding_screen.dart';

// yeh decide karega user kahan jaayega login, onboarding, ya home
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  // Firestore mein check karo ki user ka profile bana hai ya nahi
  Future<bool> _hasProfile(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc.exists && doc.data()?['displayName'] != null;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // Firebase auth state real time mein sun raha hai
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Color(0xFF22D3A6))),
          );
        }

        // agar logged in nahi hai toh login screen
        if (!snapshot.hasData) return const LoginScreen();

        // logged in hai toh profile check karo
        return FutureBuilder<bool>(
          future: _hasProfile(snapshot.data!.uid),
          builder: (context, profileSnap) {
            if (profileSnap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator(color: Color(0xFF22D3A6))),
              );
            }
            // profile hai toh home, nahi hai toh onboarding
            if (profileSnap.data == true) return const HomeScreen();
            return const OnboardingScreen();
          },
        );
      },
    );
  }
}
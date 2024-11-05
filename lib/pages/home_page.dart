// home_page.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'user_profile_page.dart'; // Import the new file

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user;

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((event) {
      setState(() {
        _user = event;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Google SignIn"),
      ),
      body: _user != null ? _userInfo() : _googleSignInButton(),
    );
  }

  Widget _googleSignInButton() {
    return Center(
      child: SizedBox(
        height: 50,
        child: SignInButton(
          Buttons.google,
          text: "Sign up with Google",
          onPressed: _handleGoogleSignIn,
        ),
      ),
    );
  }

  Widget _userInfo() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              image: DecorationImage(image: NetworkImage(_user!.photoURL!)),
            ),
          ),
          Text(_user!.email!),
          Text(_user!.displayName ?? ""),
          MaterialButton(
            color: Colors.red,
            child: const Text("Sign Out"),
            onPressed: () => _auth.signOut(),
          ),
        ],
      ),
    );
  }

  Future<void> _storeUserDetailsInFirestore(User user) async {
    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');

    DocumentSnapshot userSnapshot = await usersCollection.doc(user.uid).get();

    if (!userSnapshot.exists) {
      await usersCollection.doc(user.uid).set({
        'email': user.email,
        'name': user.displayName,
        'photoURL': user.photoURL,
      });
    }
  }

  Future<void> createUser(User user) async {
    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');

    await usersCollection.doc(user.uid).set({
      'email': user.email,
      'name': user.displayName,
      'photoURL': user.photoURL,
      'followingSet': false, // Initialize 'followingSet' to false for new users
      'followers': 0,
    });
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      // Create a new GoogleAuthProvider instance
      GoogleAuthProvider googleAuthProvider = GoogleAuthProvider();

      // Sign in with Google using signInWithPopup for web
      UserCredential userCredential;
      if (kIsWeb) {
        userCredential = await _auth.signInWithPopup(googleAuthProvider);
      } else {
        // For mobile, use signInWithProvider
        userCredential = await _auth.signInWithProvider(googleAuthProvider);
      }

      // Get the user information
      User user = userCredential.user!;

      // Store user details in Cloud Firestore
      await createUser(user);

      // Navigate to UserProfilePage
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserProfilePage(user: user),
        ),
      );
    } catch (error) {
      print("Error signing in with Google: $error");
    }
  }
}

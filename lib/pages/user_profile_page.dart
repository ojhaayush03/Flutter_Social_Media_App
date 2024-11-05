import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'final_profile_page.dart'; // Import the new file

class UserProfilePage extends StatelessWidget {
  final User user;

  const UserProfilePage({super.key, required this.user});

  void _goToFinalProfilePage(BuildContext context, String userDocumentId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FinalProfilePage(
          user: user,
          userDocumentId: userDocumentId,
          currentUserId: userDocumentId,
        ),
      ),
    );
  }

  Future<String> _getCurrentUserDocumentId() async {
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email;

    if (currentUserEmail != null) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: currentUserEmail)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Assuming each user has a unique email, so there should be only one document
        return querySnapshot.docs.first.id;
      }
    }

    return ''; // Return an empty string or handle the case when the user is not found
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Profile"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                image: DecorationImage(image: NetworkImage(user.photoURL!)),
              ),
            ),
            Text(user.email!),
            Text(user.displayName ?? ""),
            MaterialButton(
              color: Colors.red,
              child: const Text("Sign Out"),
              onPressed: () {
                // Handle sign-out logic
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String userDocumentId = await _getCurrentUserDocumentId();
                _goToFinalProfilePage(context, userDocumentId);
              },
              child: const Text("Go to Final Profile Page"),
            ),
          ],
        ),
      ),
    );
  }
}

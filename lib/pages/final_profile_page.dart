// final_profile_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'viewer_profile_page.dart';

class FinalProfilePage extends StatefulWidget {
  final User user;
  final String userDocumentId;
  final String currentUserId;

  const FinalProfilePage(
      {super.key, required this.user,
      required this.userDocumentId,
      required this.currentUserId});

  @override
  _FinalProfilePageState createState() => _FinalProfilePageState();
}

class _FinalProfilePageState extends State<FinalProfilePage> {
  late List<DocumentSnapshot> usersList;
  late Set<String> followingSet = {}; // Add this set to track followed users

  @override
  void initState() {
    super.initState();
    // Initialize the set
    followingSet = <String>{};
    // Retrieve the list of users from Firestore
    getUsersList();
  }

  Future<void> getUsersList() async {
    QuerySnapshot usersSnapshot =
        await FirebaseFirestore.instance.collection('users').get();
    setState(() {
      // Filter out the current user's data
      usersList = usersSnapshot.docs
          .where((doc) => doc.id != widget.currentUserId)
          .toList();
    });
  }

  Future<void> followUser(String profileOwnerDocumentId) async {
    // Update the profile owner's followers count
    await FirebaseFirestore.instance
        .collection('users')
        .doc(profileOwnerDocumentId)
        .update({
      'followers': FieldValue.increment(1),
    });

    // You might also want to store information about the followers in the current user's document
    // This depends on your specific use case
    // Example: Create a 'following' field in the current user's document to keep track of who they are following
    // Assuming widget.currentUserId is the auto-generated document ID of the current user
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentUserId)
        .update({
      'following.$profileOwnerDocumentId': true,
    });

    // Refresh the user list after following
    getUsersList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Final Profile Page"),
      ),
      body: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display the profile pic and name of the current user
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(widget.user.photoURL!),
              ),
              const SizedBox(height: 16),
              Text("Name: ${widget.user.displayName ?? 'N/A'}",
                  style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 20),
              const Text(
                "Users You May Know",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              // Check if usersList is not null
              for (var userDoc in usersList)
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage:
                          NetworkImage(userDoc['photoURL'] ?? ''),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Name: ${userDoc['name'] ?? 'N/A'}",
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          "Followers: ${userDoc['followers'] ?? 0}",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    if (userDoc['followingSet'] == true)
                      const Text("Following!",
                          style: TextStyle(color: Colors.green)),
                    if (userDoc['followingSet'] != true)
                      ElevatedButton(
                        onPressed: () {
                          followUser(userDoc.id);
                          // Navigate to ViewerProfilePage when the button is clicked
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewerProfilePage(
                                userDocumentId: userDoc.id,
                              ),
                            ),
                          );
                        },
                        child: const Text("Follow"),
                      ),
                  ],
                ), // Display a loading indicator
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uniapp/screens/chat_screen.dart';
import 'package:uniapp/widgets/feed/post_card.dart';

class FeedScreen extends StatefulWidget {
  final String uid;
  const FeedScreen({super.key, required this.uid});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  Future<void> _refresh() {
    return Future.delayed(const Duration(seconds: 2));
  }

  List<String> followingUser = [];
  bool followingUserscheck = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    followingUsers();
  }

  Future followingUsers() async {
    final firestore = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser!.uid;
    try {
      final userSnapshot = await firestore.collection('users').doc(user).get();

      if (userSnapshot.exists) {
        final followedUsers = List<String>.from(userSnapshot['following']);
        if (followedUsers.isEmpty) {
          setState(() {
            followingUserscheck = false;
          });
        }
        print(
            'this is followed users list without your account $followedUsers');
        followedUsers.add(user);
        setState(() {
          followingUser = followedUsers;
        });
        print('this is following users list with your account  $followingUser');

        return followedUsers;
      } else {
        print('User not found.');
        return null;
      }
    } catch (e) {
      print('Error retrieving posts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => chatScreen(uid: widget.uid)));
            },
            icon: const Icon(Icons.chat),
          ),
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: followingUserscheck
          ? FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('posts')
                  .orderBy('datePublished', descending: true)
                  .where('uid')
                  .get(),
              builder: (context,
                  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) => PostCard(
                        snap: snapshot.data!.docs[index].data(),
                      ),
                    ));
              },
            )
          : const Center(
              child: Text(
              'You have to follow someone to see them posts here',
              textAlign: TextAlign.center,
            )),
    );
  }
}

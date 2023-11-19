import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';



class GroupUsersSreen extends ConsumerWidget {
  final String groupId;
  final String profilePic;
  final String name;
  static const String routeName = '/groupusers-screen';
  GroupUsersSreen({
    required this.groupId,
    required this.profilePic,
    required this.name
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Center(
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                  profilePic,
                ),
                radius: 60,
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            "Group Users",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            children: [
              Icon(
                Icons.add,
                color: Colors.blue,
              ), // Add your desired icon here
              GestureDetector(
                onTap:(){
                 
                } ,
                child: Text(
                  "Add participants",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('groups')
                  .doc(groupId)
                  .snapshots(),
              builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                Map<String, dynamic> groupData =
                    snapshot.data!.data() as Map<String, dynamic>;

                List<String> memberUids =
                    List<String>.from(groupData['membersUid']);
                return FutureBuilder(
                  future: getUsersDetails(memberUids),
                  builder: (context,
                      AsyncSnapshot<List<Map<String, dynamic>>> userSnapshot) {
                    if (!userSnapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    List<Map<String, dynamic>> users = userSnapshot.data!;

                    return ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListTile(
                                title: Text(users[index]['name']),
                                subtitle: Text(users[index]['phoneNumber']),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> getUsersDetails(
      List<String> userUids) async {
    List<Map<String, dynamic>> users = [];

    for (int i = 0; i < userUids.length; i++) {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userUids[i])
          .get();
      if (userDoc.exists) {
        users.add(userDoc.data() as Map<String, dynamic>);
      }
    }

    return users;
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Teams/common/utils/utils.dart';
import 'package:Teams/models/user_model.dart';
import 'package:Teams/features/chat/screens/mobile_chat_screen.dart';

final selectContactsRepositoryProvider = Provider(
  (ref) => SelectContactRepository(
    firestore: FirebaseFirestore.instance,
  ),
);

class SelectContactRepository {
  final FirebaseFirestore firestore;

  SelectContactRepository({
    required this.firestore,
  });

  Future<List<Contact>> getContacts() async {
    List<Contact> contacts = [];
    try {
      // Ensure that the permission request is not null
      bool hasPermission = await FlutterContacts.requestPermission();

      if (hasPermission) {
        // Ensure that the result of getContacts is not null
        contacts = await FlutterContacts.getContacts(withProperties: true);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return contacts;
  }

  void selectContact(Contact selectedContact, BuildContext context) async {
    try {
      var userCollection = await firestore.collection('users').get();
      bool isFound = false;

      for (var document in userCollection.docs) {
        var userData = UserModel.fromMap(document.data());
        print("UserData${document}");

        String selectedPhoneNum = selectedContact.phones[0].number.replaceAll(
          ' ',
          '',
        );

        
        try {
          if (selectedPhoneNum == userData.phoneNumber) {
            isFound = true;
            Navigator.pushNamed(
              context,
              MobileChatScreen.routeName,
              arguments: {
                'name': userData.name,
                'uid': userData.uid,
              },
            );
          }
        } catch (e) {
          print("Error while selecting contact to chat${e.toString()}");
        }
      }

      if (isFound == false) {
        showSnackBar(
          context: context,
          content: 'This number does not exist on this app.',
        );
      }
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }
}

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:whatsnap/loading.dart';

class SelectContact extends StatefulWidget {
  @override
  _SelectContactState createState() => _SelectContactState();
}

class _SelectContactState extends State<SelectContact> {

  bool isLoading;
  Iterable<Contact> contacts;

  void getContacts() async {
    setState(() {
      isLoading = true;
    });
    contacts = await ContactsService.getContacts();
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getContacts();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading? LoadingScreen(): Scaffold(
      appBar: AppBar(
        title: Text('Select Contact'),
      ),
      body: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          Contact contact = contacts.elementAt(index);
          return ListTile(
            onTap: () async {
              if(contact.phones.length == 1)
                Navigator.pop(context, contact.phones.elementAt(0).value);
              else {
                String number = await showDialog(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      child: Container(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: contact.phones.length,
                          itemBuilder: (context, index) {
                            Item phone = contact.phones.elementAt(index);
                            return ListTile(
                              onTap: () {
                                Navigator.pop(context, phone.value);
                              },
                              title: Text(phone.value),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
                if(number != null) {
                  Navigator.pop(context, number);
                }
              }
            },
            leading: (contact.avatar != null && contact.avatar.isNotEmpty)? CircleAvatar(
              backgroundImage: MemoryImage(contact.avatar),
            ): CircleAvatar(
              child: Text(contact.initials()),
              backgroundColor: Theme.of(context).accentColor,
            ),
            title: Text(contact.displayName),
          );
        },
      ),
    );
  }
}

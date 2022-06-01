
import 'package:barcode_reader/repositories/repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SavedCodePage extends StatefulWidget {
  
  const SavedCodePage({Key? key}) : super(key: key);

  @override
  State<SavedCodePage> createState() => _SavedCodePageState();
}

class _SavedCodePageState extends State<SavedCodePage> {

  final repository = Repository(FirebaseFirestore.instance);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.primary
        ),
        title: Text(
          "Saved",
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("barcodes").snapshots(),
        builder: (context, snapshot) {
          if(snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data?.docs.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                DocumentSnapshot data = snapshot.data!.docs[index];
                return Dismissible(
                  background: Container(color: Colors.red),
                  key: Key(data.id),
                  onDismissed: (dismissDiretion) {
                    repository.delete(data);
                  },
                  child: ListTile(
                    title: Text(data['barcode']),
                    onTap: () => _launchURL(data['barcode']),
                  ),
                );
              },
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        }
      ),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    }
  }
}
 
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Manualsplit extends StatefulWidget {
  const Manualsplit({super.key});

  @override
  State<Manualsplit> createState() => _ManualsplitState();
}

class _ManualsplitState extends State<Manualsplit> {
  final titlecontroller = TextEditingController();
  final amountcontroller = TextEditingController();

  String? paidBy;
  Map<String, TextEditingController> controllers = {};

  @override
  void initState() {
    super.initState();
    paidBy = FirebaseAuth.instance.currentUser!.uid;
  }

  void save(List users) async {
    double? total = double.tryParse(amountcontroller.text);

    if (total == null || total <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Enter valid amount")),
      );
      return;
    }

    Map<String, double> splits = {};

    for (var u in users) {
      String userId = u["id"];
      double amount =
          double.tryParse(controllers[userId]?.text ?? "0") ?? 0;

      splits[userId] = (userId == paidBy) ? 0 : amount;
    }

    List<String> participants = splits.keys.toList();

    await FirebaseFirestore.instance.collection("expenses").add({
      "Title": titlecontroller.text,
      "total": total,
      "paidBy": paidBy,
      "paidByName":
          users.firstWhere((u) => u["id"] == paidBy)["name"],
      "splits": splits,
      "participants": participants,
      "createdAt": FieldValue.serverTimestamp(),
      "paid": {
        for (var p in participants) p: (p == paidBy)
      },
      "splitNames": {
        for (var u in users)
          if (splits.containsKey(u["id"])) u["id"]: u["name"]
      }
    });

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Manual Split",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color.fromARGB(255, 67, 33, 83),
      ),

      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(currentUser.uid)
            .collection("Friends")
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          var docs = snapshot.data!.docs;

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection("users")
                .doc(currentUser.uid)
                .get(),
            builder: (context, userSnapshot) {
              if (!userSnapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              final userDoc = userSnapshot.data!;

              if (!userDoc.exists) {
                return Center(
                  child: Text("User profile not found"),
                );
              }

              final userData =
                  userDoc.data() as Map<String, dynamic>?;

              String myName =
                  userData?["name"] ?? "Unknown User";

              List<Map<String, dynamic>> users = [
                {
                  "id": currentUser.uid,
                  "name": myName,
                },
                ...docs.map((doc) {
                  final friendData =
                      doc.data() as Map<String, dynamic>;

                  return {
                    "id": doc.id,
                    "name":
                        friendData["name"] ?? "Unknown User",
                  };
                }).toList(),
              ];

              for (var u in users) {
                controllers.putIfAbsent(
                  u["id"],
                  () => TextEditingController(),
                );
              }

              return SingleChildScrollView(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    TextField(
                      controller: titlecontroller,
                      decoration: InputDecoration(
                        labelText: "Title",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    SizedBox(height: 20),

                    TextField(
                      controller: amountcontroller,
                      keyboardType:
                          TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: "Amount",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    SizedBox(height: 20),

                    InputDecorator(
                      decoration: InputDecoration(
                        labelText: "Paid By",
                        border: OutlineInputBorder(),
                      ),
                      child: DropdownButton<String>(
                        value: paidBy,
                        isExpanded: true,
                        items: users.map((u) {
                          return DropdownMenuItem<String>(
                            value: u["id"],
                            child: Text(u["name"]),
                          );
                        }).toList(),
                        onChanged: (v) {
                          setState(() {
                            paidBy = v;
                          });
                        },
                      ),
                    ),

                    SizedBox(height: 20),

                    ...users.map((u) {
                      if (u["id"] == paidBy) {
                        return SizedBox();
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                        ),
                        child: TextField(
                          controller: controllers[u["id"]],
                          keyboardType:
                              TextInputType.number,
                          decoration: InputDecoration(
                            labelText:
                                "${u["name"]} owes",
                            border:
                                OutlineInputBorder(),
                          ),
                        ),
                      );
                    }).toList(),

                    SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: () => save(users),
                      child: Text("Add Expense"),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}


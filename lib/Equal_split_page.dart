import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SingelExpensePage extends StatefulWidget {
  const SingelExpensePage({super.key});

  @override
  State<SingelExpensePage> createState() => _SingelExpensePageState();
}

class _SingelExpensePageState extends State<SingelExpensePage> {
  final titlecontroller = TextEditingController();
  final amountcontroller = TextEditingController();

  String? paidBy;
  Map<String, bool> selected = {};

  @override
  void initState() {
    super.initState();
    paidBy = FirebaseAuth.instance.currentUser!.uid;
  }

  void splitAndSave(List users) async {
    double? total = double.tryParse(amountcontroller.text.trim());

    if (total == null || total <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Enter valid amount")));
      return;
    }

    List<String> participants =
        selected.entries.where((e) => e.value).map((e) => e.key).toList();

    if (paidBy != null && !participants.contains(paidBy)) {
      participants.add(paidBy!);
    }

    if (participants.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Select at least one person")));
      return;
    }

    double share = total / participants.length;
    Map<String, double> splits = {};

    for (var p in participants) {
      splits[p] = (p == paidBy) ? 0 : share;
    }

    await FirebaseFirestore.instance.collection("expenses").add({
      "Title": titlecontroller.text,
      "Type": "equal",
      "total": total,
      "paidBy": paidBy,
      "paidByName":
          users.firstWhere((u) => u["id"] == paidBy)["name"], // ✅ correct
      "splits": splits,
      "splitNames": {
        for (var u in users)
          if (splits.containsKey(u["id"])) u["id"]: u["name"]
      },
      "participants": splits.keys.toList(),
      "createdAt": FieldValue.serverTimestamp(),
      "paid": {
        for (var p in participants) p: (p == paidBy) // ✅ payer already paid
      },
    });

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 67, 33, 83),
        title: Text("Equal Split", style: TextStyle(color: Colors.white)),
      ),

      // 🔥 STREAM (friends)
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(currentUser!.uid)
            .collection("Friends")
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var docs = snapshot.data!.docs;

          // 🔥 FUTURE (your name)
          return FutureBuilder(
            future: FirebaseFirestore.instance
                .collection("users")
                .doc(currentUser.uid)
                .get(),
            builder: (context, userSnapshot) {
              if (!userSnapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              String myName = userSnapshot.data!["name"];

              // ✅ CLEAN USER LIST
              List<Map<String, dynamic>> allUsers = [
                {
                  "id": currentUser.uid,
                  "name": myName,
                },
                ...docs.map((doc) => {
                      "id": doc.id,
                      "name": doc["name"],
                    })
              ];

              return SingleChildScrollView(
                padding: EdgeInsets.all(12),
                child: Column(
                  children: [
                    Text("Enter Details",
                        style: TextStyle(fontWeight: FontWeight.bold)),

                    SizedBox(height: 10),

                    TextField(
                      controller: titlecontroller,
                      decoration: InputDecoration(
                        labelText: "Title",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    SizedBox(height: 10),

                    TextField(
                      controller: amountcontroller,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Amount",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    SizedBox(height: 20),

                    // 🔽 DROPDOWN
                    InputDecorator(
                      decoration: InputDecoration(
                        labelText: "Paid By",
                        border: OutlineInputBorder(),
                      ),
                      child: DropdownButton<String>(
                        value: paidBy,
                        isExpanded: true,
                        items: allUsers.map((u) {
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

                    SizedBox(height: 10),

                    Text("Expense shared by:"),

                    Column(
                      children: allUsers
                          .where((u) => u["id"] != paidBy)
                          .map((u) {
                        return CheckboxListTile(
                          title: Text(u["name"]),
                          value: selected[u["id"]] ?? false,
                          onChanged: (val) {
                            setState(() {
                              selected[u["id"]] = val!;
                            });
                          },
                        );
                      }).toList(),
                    ),

                    SizedBox(height: 10),

                    ElevatedButton(
                      onPressed: () => splitAndSave(allUsers),
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
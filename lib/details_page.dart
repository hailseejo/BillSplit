import 'package:flutter/material.dart';
import 'data_store.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseDetailsPage extends StatefulWidget {
  final String expenseId;
  final Map<String, dynamic> expense;

  const ExpenseDetailsPage({
    super.key,
    required this.expense,
    required this.expenseId,
  });

  @override
  State<ExpenseDetailsPage> createState() =>
      _ExpenseDetailsPageState();
}

class _ExpenseDetailsPageState
    extends State<ExpenseDetailsPage> {
  final currentUserId =
      FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Details",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor:
            const Color.fromARGB(255, 67, 33, 83),
      ),

      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("expenses")
            .doc(widget.expenseId)
            .snapshots(),

        builder: (context, snapshot) {
          
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator());
          }

          var e =
              snapshot.data!.data() as Map<String, dynamic>;
String paidByName;

if (e["paidBy"] == currentUserId) {
  paidByName = "You";
} else {
  paidByName = e["paidByName"] ?? "Unknown";
}
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

               
                Text(
                  e["Title"],
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                
                Text(
                  "Total: ₹${e["total"]}",
                  style: const TextStyle(
                      fontSize: 18,
                      color: Colors.green),
                ),

                const SizedBox(height: 6),

               
                Text(
                  "Paid by: $paidByName",
                  style: const TextStyle(fontSize: 16),
                ),

                const SizedBox(height: 20),

                
                const Text(
                  "Splits",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),

                const Divider(),

              
                ...(e["splits"] != null
                    ? (e["splits"]
                            as Map<String, dynamic>)
                        .entries
                        .map<Widget>((entry) {
                           String userId = entry.key;
                          if (entry.key == e["paidBy"]) return SizedBox();
                        bool isPaid =
                            e["paid"]?[entry.key] == true;
                         String rawName = e["splitNames"]?[userId] ?? "Unknown";




String name = userId == currentUserId
    ? "You"
    : e["splitNames"]?[userId] ?? "Unknown";
                        return Padding(
                          padding:
                              const EdgeInsets.symmetric(
                                  vertical: 6),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,
                            children: [

                              
                              Row(
                                children: [
                                  
                                  Text(
                                    name,
                                    style: TextStyle(
                                      color: isPaid
                                          ? Colors.grey
                                          : Colors.black,
                                      decoration: isPaid
                                          ? TextDecoration
                                              .lineThrough
                                          : null,
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  Text(
                                    isPaid
                                        ? "✅ Paid"
                                        : "❌ Pending",
                                    style: TextStyle(
                                      color: isPaid
                                          ? Colors.green
                                          : Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),

                             
                              Text(
                                "₹${(entry.value as num).toDouble().toStringAsFixed(2)}",
                                style: const TextStyle(
                                    fontWeight:
                                        FontWeight.w500),
                              ),
                            ],
                          ),
                        );
                      }).toList()
                    : [const Text("No split data")]),
              ],
            ),
          );
        },
      ),
    );
  }
}
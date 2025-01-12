import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:habiquest/pages/habit-todo/todo-add.dart';
import 'package:habiquest/pages/habit-todo/todo-edit.dart';
import 'package:lucide_icons/lucide_icons.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  _TodoPageState createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid ?? 'anonymous')
            .collection('todos')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  LucideIcons.checkCircle,
                  color: Theme.of(context).colorScheme.tertiary,
                  size: 100,
                ),
                const SizedBox(height: 16),
                Text('Minden kész!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.tertiary)),
              ],
            ));
          }

          final todos = snapshot.data!.docs;

          return ListView.builder(
            itemCount: todos.length,
            itemBuilder: (context, index) {
              final todoData = todos[index].data() as Map<String, dynamic>;
              final todoTitle = todoData['cim'] ?? 'Untitled';
              return Card(
                child: ListTile(
                  title: Text(todoTitle),
                  leading: Checkbox(
                    activeColor: Theme.of(context).colorScheme.secondary,
                    checkColor: Theme.of(context).colorScheme.onSecondary,
                    value: todoData['kesz'],
                    onChanged: (value) {
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(user?.uid ?? 'anonymous')
                          .collection('todos')
                          .doc(todos[index].id)
                          .update({'kesz': value});
                    },
                  ),
                  trailing: todoData['kesz']
                      ? IconButton(
                          onPressed: () {
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(user?.uid ?? 'anonymous')
                                .collection('todos')
                                .doc(todos[index].id)
                                .delete();
                          },
                          icon: const Icon(LucideIcons.trash),
                          color: Theme.of(context).colorScheme.secondary,
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Theme.of(context).colorScheme.onSecondary,
        child: const Icon(LucideIcons.plus),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true, // Adjusts height based on content
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
            ),
            builder: (BuildContext context) {
              final TextEditingController taskController =
                  TextEditingController();

              return Padding(
                padding: EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Adjust height dynamically
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: taskController,
                      cursorColor: Theme.of(context).colorScheme.secondary,
                      decoration: InputDecoration(
                        hintText: "Add meg az új feladatot",
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.all(12.0),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {
                          final String taskText = taskController.text.trim();
                          if (taskText.isNotEmpty) {
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(user?.uid ?? 'anonymous')
                                .collection('todos')
                                .add({
                              'cim': taskText,
                              'kesz': false,
                            }).then((value) {
                              Navigator.pop(context);
                            });
                          }
                        },
                        child: const Text("Mentés"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
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

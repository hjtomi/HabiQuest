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
            return const Center(child: Text('No todos found.'));
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
                  subtitle: Text('Határidő: ${todoData['hatarido'].toDate().toLocal().toString().split(' ')[0]}'),
                  trailing: Checkbox(
                    value: todoData['kesz'],
                    onChanged: (value) {
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(user?.uid ?? 'anonymous')
                          .collection('todos')
                          .doc(todos[index].id)
                          .update({'kesz': value});
                      if (value == true) {
                        // Remove from the list if checked
                        setState(() {
                          todos.removeAt(index);
                        });
                      }
                    },
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => TodoEdit(
                          teendo: todoData,
                          index: index,
                          mentTeendo: (index, cim, megjegyzes, nehezseg, hatarido) {
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(user?.uid ?? 'anonymous')
                                .collection('todos')
                                .doc(todos[index].id)
                                .update({
                              'cim': cim,
                              'megjegyzes': megjegyzes,
                              'nehezseg': nehezseg,
                              'hatarido': hatarido,
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Theme.of(context).colorScheme.onSecondary,
        child: Icon(LucideIcons.plus),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TodoAdd(
                hozzaadTeendo: (cim, megjegyzes, nehezseg, hatarido) {
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(user?.uid ?? 'anonymous')
                      .collection('todos')
                      .add({
                    'cim': cim,
                    'megjegyzes': megjegyzes,
                    'nehezseg': nehezseg,
                    'hatarido': hatarido,
                    'kesz': false,
                  });
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
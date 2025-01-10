import 'package:flutter/material.dart';
import 'package:habiquest/firebase/query/habitHandle.dart';

class HabitTile extends StatefulWidget {
  final String title; // Add a final field for the title
  final bool state;
  final String id;

  const HabitTile(
      {super.key,
      required this.title,
      required this.state,
      required this.id}); // Assign the title in the constructor

  @override
  State<HabitTile> createState() => _HabitTileState();
}

class _HabitTileState extends State<HabitTile> {
  late bool isOn; // State variable to track on/off status
  void initState() {
    super.initState();
    isOn = widget.state; // Initialize the variable in initState
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4.0),
      child: Card(
        color: Theme.of(context).colorScheme.onPrimary,
        child: ListTile(
          title: Text(widget.title),
          trailing: IconButton.filledTonal(
            onPressed: () {
              setState(() {
                isOn = !isOn; // Toggle the state
              });
              firestoreCompleteHabit(habitId: widget.id, updatedState: isOn);
            },
            icon: const Icon(Icons.check), // Change icon
            style: IconButton.styleFrom(
              backgroundColor: isOn
                  ? Theme.of(context).colorScheme.secondary // On color
                  : Theme.of(context).colorScheme.primary, // Off color
              foregroundColor: Theme.of(context).colorScheme.onSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

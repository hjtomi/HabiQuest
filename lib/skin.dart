import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CharacterSelector extends StatefulWidget {
  const CharacterSelector({super.key});

  @override
  _CharacterSelectorState createState() => _CharacterSelectorState();
}

class _CharacterSelectorState extends State<CharacterSelector> {
  // Paths to character images stored in the lib/characters folder
  final List<String> characterImages = [
    'lib/assets/skins/skin-1.png',
    'lib/assets/skins/skin-2.png',
    'lib/assets/skins/skin-3.png',
    'lib/assets/skins/skin-4.png',
  ];

  final List<String> charachterNames = [
    'Celestia',
    'Cobalt',
    'Thalgar',
    'Vulcan',
  ];

  final List<String> characterDescription = [
    'Bár külsőre törékenynek tűnik, ereje hatalmas, és minden varázslata az univerzum titkos szöveteiből merít.',
    'Egy önállóan gondolkodó kőgólem, akit a föld szívéből fakadó energiák tartanak életben.',
    'A rettenthetetlen harci bika, egy letűnt törzs szellemi vezére, aki az ősök harci technikáit és bölcsességét örökölte.',
    'Mélyén szunnyadt évszázadokig, míg a világ kétségbeesése fel nem ébresztette. Létezése egyszerre áldás és átok...',
  ];

  int currentIndex = 0;

  void _onLeftSwipe() {
    setState(() {
      currentIndex =
          (currentIndex > 0) ? currentIndex - 1 : characterImages.length - 1;
    });
    print(currentIndex);
  }

  void _onRightSwipe() {
    setState(() {
      currentIndex =
          (currentIndex < characterImages.length - 1) ? currentIndex + 1 : 0;
    });
    print(currentIndex);
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? user = FirebaseAuth.instance.currentUser;

  bool isLoading = false;

  Future<void> updateCharacter(int characterValue) async {
    isLoading = true;
    try {
      // Reference the user's document in Firestore
      await _firestore.collection('users').doc(user!.uid).update({
        'character': characterValue,
        'balance': characterValue == 1 ? 50 : 0,
        'health': characterValue == 2 ? 200 : 100,
        'attack': characterValue == 4 ? 50 : 25,
        'defense': characterValue == 3 ? 20 : 10,
        'level': 1,
        'xp': 0,
        'secondsInApp': 0,
        'moneyChange': [DateTime.now(), characterValue == 1 ? 50 : 0],
      });
      print('Character updated successfully!');
      Navigator.of(context).pop();
    } catch (e) {
      print('Error updating character: $e');
    } finally {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Válaszd ki a karakteredet'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: PageView.builder(
                itemCount: characterImages.length,
                onPageChanged: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          characterImages[index],
                          fit: BoxFit.contain,
                        ),
                        Text(
                          charachterNames[index],
                          style: const TextStyle(
                              fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          textAlign: TextAlign.center,
                          characterDescription[index],
                          style: const TextStyle(
                              fontSize: 19, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              style: ButtonStyle(
                padding: WidgetStateProperty.all<EdgeInsets>(
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
              onPressed: () => updateCharacter(currentIndex + 1),
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text(
                      "Kiválasztás",
                      style: TextStyle(fontSize: 20),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

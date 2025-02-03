import 'package:flutter/material.dart';
import 'package:habiquest/auth.dart';
import 'package:habiquest/pages/statistics_page.dart';
import 'package:habiquest/pages/market_page.dart';
import 'package:habiquest/pages/monster_page.dart'; // Import the new monster page

class ThemeColors {
  static const Color primary = Color(0xff1D2B53);
  static const Color secondary = Color(0xff7E2553);
  static const Color tetriary = Color(0xffFF004D);
  static const Color highlight = Color(0xffFAEF5D);
}

void printWarning(String text) {
  print('\x1B[33m$text\x1B[0m');
}

void printError(String text) {
  print('\x1B[31m$text\x1B[0m');
}

void printMessage(String text) {
  print('\x1B[32m$text\x1B[0m');
}

Drawer drawer(BuildContext context) {
  return Drawer(
    child: ListView(
      padding: const EdgeInsets.symmetric(vertical: 32),
      children: [
        Flexible(
          child: Card(
            color: Colors.grey[900],
            child: ListTile(
              contentPadding: const EdgeInsets.all(8),
              trailing: IconButton(
                icon: const Icon(Icons.logout_outlined),
                onPressed: Auth().signOut,
              ),
              leading: characterId != null
                  ? Image(
                      fit: BoxFit.cover,
                      width: 80,
                      height: 80,
                      image: AssetImage('lib/assets/skins/skin-$characterId.png'),
                    )
                  : const Icon(Icons.person),
              title: Text(
                currentUser!.displayName ?? 'Unknown',
                overflow: TextOverflow.fade,
              ),
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.insert_chart_outlined_rounded),
          title: const Text('Statisztikák'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const StatisticsPage()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.storefront),
          title: const Text('Piactér'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MarketPage()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.pets),
          title: const Text('Szörnyek'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MonsterPage()),
            );
          },
        ),
      ],
    ),
  );
}
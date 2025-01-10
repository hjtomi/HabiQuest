import 'package:flutter/material.dart';
import 'package:habiquest/components/MarketHolder.dart';
import 'package:habiquest/utils/MarketJSONConverter.dart';
import 'package:lucide_icons/lucide_icons.dart';

class MarketPage extends StatefulWidget {
  const MarketPage({super.key});

  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  late Future<List<Item>> itemsFuture;

  @override
  void initState() {
    super.initState();
    itemsFuture = loadItems();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        initialIndex: 0,
        length: 6,
        child: Scaffold(
            appBar: TabBar(
                labelColor: Theme.of(context).colorScheme.secondary,
                indicatorColor: Theme.of(context).colorScheme.secondary,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: const [
                  Tab(text: "Fegyverek", icon: Icon(LucideIcons.sword)),
                  Tab(
                    text: "Páncélok",
                    icon: Icon(LucideIcons.shield),
                  ),
                  Tab(
                    text: "Ételek",
                    icon: Icon(LucideIcons.beef),
                  ),
                  Tab(
                    text: "Bájitalok",
                    icon: Icon(LucideIcons.flaskConical),
                  ),
                  Tab(
                    text: "Kozmetikák",
                    icon: Icon(LucideIcons.shirt),
                  ),
                  Tab(
                    text: "Egyébb",
                    icon: Icon(LucideIcons.circleEllipsis),
                  ),
                ]),
            body: const TabBarView(children: [
              CategoryHolder(category: "weapon"),
              CategoryHolder(category: "armor"),
              CategoryHolder(category: "food"),
              CategoryHolder(category: "potion"),
              CategoryHolder(category: "cosmetic"),
              CategoryHolder(category: "misc"),
            ])));
  }
}

import 'package:flutter/material.dart';
import 'package:habiquest/components/MarketHolder.dart';
import 'package:habiquest/components/MarketItem.dart';
import 'package:habiquest/utils/MarketJSONConverter.dart';

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
                tabs: [
                  Tab(icon: Text("Fegyverek")),
                  Tab(icon: Text("Páncélok")),
                  Tab(icon: Text("Ételek")),
                  Tab(icon: Text("Bájitalok")),
                  Tab(icon: Text("Kozmetikák")),
                  Tab(icon: Text("Egyebek")),
                ]),
            body: TabBarView(children: [
              CategoryHolder(category: "weapon"),
              CategoryHolder(category: "armor"),
              CategoryHolder(category: "food"),
              CategoryHolder(category: "potion"),
              CategoryHolder(category: "cosmetic"),
              CategoryHolder(category: "misc"),
            ])));
  }
}

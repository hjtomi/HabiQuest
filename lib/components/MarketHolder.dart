import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:habiquest/components/MarketItem.dart';
import 'package:habiquest/utils/MarketJSONConverter.dart';

class CategoryHolder extends StatefulWidget {
  final String category;

  const CategoryHolder({
    super.key,
    required this.category,
  });

  @override
  State<CategoryHolder> createState() => _CategoryHolderState();
}

class _CategoryHolderState extends State<CategoryHolder> {
  late Future<List<Item>> itemsFuture;

  @override
  void initState() {
    super.initState();
    itemsFuture = loadItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Item>>(
        future: itemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No items available."));
          } else {
            // Filter the items by category
            final filteredItems = snapshot.data!
                .where((item) => item.category == widget.category)
                .toList();

            if (filteredItems.isEmpty) {
              return const Center(child: Text("No items in this category."));
            }

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // Number of items per row
                  crossAxisSpacing: 8.0, // Spacing between columns
                  mainAxisSpacing: 8.0, // Spacing between rows
                  childAspectRatio: 0.8, // Adjust height/width ratio
                ),
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  return MarketItem(item: item);
                },
              ),
            );
          }
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:habiquest/utils/MarketJSONConverter.dart';
import 'package:habiquest/utils/theme/AppColors.dart';
import 'package:habiquest/utils/theme/AppTheme.dart';
import 'package:slide_to_act/slide_to_act.dart';

class MarketItem extends StatelessWidget {
  const MarketItem({
    super.key,
    required this.item,
  });

  final Item item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Container(
              width: double.infinity, // Makes the container full-width
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Ensures minimal height
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Image.asset(
                        item.image,
                        width: 100,
                        height: 100,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Text(
                      item.name,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Divider(
                        thickness: 2,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    Text(
                      item.description,
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    SlideAction(
                      onSubmit: () {
                        Navigator.of(context).pop();
                      },
                      outerColor: Theme.of(context).colorScheme.secondary,
                      text: item.price.toString(),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          side: BorderSide(
              color: Theme.of(context).colorScheme.secondary, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Item Image
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Image.asset(
                item.image,
                width: 64,
                height: 64,
                fit: BoxFit.contain,
                cacheWidth: 200, // Adjust to match the required display size
                cacheHeight: 200,
              ),
            ),
            // Price Section
            Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.paid_rounded,
                      color: Theme.of(context).colorScheme.tertiary, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '${item.price}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

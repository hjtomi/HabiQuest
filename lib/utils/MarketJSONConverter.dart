import 'dart:convert';
import 'package:flutter/services.dart';

class Item {
  final int id;
  final String name;
  final String image;
  final String description;
  final double price;
  final String category;

  Item({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
    required this.price,
    required this.category,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      description: json['description'],
      price: json['price'].toDouble(),
      category: json['category'],
    );
  }
}

Future<List<Item>> loadItems() async {
  final String response = await rootBundle.loadString('lib/assets/market.json');
  final List<dynamic> data = json.decode(response);
  return data.map((json) => Item.fromJson(json)).toList();
}

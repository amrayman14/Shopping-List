import 'dart:ui';


enum Categories {
  vegetables,
  fruit,
  meat,
  dairy,
  carbs,
  sweets,
  spices,
  convenience,
  hygiene,
  other
}

class Category {
    const Category(this.fruitName,this.color);
  final String fruitName;
  final Color color;
}
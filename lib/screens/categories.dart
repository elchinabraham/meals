import 'package:flutter/material.dart';
import 'package:meals/data/dummy_data.dart';
import 'package:meals/screens/meals.dart';
import 'package:meals/widgets/category_grid_item.dart';

import '../models/category.dart';
import '../models/meal.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({
    super.key,
    required this.onToogleFavorite,
    required this.aviableMeals,
  });

  final void Function(Meal meal) onToogleFavorite;
  final List<Meal> aviableMeals;

  void _selectCategory(BuildContext context, Category category) {
    var selectedCategoryMeals = aviableMeals
        .where((meal) => meal.categories.contains(category.id))
        .toList();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => MealsScreen(
          title: category.title,
          meals: selectedCategoryMeals,
          onToogleFavorite: onToogleFavorite,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GridView(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3.0 / 2.0,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      children: [
        for (final c in availableCategories)
          CategoryGridItem(
            category: c,
            onSelectCategory: () {
              _selectCategory(context, c);
            },
          ),
      ],
    );
  }
}

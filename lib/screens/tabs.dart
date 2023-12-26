import 'package:flutter/material.dart';
import 'package:meals/providers/meals_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meals/screens/categories.dart';
import 'package:meals/screens/filters.dart';
import 'package:meals/screens/meals.dart';
import 'package:meals/widgets/main_drawer.dart';

import '../models/meal.dart';

const kInitialFIlters = {
  Filter.gluter: false,
  Filter.lactose: false,
  Filter.vegetarian: false,
  Filter.vegan: false,
};

class TabsScreen extends ConsumerStatefulWidget {
  const TabsScreen({super.key});

  @override
  ConsumerState<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends ConsumerState<TabsScreen> {
  int _selectedPageIndex = 0;
  final List<Meal> _favoriteMeals = [];
  Map<Filter, bool> _selectedFilters = kInitialFIlters;

  void _showInfoMessage(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  void _toogleMealFavoriteStatus(Meal m) {
    final isExisting = _favoriteMeals.contains(m);
    setState(() {
      if (isExisting) {
        _favoriteMeals.remove(m);
        _showInfoMessage('Meal is no longer a favorite');
      } else {
        _favoriteMeals.add(m);
        _showInfoMessage('Marked as a favorite');
      }
    });

    debugPrint("${_favoriteMeals.length}");
  }

  @override
  Widget build(BuildContext context) {
    final meals = ref.watch(mealsProvider);
    final aviableMeals = meals.where(
      (meal) {
        if (_selectedFilters[Filter.gluter]! && !meal.isGlutenFree) {
          return false;
        }

        if (_selectedFilters[Filter.lactose]! && !meal.isLactoseFree) {
          return false;
        }

        if (_selectedFilters[Filter.vegetarian]! && !meal.isVegetarian) {
          return false;
        }

        if (_selectedFilters[Filter.vegan]! && !meal.isVegan) {
          return false;
        }

        return true;
      },
    ).toList();

    Widget activePage = CategoriesScreen(
      onToogleFavorite: _toogleMealFavoriteStatus,
      aviableMeals: aviableMeals,
    );
    var activePageTitle = 'Pick your category';

    if (_selectedPageIndex == 1) {
      activePage = MealsScreen(
        meals: _favoriteMeals,
        onToogleFavorite: _toogleMealFavoriteStatus,
      );
      activePageTitle = 'Your favorites';
    }

    void setScreen(String identifier) async {
      Navigator.of(context).pop();
      if (identifier == 'filters') {
        final result = await Navigator.of(context).push<Map<Filter, bool>>(
          MaterialPageRoute(
            builder: (ctx) => FiltersScreen(currentFilter: _selectedFilters),
          ),
        );

        setState(() {
          _selectedFilters = result ?? kInitialFIlters;
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(activePageTitle),
      ),
      drawer: MainDrawer(onSelectScreen: setScreen),
      body: activePage,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedPageIndex,
        onTap: (selectedTabIndex) {
          _selectPage(selectedTabIndex);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.set_meal),
            label: 'Category',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorite',
          ),
        ],
      ),
    );
  }
}

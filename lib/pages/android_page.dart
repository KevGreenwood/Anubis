import 'package:flutter/material.dart';

import '../utils/app_card.dart';

class AndroidPage extends StatelessWidget
{
  const AndroidPage({super.key});

  static List<String> categories = ["Recommended", "All", "System"];
  final String _selectedCategory = "Recommended";
  static List<String> state = ["All packages", "Enabled", "Disabled", "Uninstalled"];
  final String _selectedState = "All packages";
  static List<String> brands = ["All packages", "AOSP", "Google", "Meta", "Microsoft", "Samsung", "Xiaomi"];
  final String _selectedBrands = "All packages";

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
        body: Column(
          children: [
            Center(
              child: Row(children:
              [
                DropdownMenu(
                    dropdownMenuEntries: categories.map((i) => DropdownMenuEntry(value: i, label: i)).toList(),
                initialSelection: _selectedCategory),
                DropdownMenu(
                    dropdownMenuEntries: state.map((i) => DropdownMenuEntry(value: i, label: i)).toList(),
                    initialSelection: _selectedState),
                DropdownMenu(
                    dropdownMenuEntries: brands.map((i) => DropdownMenuEntry(value: i, label: i)).toList(),
                    initialSelection: _selectedBrands)
              ],
              ),
            ),
            //Center(child: ListView())
          ],
        )
    );
  }
}


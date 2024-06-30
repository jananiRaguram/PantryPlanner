import 'package:flutter/material.dart';

class FilterPill extends StatefulWidget {
  final String label;
  final Function(String, bool) onSelectionChanged;

  const FilterPill({
    Key? key,
    required this.label,
    required this.onSelectionChanged,
  }) : super(key: key);

  @override
  FilterPillState createState() => FilterPillState();
}

class FilterPillState extends State<FilterPill> {
  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(
        widget.label,
        style: const TextStyle(fontSize: 14.0),
      ),
      selected: _isSelected,
      onSelected: (isSelected) {
        setState(() {
          _isSelected = isSelected;
          widget.onSelectionChanged(widget.label, isSelected);
        });
      },
      selectedColor: const Color.fromARGB(255, 223, 196, 242),
      shape: const StadiumBorder(),
    );
  }
}

class RecipeFilterPills extends StatefulWidget {
  final List<String> categories;
  final Function(String) onSelect;

  const RecipeFilterPills(
      {Key? key, required this.categories, required this.onSelect})
      : super(key: key);

  @override
  _RecipeFilterPillsState createState() => _RecipeFilterPillsState();
}

class _RecipeFilterPillsState extends State<RecipeFilterPills> {
  String? selectedCategory;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: widget.categories
            .map(
              (category) => GestureDetector(
                onTap: () {
                  setState(() {
                    selectedCategory = category;
                  });
                  widget.onSelect(selectedCategory!);
                },
                child: Container(
                  margin: EdgeInsets.all(8),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: selectedCategory == category
                        ? const Color.fromARGB(255, 223, 196, 242)
                        : Colors.white,
                    border: Border.all(
                      color: Colors.black, // Border color
                      width: 1, // Border width
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      color: Colors.black, // Text color
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

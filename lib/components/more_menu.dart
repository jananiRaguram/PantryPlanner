import 'package:flutter/material.dart';
import 'package:pantry_planner/pages/groceries.dart';
import '../../globals.dart' as globals;
import 'package:pantry_planner/provider/groceryList_provider.dart';
import 'package:provider/provider.dart';

class MoreMenu extends StatefulWidget {
  final List<String> ingredients;
  const MoreMenu({Key? key, required this.ingredients}) : super(key: key);

  @override
  State<MoreMenu> createState() => _MoreMenuState();
}

class _MoreMenuState extends State<MoreMenu> {
  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      builder:
          (BuildContext context, MenuController controller, Widget? child) {
        return IconButton(
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          icon: const Icon(Icons.more_horiz),
        );
      },
      menuChildren: List.generate(
        1,
        (index) => MenuItemButton(
          onPressed: () {
            if (index == 0) {
              // add to groceries list if the first item is pressed
              Provider.of<GroceryListProvider>(context, listen: false)
                  .addItemToGroceryList(widget.ingredients);

              // Show a snackbar to provide feedback to the user
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Ingredients added to your grocery list!'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          child: Row(
            children: [Icon(Icons.add), Text('Add to grocery list')],
          ),
        ),
      ),
    );
  }
}

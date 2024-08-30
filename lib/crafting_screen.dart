// crafting_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'crafting.dart';
import 'resource.dart';

class CraftingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Crafting')),
      body: Consumer2<CraftingManager, ResourceManager>(
        builder: (context, craftingManager, resourceManager, child) {
          return ListView.builder(
            itemCount: craftingManager.recipes.length,
            itemBuilder: (context, index) {
              final recipe = craftingManager.recipes[index];
              return CraftingRecipeCard(recipe: recipe);
            },
          );
        },
      ),
    );
  }
}

class CraftingRecipeCard extends StatelessWidget {
  final CraftedItem recipe;

  CraftingRecipeCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final craftingManager = context.watch<CraftingManager>();
    final resourceManager = context.watch<ResourceManager>();

    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(recipe.name, style: Theme.of(context).textTheme.titleLarge),
            Text(recipe.description),
            SizedBox(height: 8),
            Text('Required Resources:'),
            ...recipe.resourceCost.entries.map((entry) => Text(
              '${entry.key}: ${entry.value} (Available: ${resourceManager.getResourceQuantity(entry.key)})'
            )),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: craftingManager.canCraft(recipe)
                ? () => craftingManager.craft(recipe)
                : null,
              child: Text('Craft'),
            ),
          ],
        ),
      ),
    );
  }
}
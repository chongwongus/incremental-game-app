import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'talent_system.dart';

class TalentTreeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Talent Tree')),
      body: TalentTreeView(),
    );
  }
}

class TalentTreeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final playerTalents = Provider.of<PlayerTalents>(context);
    final talentTree = TalentTree();

    return InteractiveViewer(
      boundaryMargin: EdgeInsets.all(double.infinity),
      minScale: 0.5,
      maxScale: 4.0,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            width: constraints.maxWidth * 2,
            height: constraints.maxHeight * 2,
            child: CustomMultiChildLayout(
              delegate: TalentTreeLayoutDelegate(talentTree.talents),
              children: talentTree.talents.map((talent) {
                return LayoutId(
                  id: talent.id,
                  child: TalentNode(
                    talent: talent,
                    isUnlocked: playerTalents.isTalentUnlocked(talent.id),
                    canUnlock: playerTalents.canUnlockTalent(talent.id),
                    onTap: () => playerTalents.unlockTalent(talent.id),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}

class TalentTreeLayoutDelegate extends MultiChildLayoutDelegate {
  final List<Talent> talents;

  TalentTreeLayoutDelegate(this.talents);

  @override
  void performLayout(Size size) {
    final double nodeSize = 80.0;
    final double horizontalSpacing = 120.0;
    final double verticalSpacing = 100.0;

    Map<TalentCategory, List<Talent>> categorizedTalents = {};
    for (var talent in talents) {
      categorizedTalents.putIfAbsent(talent.category, () => []).add(talent);
    }

    double yOffset = 50.0;
    categorizedTalents.forEach((category, talents) {
      double xOffset = 50.0;
      for (var talent in talents) {
        layoutChild(talent.id, BoxConstraints.loose(Size(nodeSize, nodeSize)));
        positionChild(talent.id, Offset(xOffset, yOffset));
        xOffset += horizontalSpacing;
      }
      yOffset += verticalSpacing;
    });
  }

  @override
  bool shouldRelayout(TalentTreeLayoutDelegate oldDelegate) {
    return talents != oldDelegate.talents;
  }
}

class TalentNode extends StatelessWidget {
  final Talent talent;
  final bool isUnlocked;
  final bool canUnlock;
  final VoidCallback onTap;

  TalentNode({
    required this.talent,
    required this.isUnlocked,
    required this.canUnlock,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: canUnlock ? onTap : () => _showTalentInfo(context),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isUnlocked ? Colors.green : (canUnlock ? Colors.blue : Colors.grey),
        ),
        child: Center(
          child: Text(
            talent.name,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  void _showTalentInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(talent.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(talent.description),
              SizedBox(height: 8),
              Text('Category: ${talent.category.toString().split('.').last}'),
              Text('Required Points: ${talent.requiredPoints}'),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
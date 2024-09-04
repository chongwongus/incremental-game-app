import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'quests.dart';

class QuestSelectionScreen extends StatelessWidget {
  final QuestManager questManager;

  QuestSelectionScreen({required this.questManager});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Available Quests'),
      ),
      body: ListView.builder(
        itemCount: questManager.availableQuests.length,
        itemBuilder: (context, index) {
          final quest = questManager.availableQuests[index];
          return QuestCard(quest: quest, questManager: questManager);
        },
      ),
    );
  }
}

class QuestCard extends StatelessWidget {
  final Quest quest;
  final QuestManager questManager;

  QuestCard({required this.quest, required this.questManager});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    quest.title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                if (quest.isEpicQuest) Icon(Icons.star, color: Colors.yellow),
              ],
            ),
            SizedBox(height: 8),
            Text(quest.description),
            SizedBox(height: 8),
            Text('Skill: ${quest.relatedSkill}'),
            Text('Duration: ${quest.duration.inDays} days'),
            Text('XP Reward: ${quest.expReward}'),
            if (quest.isEpicQuest) ...[
              Text('Talent Points: ${quest.talentPointsReward}'),
              Text('Skill Unlocks: ${quest.skillUnlocks.join(", ")}'),
            ],
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                questManager.startQuest(quest.id);
                Navigator.pop(context);
              },
              child: Text('Start Quest'),
            ),
          ],
        ),
      ),
    );
  }
}

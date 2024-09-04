import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'quests.dart';

class QuestProgressWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final questManager = Provider.of<QuestManager>(context);

    if (questManager.activeQuests.isEmpty) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(Icons.quiz, size: 48, color: Colors.grey),
              SizedBox(height: 16),
              Text('No active quests. Start a new adventure!'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // TODO: Implement navigation to quest selection screen
                },
                child: Text('Find a Quest'),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Active Quests',
                style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 16),
            ...questManager.activeQuests
                .map((quest) => QuestProgressItem(quest: quest)),
          ],
        ),
      ),
    );
  }
}

class QuestProgressItem extends StatelessWidget {
  final Quest quest;

  QuestProgressItem({required this.quest});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(quest.title,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: quest.isEpicQuest ? Colors.purple : null,
                            )),
                    Text(quest.description,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              if (quest.isEpicQuest) Icon(Icons.star, color: Colors.yellow),
            ],
          ),
          SizedBox(height: 8),
          LinearProgressIndicator(
            value: quest.progress,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              quest.isEpicQuest
                  ? Colors.purple
                  : Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${(quest.progress * 100).toStringAsFixed(1)}% complete'),
              Text(
                  '${quest.checkInsCompleted}/${quest.checkInsRequired} check-ins'),
            ],
          ),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: quest.canCheckIn()
                ? () => Provider.of<QuestManager>(context, listen: false)
                    .checkInQuest(quest.id)
                : null,
            child: Text('Check In'),
            style: ElevatedButton.styleFrom(
              backgroundColor: quest.isEpicQuest ? Colors.purple : null,
            ),
          ),
        ],
      ),
    );
  }
}

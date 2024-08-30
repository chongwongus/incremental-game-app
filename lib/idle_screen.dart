import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'idle_manager.dart';
import 'character.dart';

class IdleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Idle Actions')),
      body: Consumer<IdleManager>(
        builder: (context, idleManager, child) {
          return ListView(
            children: [
              IdleActionCard(
                skillName: 'Woodcutting',
                onToggle: () => _toggleIdleAction(context, 'Woodcutting'),
                isActive: idleManager.activeSkill == 'Woodcutting',
                progress: idleManager.activeSkill == 'Woodcutting' ? idleManager.progress : 0.0,
              ),
              IdleActionCard(
                skillName: 'Fishing',
                onToggle: () => _toggleIdleAction(context, 'Fishing'),
                isActive: idleManager.activeSkill == 'Fishing',
                progress: idleManager.activeSkill == 'Fishing' ? idleManager.progress : 0.0,
              ),
              IdleActionCard(
                skillName: 'Mining',
                onToggle: () => _toggleIdleAction(context, 'Mining'),
                isActive: idleManager.activeSkill == 'Mining',
                progress: idleManager.activeSkill == 'Mining' ? idleManager.progress : 0.0,
              ),
            ],
          );
        },
      ),
    );
  }

  void _toggleIdleAction(BuildContext context, String skillName) {
    final idleManager = context.read<IdleManager>();
    if (idleManager.activeSkill == skillName) {
      idleManager.stopIdleAction();
    } else {
      idleManager.startIdleAction(skillName);
    }
  }
}

class IdleActionCard extends StatelessWidget {
  final String skillName;
  final VoidCallback onToggle;
  final bool isActive;
  final double progress;

  IdleActionCard({
    required this.skillName,
    required this.onToggle,
    required this.isActive,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(skillName, style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 8.0),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                isActive ? Colors.green : Colors.grey,
              ),
            ),
            SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: onToggle,
              child: Text(isActive ? 'Stop' : 'Start'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isActive ? Colors.red : Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
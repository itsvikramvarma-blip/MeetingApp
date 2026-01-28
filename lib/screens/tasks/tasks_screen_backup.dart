import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/meeting_service.dart';
import '../../models/models.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header section with golden theme
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Color(0xFFD4AF37),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
          ),
          child: const Row(
            children: [
              Text(
                'Tasks',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Consumer<MeetingService>(
            builder: (context, meetingService, child) {
              final tasks = meetingService.tasks;
              
              if (tasks.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.task_outlined, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No tasks found',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  final isCompleted = task.status == TaskStatus.completed;
              
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isCompleted ? Colors.green : Colors.blue,
                        child: Icon(
                          isCompleted ? Icons.check : Icons.task,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        task.title,
                        style: TextStyle(
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (task.description?.isNotEmpty == true)
                            Text(task.description!),
                          Text('Assigned to: ${task.assignedTo}'),
                        ],
                      ),
                      trailing: Text(
                        isCompleted ? 'Completed' : 'In Progress',
                        style: TextStyle(
                          color: isCompleted ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
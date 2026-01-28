import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../services/meeting_service_remote.dart';
import '../../models/models.dart';

class MeetingsScreen extends StatefulWidget {
  const MeetingsScreen({super.key});

  @override
  State<MeetingsScreen> createState() => _MeetingsScreenState();
}

class _MeetingsScreenState extends State<MeetingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header section with title and add button
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Color(0xFFD4AF37),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'My Meetings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: () {
                  context.go('/create-meeting');
                },
              ),
            ],
          ),
        ),
        // Meetings list
        Expanded(
          child: Consumer<MeetingServiceRemote>(
            builder: (context, meetingService, child) {
              final allMeetings = meetingService.meetings;
              
              if (allMeetings.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.video_call_outlined,
                        size: 80,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No meetings scheduled',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Tap the + button to create your first meeting',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: allMeetings.length,
                itemBuilder: (context, index) {
                  final meeting = allMeetings[index];
                  final isUpcoming = meeting.startTime.isAfter(DateTime.now());
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: isUpcoming ? const Color(0xFFD4AF37) : Colors.grey,
                        child: Icon(
                          isUpcoming ? Icons.video_call : Icons.history,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        meeting.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            meeting.description ?? 'No description',
                            style: const TextStyle(fontSize: 14),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatDateTime(meeting.startTime),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.group,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${meeting.participants.length} participants',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(meeting.status),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _getStatusText(meeting.status),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          switch (value) {
                            case 'edit':
                              context.go('/edit-meeting/${meeting.id}');
                              break;
                            case 'complete':
                              _markMeetingCompleted(meeting.id);
                              break;
                            case 'minutes':
                              context.go('/meeting-minutes/${meeting.id}');
                              break;
                          }
                        },
                        itemBuilder: (context) {
                          List<PopupMenuEntry<String>> items = [];
                          
                          // Edit option (always available)
                          items.add(const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20),
                                SizedBox(width: 8),
                                Text('Edit Meeting'),
                              ],
                            ),
                          ));
                          
                          // Complete option (only for scheduled meetings)
                          if (meeting.status == MeetingStatus.scheduled) {
                            items.add(const PopupMenuItem(
                              value: 'complete',
                              child: Row(
                                children: [
                                  Icon(Icons.check_circle, size: 20),
                                  SizedBox(width: 8),
                                  Text('Mark Complete'),
                                ],
                              ),
                            ));
                          }
                          
                          // Minutes option (only for completed meetings)
                          if (meeting.status == MeetingStatus.completed) {
                            items.add(const PopupMenuItem(
                              value: 'minutes',
                              child: Row(
                                children: [
                                  Icon(Icons.description, size: 20),
                                  SizedBox(width: 8),
                                  Text('Meeting Minutes'),
                                ],
                              ),
                            ));
                          }
                          
                          return items;
                        },
                      ),
                      onTap: () {
                        context.go('/edit-meeting/${meeting.id}');
                      },
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

  void _markMeetingCompleted(String meetingId) async {
    try {
      final meetingService = Provider.of<MeetingServiceRemote>(context, listen: false);
      await meetingService.markMeetingCompleted(meetingId);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Meeting marked as completed! You can now create meeting minutes.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error completing meeting: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Color _getStatusColor(MeetingStatus status) {
    switch (status) {
      case MeetingStatus.completed:
        return Colors.green;
      case MeetingStatus.inProgress:
        return Colors.blue;
      case MeetingStatus.scheduled:
        return const Color(0xFFD4AF37);
      case MeetingStatus.cancelled:
        return Colors.red;
      case MeetingStatus.pending:
        return Colors.grey;
    }
  }

  String _getStatusText(MeetingStatus status) {
    switch (status) {
      case MeetingStatus.completed:
        return 'COMPLETED';
      case MeetingStatus.inProgress:
        return 'IN PROGRESS';
      case MeetingStatus.scheduled:
        return 'SCHEDULED';
      case MeetingStatus.cancelled:
        return 'CANCELLED';
      case MeetingStatus.pending:
        return 'PENDING';
    }
  }
}
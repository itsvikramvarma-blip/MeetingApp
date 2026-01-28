import 'package:flutter/foundation.dart';
import '../models/models.dart';

class MeetingService extends ChangeNotifier {
  final List<Meeting> _meetings = [];
  final List<Task> _tasks = [];
  final List<MeetingRoom> _meetingRooms = [];
  final List<NotificationModel> _notifications = [];

  // Getters
  List<Meeting> get meetings => List.unmodifiable(_meetings);
  List<Task> get tasks => List.unmodifiable(_tasks);
  List<MeetingRoom> get meetingRooms => List.unmodifiable(_meetingRooms);
  List<NotificationModel> get notifications => List.unmodifiable(_notifications);

  // Initialize with sample data
  MeetingService() {
    _initializeSampleData();
  }

  void _initializeSampleData() {
    // Sample meeting rooms
    _meetingRooms.addAll([
      MeetingRoom(
        id: '1',
        name: 'Conference Room A',
        location: 'Floor 1, Building A',
        capacity: 12,
        equipment: ['Projector', 'Whiteboard', 'Video Conference'],
      ),
      MeetingRoom(
        id: '2',
        name: 'Meeting Room B',
        location: 'Floor 2, Building A',
        capacity: 6,
        equipment: ['Smart TV', 'Whiteboard'],
      ),
      MeetingRoom(
        id: '3',
        name: 'Executive Boardroom',
        location: 'Floor 3, Building A',
        capacity: 20,
        equipment: ['Projector', 'Video Conference', 'Audio System'],
      ),
    ]);

    // Sample meetings
    final now = DateTime.now();
    _meetings.addAll([
      Meeting(
        id: '1',
        title: 'Team Standup',
        description: 'Daily standup meeting to discuss progress and blockers',
        startTime: DateTime(now.year, now.month, now.day, 9, 0),
        endTime: DateTime(now.year, now.month, now.day, 9, 30),
        organizer: 'john.doe@company.com',
        participants: [
          'john.doe@company.com',
          'jane.smith@company.com',
          'mike.wilson@company.com',
          'sarah.brown@company.com',
          'alex.jones@company.com',
        ],
        meetingRoom: 'Meeting Room B',
        status: MeetingStatus.scheduled,
        agenda: [
          'Review yesterday\'s progress',
          'Discuss today\'s tasks',
          'Identify any blockers',
        ],
      ),
      Meeting(
        id: '2',
        title: 'Client Review Meeting',
        description: 'Quarterly business review with key client',
        startTime: DateTime(now.year, now.month, now.day, 14, 0),
        endTime: DateTime(now.year, now.month, now.day, 15, 30),
        organizer: 'jane.smith@company.com',
        participants: [
          'jane.smith@company.com',
          'client@customer.com',
          'manager@company.com',
          'sales@company.com',
        ],
        meetingRoom: 'Executive Boardroom',
        status: MeetingStatus.completed,
        agenda: [
          'Project status update',
          'Budget review',
          'Next quarter planning',
          'Q&A session',
        ],
        meetingMinutes: MeetingMinutes(
          meetingId: '2',
          createdAt: DateTime(now.year, now.month, now.day),
          lastUpdatedAt: DateTime(now.year, now.month, now.day),
          createdBy: 'jane.smith@company.com',
          discussionPoints: [
            'Reviewed Q3 project deliverables and milestones',
            'Client expressed satisfaction with current progress',
            'Discussed budget utilization and remaining allocation',
            'Identified opportunities for Q4 expansion',
            'Addressed client concerns about timeline delays',
          ],
          decisions: [
            Decision(
              id: '1',
              description: 'Approve additional budget for Q4 feature development',
              createdAt: DateTime(now.year, now.month, now.day, 14, 30),
              stakeholders: ['client@customer.com', 'manager@company.com'],
              details: 'Additional 25% budget approved for advanced features',
            ),
            Decision(
              id: '2',
              description: 'Extend project timeline by 2 weeks for additional testing',
              createdAt: DateTime(now.year, now.month, now.day, 14, 45),
              stakeholders: ['manager@company.com', 'jane.smith@company.com'],
              details: 'Extra testing phase to ensure quality standards',
            ),
            Decision(
              id: '3',
              description: 'Implement weekly progress review meetings',
              createdAt: DateTime(now.year, now.month, now.day, 15, 0),
              stakeholders: ['jane.smith@company.com', 'client@customer.com'],
            ),
          ],
          actionItems: [
            ActionItem(
              id: '1',
              description: 'Prepare detailed Q4 project roadmap',
              assignedTo: 'jane.smith@company.com',
              dueDate: DateTime(now.year, now.month, now.day + 7),
              priority: ActionItemPriority.high,
              status: ActionItemStatus.pending,
              createdAt: DateTime(now.year, now.month, now.day),
              details: 'Include feature specifications, timelines, and resource requirements',
            ),
            ActionItem(
              id: '2',
              description: 'Schedule weekly review meetings with client',
              assignedTo: 'manager@company.com',
              dueDate: DateTime(now.year, now.month, now.day + 3),
              priority: ActionItemPriority.medium,
              status: ActionItemStatus.pending,
              createdAt: DateTime(now.year, now.month, now.day),
            ),
            ActionItem(
              id: '3',
              description: 'Finalize budget proposal for additional features',
              assignedTo: 'sales@company.com',
              dueDate: DateTime(now.year, now.month, now.day + 5),
              priority: ActionItemPriority.high,
              status: ActionItemStatus.pending,
              createdAt: DateTime(now.year, now.month, now.day),
              details: 'Include detailed cost breakdown and ROI analysis',
            ),
          ],
          generalNotes: 'Excellent meeting with positive client feedback. All stakeholders aligned on project direction and next steps. Client is eager to move forward with proposed enhancements.',
        ),
      ),
      Meeting(
        id: '3',
        title: 'Project Planning Session',
        description: 'Planning session for the new mobile app project',
        startTime: DateTime(now.year, now.month, now.day, 16, 30),
        endTime: DateTime(now.year, now.month, now.day, 18, 0),
        organizer: 'mike.wilson@company.com',
        participants: [
          'mike.wilson@company.com',
          'dev1@company.com',
          'dev2@company.com',
          'designer@company.com',
          'pm@company.com',
        ],
        meetingRoom: 'Conference Room A',
        status: MeetingStatus.scheduled,
        agenda: [
          'Requirements review',
          'Technical architecture discussion',
          'Timeline estimation',
          'Resource allocation',
        ],
      ),
    ]);

    // Sample tasks
    _tasks.addAll([
      Task(
        id: '1',
        title: 'Update project documentation',
        description: 'Update the technical documentation based on recent changes',
        dueDate: DateTime(now.year, now.month, now.day + 2),
        priority: TaskPriority.medium,
        status: TaskStatus.pending,
        assignedTo: 'john.doe@company.com',
        assignedBy: 'jane.smith@company.com',
        meetingId: '1',
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      Task(
        id: '2',
        title: 'Prepare client presentation',
        description: 'Create slides for the quarterly review meeting',
        dueDate: DateTime(now.year, now.month, now.day),
        priority: TaskPriority.high,
        status: TaskStatus.inProgress,
        assignedTo: 'jane.smith@company.com',
        assignedBy: 'manager@company.com',
        meetingId: '2',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      Task(
        id: '3',
        title: 'Setup development environment',
        description: 'Configure the development environment for the new project',
        dueDate: DateTime(now.year, now.month, now.day + 1),
        priority: TaskPriority.urgent,
        status: TaskStatus.pending,
        assignedTo: 'mike.wilson@company.com',
        assignedBy: 'pm@company.com',
        meetingId: '3',
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
    ]);

    // Sample notifications
    _notifications.addAll([
      NotificationModel(
        id: '1',
        title: 'Meeting Starting Soon',
        body: 'Team Standup starts in 15 minutes',
        type: NotificationType.meetingReminder,
        createdAt: now.subtract(const Duration(minutes: 5)),
        meetingId: '1',
      ),
      NotificationModel(
        id: '2',
        title: 'New Task Assigned',
        body: 'You have been assigned: Setup development environment',
        type: NotificationType.taskAssigned,
        createdAt: now.subtract(const Duration(hours: 1)),
        taskId: '3',
      ),
      NotificationModel(
        id: '3',
        title: 'Meeting Room Changed',
        body: 'Client Review Meeting moved to Executive Boardroom',
        type: NotificationType.meetingUpdated,
        createdAt: now.subtract(const Duration(hours: 2)),
        meetingId: '2',
      ),
    ]);
  }

  // Meeting methods
  List<Meeting> getTodaysMeetings() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return _meetings.where((meeting) {
      return meeting.startTime.isAfter(today) &&
             meeting.startTime.isBefore(tomorrow);
    }).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  List<Meeting> getUpcomingMeetings({int days = 7}) {
    final now = DateTime.now();
    final future = now.add(Duration(days: days));

    return _meetings.where((meeting) {
      return meeting.startTime.isAfter(now) &&
             meeting.startTime.isBefore(future) &&
             meeting.status == MeetingStatus.scheduled;
    }).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  Meeting? getMeetingById(String id) {
    try {
      return _meetings.firstWhere((meeting) => meeting.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> createMeeting(Meeting meeting) async {
    _meetings.add(meeting);
    notifyListeners();
    
    // Create notification for participants
    _createMeetingNotification(meeting, NotificationType.meetingInvitation);
  }

  Future<void> updateMeeting(Meeting updatedMeeting) async {
    final index = _meetings.indexWhere((m) => m.id == updatedMeeting.id);
    if (index != -1) {
      _meetings[index] = updatedMeeting;
      notifyListeners();
      
      // Create notification for update
      _createMeetingNotification(updatedMeeting, NotificationType.meetingUpdated);
    }
  }

  Future<void> cancelMeeting(String meetingId, String reason) async {
    final index = _meetings.indexWhere((m) => m.id == meetingId);
    if (index != -1) {
      final meeting = _meetings[index];
      final cancelledMeeting = Meeting(
        id: meeting.id,
        title: meeting.title,
        description: meeting.description,
        startTime: meeting.startTime,
        endTime: meeting.endTime,
        organizer: meeting.organizer,
        participants: meeting.participants,
        meetingRoom: meeting.meetingRoom,
        meetingLink: meeting.meetingLink,
        status: MeetingStatus.cancelled,
        agenda: meeting.agenda,
        attachments: meeting.attachments,
        notes: '${meeting.notes ?? ''}\nCancellation reason: $reason',
        isRecurring: meeting.isRecurring,
        recurrencePattern: meeting.recurrencePattern,
      );
      
      _meetings[index] = cancelledMeeting;
      notifyListeners();
      
      // Create cancellation notification
      _createMeetingNotification(cancelledMeeting, NotificationType.meetingCancelled);
    }
  }

  // Task methods
  List<Task> getTasksForUser(String userEmail) {
    return _tasks.where((task) => task.assignedTo == userEmail).toList()
      ..sort((a, b) => (a.dueDate ?? DateTime.now()).compareTo(b.dueDate ?? DateTime.now()));
  }

  List<Task> getPendingTasks() {
    return _tasks.where((task) => task.status == TaskStatus.pending).toList();
  }

  List<Task> getTasksForMeeting(String meetingId) {
    return _tasks.where((task) => task.meetingId == meetingId).toList();
  }

  Future<void> createTask(Task task) async {
    _tasks.add(task);
    notifyListeners();
    
    // Create notification for task assignment
    _notifications.add(NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'New Task Assigned',
      body: 'You have been assigned: ${task.title}',
      type: NotificationType.taskAssigned,
      createdAt: DateTime.now(),
      taskId: task.id,
    ));
  }

  Future<void> updateTaskStatus(String taskId, TaskStatus status) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final task = _tasks[index];
      final updatedTask = Task(
        id: task.id,
        title: task.title,
        description: task.description,
        dueDate: task.dueDate,
        priority: task.priority,
        status: status,
        assignedTo: task.assignedTo,
        assignedBy: task.assignedBy,
        meetingId: task.meetingId,
        attachments: task.attachments,
        createdAt: task.createdAt,
        completedAt: status == TaskStatus.completed ? DateTime.now() : null,
      );
      
      _tasks[index] = updatedTask;
      notifyListeners();
      
      if (status == TaskStatus.completed) {
        _notifications.add(NotificationModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: 'Task Completed',
          body: 'Task completed: ${task.title}',
          type: NotificationType.taskCompleted,
          createdAt: DateTime.now(),
          taskId: task.id,
        ));
      }
    }
  }

  // Notification methods
  List<NotificationModel> getUnreadNotifications() {
    return _notifications.where((n) => !n.isRead).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      final notification = _notifications[index];
      final updatedNotification = NotificationModel(
        id: notification.id,
        title: notification.title,
        body: notification.body,
        type: notification.type,
        createdAt: notification.createdAt,
        isRead: true,
        meetingId: notification.meetingId,
        taskId: notification.taskId,
        data: notification.data,
      );
      
      _notifications[index] = updatedNotification;
      notifyListeners();
    }
  }

  // Meeting room methods
  List<MeetingRoom> getAvailableRooms(DateTime startTime, DateTime endTime) {
    return _meetingRooms.where((room) {
      // Check if room is available during the requested time
      final conflictingMeetings = _meetings.where((meeting) {
        return meeting.meetingRoom == room.name &&
               meeting.status == MeetingStatus.scheduled &&
               !(meeting.endTime.isBefore(startTime) || 
                 meeting.startTime.isAfter(endTime));
      });
      
      return room.isAvailable && conflictingMeetings.isEmpty;
    }).toList();
  }

  // Helper methods
  void _createMeetingNotification(Meeting meeting, NotificationType type) {
    String title = '';
    String body = '';
    
    switch (type) {
      case NotificationType.meetingInvitation:
        title = 'Meeting Invitation';
        body = 'You\'re invited to: ${meeting.title}';
        break;
      case NotificationType.meetingUpdated:
        title = 'Meeting Updated';
        body = 'Meeting updated: ${meeting.title}';
        break;
      case NotificationType.meetingCancelled:
        title = 'Meeting Cancelled';
        body = 'Meeting cancelled: ${meeting.title}';
        break;
      case NotificationType.meetingReminder:
        title = 'Meeting Reminder';
        body = 'Meeting starts in 15 minutes: ${meeting.title}';
        break;
      default:
        return;
    }
    
    _notifications.add(NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      type: type,
      createdAt: DateTime.now(),
      meetingId: meeting.id,
    ));
  }

  // Statistics methods
  int getMeetingCountForPeriod(DateTime start, DateTime end) {
    return _meetings.where((meeting) {
      return meeting.startTime.isAfter(start) &&
             meeting.startTime.isBefore(end);
    }).length;
  }

  int getCompletedTasksCount() {
    return _tasks.where((task) => task.status == TaskStatus.completed).length;
  }

  int getPendingTasksCount() {
    return _tasks.where((task) => task.status == TaskStatus.pending).length;
  }

  // Meeting Minutes methods
  Future<void> saveMeetingMinutes(String meetingId, MeetingMinutes meetingMinutes) async {
    final index = _meetings.indexWhere((m) => m.id == meetingId);
    if (index != -1) {
      final meeting = _meetings[index];
      final updatedMeeting = Meeting(
        id: meeting.id,
        title: meeting.title,
        description: meeting.description,
        startTime: meeting.startTime,
        endTime: meeting.endTime,
        organizer: meeting.organizer,
        participants: meeting.participants,
        meetingRoom: meeting.meetingRoom,
        meetingLink: meeting.meetingLink,
        status: meeting.status,
        agenda: meeting.agenda,
        attachments: meeting.attachments,
        notes: meeting.notes,
        isRecurring: meeting.isRecurring,
        recurrencePattern: meeting.recurrencePattern,
        meetingMinutes: meetingMinutes,
      );
      
      _meetings[index] = updatedMeeting;
      notifyListeners();
      
      // Create notification for meeting minutes completion
      _createMeetingNotification(updatedMeeting, NotificationType.general);
    }
  }

  MeetingMinutes? getMeetingMinutes(String meetingId) {
    final meeting = _meetings.firstWhere(
      (m) => m.id == meetingId,
      orElse: () => throw Exception('Meeting not found'),
    );
    return meeting.meetingMinutes;
  }

  Future<void> markMeetingCompleted(String meetingId) async {
    final index = _meetings.indexWhere((m) => m.id == meetingId);
    if (index != -1) {
      final meeting = _meetings[index];
      final completedMeeting = Meeting(
        id: meeting.id,
        title: meeting.title,
        description: meeting.description,
        startTime: meeting.startTime,
        endTime: meeting.endTime,
        organizer: meeting.organizer,
        participants: meeting.participants,
        meetingRoom: meeting.meetingRoom,
        meetingLink: meeting.meetingLink,
        status: MeetingStatus.completed,
        agenda: meeting.agenda,
        attachments: meeting.attachments,
        notes: meeting.notes,
        isRecurring: meeting.isRecurring,
        recurrencePattern: meeting.recurrencePattern,
        meetingMinutes: meeting.meetingMinutes,
      );
      
      _meetings[index] = completedMeeting;
      notifyListeners();
      
      // Create notification for meeting completion
      _createMeetingNotification(completedMeeting, NotificationType.general);
    }
  }

  List<ActionItem> getAllActionItems() {
    List<ActionItem> allActionItems = [];
    for (final meeting in _meetings) {
      if (meeting.meetingMinutes != null) {
        allActionItems.addAll(meeting.meetingMinutes!.actionItems);
      }
    }
    return allActionItems;
  }

  List<ActionItem> getActionItemsForUser(String userEmail) {
    return getAllActionItems()
        .where((actionItem) => actionItem.assignedTo == userEmail)
        .toList();
  }

  List<ActionItem> getPendingActionItems() {
    return getAllActionItems()
        .where((actionItem) => actionItem.status == ActionItemStatus.pending)
        .toList();
  }
}

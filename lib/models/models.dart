// User model is already defined in auth_service.dart
// Exporting it for use in other files
export '../services/auth_service.dart' show User, UserRole;

class Meeting {
  final String id;
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime endTime;
  final String organizer;
  final List<String> participants;
  final String? meetingRoom;
  final String? meetingLink;
  final MeetingStatus status;
  final List<String> agenda;
  final List<String> attachments;
  final String? notes;
  final bool isRecurring;
  final RecurrencePattern? recurrencePattern;
  final MeetingMinutes? meetingMinutes;

  Meeting({
    required this.id,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    required this.organizer,
    required this.participants,
    this.meetingRoom,
    this.meetingLink,
    required this.status,
    this.agenda = const [],
    this.attachments = const [],
    this.notes,
    this.isRecurring = false,
    this.recurrencePattern,
    this.meetingMinutes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'organizer': organizer,
      'participants': participants,
      'meetingRoom': meetingRoom,
      'meetingLink': meetingLink,
      'status': status.toString().split('.').last,
      'agenda': agenda,
      'attachments': attachments,
      'notes': notes,
      'isRecurring': isRecurring,
      'recurrencePattern': recurrencePattern?.toJson(),
      'meetingMinutes': meetingMinutes?.toJson(),
    };
  }

  factory Meeting.fromJson(Map<String, dynamic> json) {
    return Meeting(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      organizer: json['organizer'],
      participants: List<String>.from(json['participants']),
      meetingRoom: json['meetingRoom'],
      meetingLink: json['meetingLink'],
      status: MeetingStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      agenda: List<String>.from(json['agenda'] ?? []),
      attachments: List<String>.from(json['attachments'] ?? []),
      notes: json['notes'],
      isRecurring: json['isRecurring'] ?? false,
      recurrencePattern: json['recurrencePattern'] != null
          ? RecurrencePattern.fromJson(json['recurrencePattern'])
          : null,
      meetingMinutes: json['meetingMinutes'] != null
          ? MeetingMinutes.fromJson(json['meetingMinutes'])
          : null,
    );
  }
}

enum MeetingStatus {
  scheduled,
  inProgress,
  completed,
  cancelled,
  pending,
}

class RecurrencePattern {
  final RecurrenceType type;
  final int interval;
  final List<int>? daysOfWeek; // For weekly: 1=Monday, 7=Sunday
  final int? dayOfMonth; // For monthly
  final DateTime? endDate;
  final int? occurrences;

  RecurrencePattern({
    required this.type,
    this.interval = 1,
    this.daysOfWeek,
    this.dayOfMonth,
    this.endDate,
    this.occurrences,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString().split('.').last,
      'interval': interval,
      'daysOfWeek': daysOfWeek,
      'dayOfMonth': dayOfMonth,
      'endDate': endDate?.toIso8601String(),
      'occurrences': occurrences,
    };
  }

  factory RecurrencePattern.fromJson(Map<String, dynamic> json) {
    return RecurrencePattern(
      type: RecurrenceType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      interval: json['interval'] ?? 1,
      daysOfWeek: json['daysOfWeek'] != null 
          ? List<int>.from(json['daysOfWeek']) 
          : null,
      dayOfMonth: json['dayOfMonth'],
      endDate: json['endDate'] != null 
          ? DateTime.parse(json['endDate']) 
          : null,
      occurrences: json['occurrences'],
    );
  }
}

enum RecurrenceType {
  daily,
  weekly,
  monthly,
  yearly,
}

class Task {
  final String id;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final TaskPriority priority;
  final TaskStatus status;
  final String assignedTo;
  final String? assignedBy;
  final String? meetingId;
  final List<String> attachments;
  final DateTime createdAt;
  final DateTime? completedAt;

  Task({
    required this.id,
    required this.title,
    this.description,
    this.dueDate,
    required this.priority,
    required this.status,
    required this.assignedTo,
    this.assignedBy,
    this.meetingId,
    this.attachments = const [],
    required this.createdAt,
    this.completedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate?.toIso8601String(),
      'priority': priority.toString().split('.').last,
      'status': status.toString().split('.').last,
      'assignedTo': assignedTo,
      'assignedBy': assignedBy,
      'meetingId': meetingId,
      'attachments': attachments,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dueDate: json['dueDate'] != null 
          ? DateTime.parse(json['dueDate']) 
          : null,
      priority: TaskPriority.values.firstWhere(
        (e) => e.toString().split('.').last == json['priority'],
      ),
      status: TaskStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      assignedTo: json['assignedTo'],
      assignedBy: json['assignedBy'],
      meetingId: json['meetingId'],
      attachments: List<String>.from(json['attachments'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt']) 
          : null,
    );
  }
}

enum TaskPriority {
  low,
  medium,
  high,
  urgent,
}

enum TaskStatus {
  pending,
  inProgress,
  completed,
  cancelled,
}

class MeetingRoom {
  final String id;
  final String name;
  final String location;
  final int capacity;
  final List<String> equipment;
  final bool isAvailable;
  final String? description;

  MeetingRoom({
    required this.id,
    required this.name,
    required this.location,
    required this.capacity,
    this.equipment = const [],
    this.isAvailable = true,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'capacity': capacity,
      'equipment': equipment,
      'isAvailable': isAvailable,
      'description': description,
    };
  }

  factory MeetingRoom.fromJson(Map<String, dynamic> json) {
    return MeetingRoom(
      id: json['id'],
      name: json['name'],
      location: json['location'],
      capacity: json['capacity'],
      equipment: List<String>.from(json['equipment'] ?? []),
      isAvailable: json['isAvailable'] ?? true,
      description: json['description'],
    );
  }
}

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;
  final String? meetingId;
  final String? taskId;
  final Map<String, dynamic>? data;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.meetingId,
    this.taskId,
    this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'meetingId': meetingId,
      'taskId': taskId,
      'data': data,
    };
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      type: NotificationType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      createdAt: DateTime.parse(json['createdAt']),
      isRead: json['isRead'] ?? false,
      meetingId: json['meetingId'],
      taskId: json['taskId'],
      data: json['data'],
    );
  }
}

enum NotificationType {
  meetingReminder,
  meetingInvitation,
  meetingCancelled,
  meetingUpdated,
  taskAssigned,
  taskDue,
  taskCompleted,
  general,
}

// Meeting Minutes Models
class MeetingMinutes {
  final String meetingId;
  final List<String> discussionPoints;
  final List<Decision> decisions;
  final List<ActionItem> actionItems;
  final String? generalNotes;
  final String? attendeeNotes;
  final DateTime createdAt;
  final DateTime? lastUpdatedAt;
  final String createdBy;

  MeetingMinutes({
    required this.meetingId,
    this.discussionPoints = const [],
    this.decisions = const [],
    this.actionItems = const [],
    this.generalNotes,
    this.attendeeNotes,
    required this.createdAt,
    this.lastUpdatedAt,
    required this.createdBy,
  });

  Map<String, dynamic> toJson() {
    return {
      'meetingId': meetingId,
      'discussionPoints': discussionPoints,
      'decisions': decisions.map((d) => d.toJson()).toList(),
      'actionItems': actionItems.map((a) => a.toJson()).toList(),
      'generalNotes': generalNotes,
      'attendeeNotes': attendeeNotes,
      'createdAt': createdAt.toIso8601String(),
      'lastUpdatedAt': lastUpdatedAt?.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  factory MeetingMinutes.fromJson(Map<String, dynamic> json) {
    return MeetingMinutes(
      meetingId: json['meetingId'],
      discussionPoints: List<String>.from(json['discussionPoints'] ?? []),
      decisions: (json['decisions'] as List<dynamic>?)
          ?.map((d) => Decision.fromJson(d))
          .toList() ?? [],
      actionItems: (json['actionItems'] as List<dynamic>?)
          ?.map((a) => ActionItem.fromJson(a))
          .toList() ?? [],
      generalNotes: json['generalNotes'],
      attendeeNotes: json['attendeeNotes'],
      createdAt: DateTime.parse(json['createdAt']),
      lastUpdatedAt: json['lastUpdatedAt'] != null 
          ? DateTime.parse(json['lastUpdatedAt']) 
          : null,
      createdBy: json['createdBy'],
    );
  }
}

class Decision {
  final String id;
  final String description;
  final String? details;
  final List<String> stakeholders;
  final DateTime createdAt;

  Decision({
    required this.id,
    required this.description,
    this.details,
    this.stakeholders = const [],
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'details': details,
      'stakeholders': stakeholders,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Decision.fromJson(Map<String, dynamic> json) {
    return Decision(
      id: json['id'],
      description: json['description'],
      details: json['details'],
      stakeholders: List<String>.from(json['stakeholders'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class ActionItem {
  final String id;
  final String description;
  final String? details;
  final String assignedTo;
  final DateTime? dueDate;
  final ActionItemStatus status;
  final ActionItemPriority priority;
  final DateTime createdAt;

  ActionItem({
    required this.id,
    required this.description,
    this.details,
    required this.assignedTo,
    this.dueDate,
    this.status = ActionItemStatus.pending,
    this.priority = ActionItemPriority.medium,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'details': details,
      'assignedTo': assignedTo,
      'dueDate': dueDate?.toIso8601String(),
      'status': status.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ActionItem.fromJson(Map<String, dynamic> json) {
    return ActionItem(
      id: json['id'],
      description: json['description'],
      details: json['details'],
      assignedTo: json['assignedTo'],
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      status: ActionItemStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => ActionItemStatus.pending,
      ),
      priority: ActionItemPriority.values.firstWhere(
        (e) => e.toString().split('.').last == json['priority'],
        orElse: () => ActionItemPriority.medium,
      ),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

enum ActionItemStatus {
  pending,
  inProgress,
  completed,
  cancelled,
}

enum ActionItemPriority {
  low,
  medium,
  high,
  urgent,
}

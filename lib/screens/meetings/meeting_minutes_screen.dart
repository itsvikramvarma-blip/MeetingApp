import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/meeting_service_remote.dart';
import '../../models/models.dart';

class MeetingMinutesScreen extends StatefulWidget {
  final String meetingId;
  
  const MeetingMinutesScreen({super.key, required this.meetingId});

  @override
  State<MeetingMinutesScreen> createState() => _MeetingMinutesScreenState();
}

class _MeetingMinutesScreenState extends State<MeetingMinutesScreen> {
  Meeting? _meeting;
  MeetingMinutes? _meetingMinutes;
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;

  // Controllers for form fields
  final _discussionController = TextEditingController();
  final _decisionController = TextEditingController();
  final _decisionDetailsController = TextEditingController();
  final _actionItemController = TextEditingController();
  final _actionItemDetailsController = TextEditingController();
  final _assigneeController = TextEditingController();
  final _generalNotesController = TextEditingController();
  final _attendeeNotesController = TextEditingController();

  // Lists for dynamic content
  List<String> _discussionPoints = [];
  List<Decision> _decisions = [];
  List<ActionItem> _actionItems = [];
  DateTime? _selectedDueDate;
  ActionItemPriority _selectedPriority = ActionItemPriority.medium;

  @override
  void initState() {
    super.initState();
    _loadMeeting();
  }

  Future<void> _loadMeeting() async {
    final meetingService = Provider.of<MeetingServiceRemote>(context, listen: false);
    final meeting = meetingService.meetings.firstWhere(
      (m) => m.id == widget.meetingId,
      orElse: () => Meeting(
        id: widget.meetingId,
        title: 'Unknown',
        startTime: DateTime.now(),
        endTime: DateTime.now(),
        organizer: '',
        participants: [],
        status: MeetingStatus.scheduled,
      ),
    );
    
    if (meeting != null) {
      setState(() {
        _meeting = meeting;
        _meetingMinutes = meeting.meetingMinutes;
        
        if (_meetingMinutes != null) {
          _discussionPoints = List.from(_meetingMinutes!.discussionPoints);
          _decisions = List.from(_meetingMinutes!.decisions);
          _actionItems = List.from(_meetingMinutes!.actionItems);
          _generalNotesController.text = _meetingMinutes!.generalNotes ?? '';
          _attendeeNotesController.text = _meetingMinutes!.attendeeNotes ?? '';
        }
        
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_meeting == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Meeting Minutes'),
          backgroundColor: const Color(0xFFD4AF37),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('Meeting not found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meeting Minutes'),
        backgroundColor: const Color(0xFFD4AF37),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_meeting!.status == MeetingStatus.completed)
            IconButton(
              icon: Icon(_isEditing ? Icons.visibility : Icons.edit),
              onPressed: () => setState(() => _isEditing = !_isEditing),
              tooltip: _isEditing ? 'View Mode' : 'Edit Mode',
            ),
        ],
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meeting Info Header
                  _buildMeetingInfoCard(),
                  const SizedBox(height: 24),

                  // Status Check
                  if (_meeting!.status != MeetingStatus.completed)
                    _buildStatusWarning()
                  else ...[
                    // Discussion Points Section
                    _buildSectionTitle('Discussion Points', Icons.forum),
                    const SizedBox(height: 8),
                    _buildDiscussionPointsSection(),
                    const SizedBox(height: 24),

                    // Decisions Section
                    _buildSectionTitle('Decisions Made', Icons.gavel),
                    const SizedBox(height: 8),
                    _buildDecisionsSection(),
                    const SizedBox(height: 24),

                    // Action Items Section
                    _buildSectionTitle('Action Items', Icons.assignment),
                    const SizedBox(height: 8),
                    _buildActionItemsSection(),
                    const SizedBox(height: 24),

                    // Notes Sections
                    _buildSectionTitle('General Notes', Icons.notes),
                    const SizedBox(height: 8),
                    _buildGeneralNotesSection(),
                    const SizedBox(height: 24),

                    _buildSectionTitle('Attendee Notes', Icons.people),
                    const SizedBox(height: 8),
                    _buildAttendeeNotesSection(),
                    const SizedBox(height: 24),

                    // Save Button (only in edit mode)
                    if (_isEditing) _buildSaveButton(),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildMeetingInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _meeting!.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.schedule, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  _formatDateTime(_meeting!.startTime),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.people, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${_meeting!.participants.length} participants',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.info, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(_meeting!.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(_meeting!.status),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusWarning() {
    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Meeting not completed yet',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Minutes can only be created for completed meetings. Please complete the meeting first.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFD4AF37)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFFD4AF37),
          ),
        ),
      ],
    );
  }

  Widget _buildDiscussionPointsSection() {
    return Column(
      children: [
        if (_isEditing) ...[
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _discussionController,
                  decoration: const InputDecoration(
                    labelText: 'Add Discussion Point',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.chat),
                  ),
                  maxLines: 2,
                  onSubmitted: (_) => _addDiscussionPoint(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _addDiscussionPoint,
                icon: const Icon(Icons.add_circle),
                color: const Color(0xFFD4AF37),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        _buildDiscussionPointsList(),
      ],
    );
  }

  Widget _buildDiscussionPointsList() {
    if (_discussionPoints.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No discussion points recorded'),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _discussionPoints.length,
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            leading: Text('${index + 1}.'),
            title: Text(_discussionPoints[index]),
            trailing: _isEditing
                ? IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _removeDiscussionPoint(index),
                  )
                : null,
          ),
        );
      },
    );
  }

  Widget _buildDecisionsSection() {
    return Column(
      children: [
        if (_isEditing) ...[
          TextField(
            controller: _decisionController,
            decoration: const InputDecoration(
              labelText: 'Decision Description*',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.check_circle),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _decisionDetailsController,
            decoration: const InputDecoration(
              labelText: 'Additional Details (optional)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.description),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _addDecision,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Decision'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        _buildDecisionsList(),
      ],
    );
  }

  Widget _buildDecisionsList() {
    if (_decisions.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No decisions recorded'),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _decisions.length,
      itemBuilder: (context, index) {
        final decision = _decisions[index];
        return Card(
          child: ExpansionTile(
            leading: const Icon(Icons.gavel, color: Colors.green),
            title: Text(decision.description),
            subtitle: decision.details != null
                ? Text(decision.details!, style: const TextStyle(fontSize: 12))
                : null,
            trailing: _isEditing
                ? IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _removeDecision(index),
                  )
                : null,
            children: [
              if (decision.stakeholders.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Stakeholders:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        children: decision.stakeholders
                            .map((s) => Chip(label: Text(s), backgroundColor: Colors.blue.shade50))
                            .toList(),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionItemsSection() {
    return Column(
      children: [
        if (_isEditing) ...[
          TextField(
            controller: _actionItemController,
            decoration: const InputDecoration(
              labelText: 'Action Item Description*',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.task_alt),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _actionItemDetailsController,
            decoration: const InputDecoration(
              labelText: 'Additional Details (optional)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.description),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _assigneeController,
            decoration: const InputDecoration(
              labelText: 'Assigned To*',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
              hintText: 'Enter assignee email',
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: _selectDueDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.date_range, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(_selectedDueDate != null 
                            ? _formatDate(_selectedDueDate!) 
                            : 'Select due date (optional)'),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<ActionItemPriority>(
                  initialValue: _selectedPriority,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(),
                  ),
                  items: ActionItemPriority.values.map((priority) {
                    return DropdownMenuItem(
                      value: priority,
                      child: Text(_getPriorityText(priority)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedPriority = value);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _addActionItem,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Action Item'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        _buildActionItemsList(),
      ],
    );
  }

  Widget _buildActionItemsList() {
    if (_actionItems.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No action items recorded'),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _actionItems.length,
      itemBuilder: (context, index) {
        final actionItem = _actionItems[index];
        return Card(
          child: ExpansionTile(
            leading: Icon(
              Icons.assignment,
              color: _getPriorityColor(actionItem.priority),
            ),
            title: Text(actionItem.description),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Assigned to: ${actionItem.assignedTo}'),
                if (actionItem.dueDate != null)
                  Text('Due: ${_formatDate(actionItem.dueDate!)}'),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(actionItem.priority),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getPriorityText(actionItem.priority),
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getActionStatusColor(actionItem.status),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getActionStatusText(actionItem.status),
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: _isEditing
                ? IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _removeActionItem(index),
                  )
                : null,
            children: [
              if (actionItem.details != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Details:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(actionItem.details!),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGeneralNotesSection() {
    if (_isEditing) {
      return TextField(
        controller: _generalNotesController,
        decoration: const InputDecoration(
          labelText: 'General Meeting Notes',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.notes),
          alignLabelWithHint: true,
        ),
        maxLines: 5,
      );
    } else {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            _generalNotesController.text.isEmpty
                ? 'No general notes recorded'
                : _generalNotesController.text,
          ),
        ),
      );
    }
  }

  Widget _buildAttendeeNotesSection() {
    if (_isEditing) {
      return TextField(
        controller: _attendeeNotesController,
        decoration: const InputDecoration(
          labelText: 'Attendee Feedback & Notes',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.people),
          alignLabelWithHint: true,
        ),
        maxLines: 5,
      );
    } else {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            _attendeeNotesController.text.isEmpty
                ? 'No attendee notes recorded'
                : _attendeeNotesController.text,
          ),
        ),
      );
    }
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _saveMeetingMinutes,
        icon: const Icon(Icons.save),
        label: const Text(
          'Save Meeting Minutes',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD4AF37),
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  // Helper methods
  String _formatDateTime(DateTime dateTime) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    final month = months[dateTime.month - 1];
    final day = dateTime.day;
    final year = dateTime.year;
    
    final hour = dateTime.hour == 0 ? 12 : dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    
    return '$month $day, $year at $hour:$minute $period';
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Color _getStatusColor(MeetingStatus status) {
    switch (status) {
      case MeetingStatus.completed:
        return Colors.green;
      case MeetingStatus.inProgress:
        return Colors.blue;
      case MeetingStatus.scheduled:
        return Colors.orange;
      case MeetingStatus.cancelled:
        return Colors.red;
      case MeetingStatus.pending:
        return Colors.grey;
    }
  }

  String _getStatusText(MeetingStatus status) {
    switch (status) {
      case MeetingStatus.completed:
        return 'Completed';
      case MeetingStatus.inProgress:
        return 'In Progress';
      case MeetingStatus.scheduled:
        return 'Scheduled';
      case MeetingStatus.cancelled:
        return 'Cancelled';
      case MeetingStatus.pending:
        return 'Pending';
    }
  }

  Color _getPriorityColor(ActionItemPriority priority) {
    switch (priority) {
      case ActionItemPriority.urgent:
        return Colors.red;
      case ActionItemPriority.high:
        return Colors.orange;
      case ActionItemPriority.medium:
        return Colors.blue;
      case ActionItemPriority.low:
        return Colors.green;
    }
  }

  String _getPriorityText(ActionItemPriority priority) {
    switch (priority) {
      case ActionItemPriority.urgent:
        return 'Urgent';
      case ActionItemPriority.high:
        return 'High';
      case ActionItemPriority.medium:
        return 'Medium';
      case ActionItemPriority.low:
        return 'Low';
    }
  }

  Color _getActionStatusColor(ActionItemStatus status) {
    switch (status) {
      case ActionItemStatus.completed:
        return Colors.green;
      case ActionItemStatus.inProgress:
        return Colors.blue;
      case ActionItemStatus.pending:
        return Colors.orange;
      case ActionItemStatus.cancelled:
        return Colors.red;
    }
  }

  String _getActionStatusText(ActionItemStatus status) {
    switch (status) {
      case ActionItemStatus.completed:
        return 'Completed';
      case ActionItemStatus.inProgress:
        return 'In Progress';
      case ActionItemStatus.pending:
        return 'Pending';
      case ActionItemStatus.cancelled:
        return 'Cancelled';
    }
  }

  // Action methods
  void _addDiscussionPoint() {
    if (_discussionController.text.trim().isNotEmpty) {
      setState(() {
        _discussionPoints.add(_discussionController.text.trim());
        _discussionController.clear();
      });
    }
  }

  void _removeDiscussionPoint(int index) {
    setState(() => _discussionPoints.removeAt(index));
  }

  void _addDecision() {
    if (_decisionController.text.trim().isNotEmpty) {
      final decision = Decision(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        description: _decisionController.text.trim(),
        details: _decisionDetailsController.text.trim().isEmpty
            ? null
            : _decisionDetailsController.text.trim(),
        createdAt: DateTime.now(),
      );

      setState(() {
        _decisions.add(decision);
        _decisionController.clear();
        _decisionDetailsController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a decision description'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeDecision(int index) {
    setState(() => _decisions.removeAt(index));
  }

  void _addActionItem() {
    if (_actionItemController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an action item description'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_assigneeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please assign the action item to someone'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final actionItem = ActionItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      description: _actionItemController.text.trim(),
      details: _actionItemDetailsController.text.trim().isEmpty
          ? null
          : _actionItemDetailsController.text.trim(),
      assignedTo: _assigneeController.text.trim(),
      dueDate: _selectedDueDate,
      priority: _selectedPriority,
      createdAt: DateTime.now(),
    );

    setState(() {
      _actionItems.add(actionItem);
      _actionItemController.clear();
      _actionItemDetailsController.clear();
      _assigneeController.clear();
      _selectedDueDate = null;
      _selectedPriority = ActionItemPriority.medium;
    });
  }

  void _removeActionItem(int index) {
    setState(() => _actionItems.removeAt(index));
  }

  Future<void> _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _selectedDueDate = date);
    }
  }

  Future<void> _saveMeetingMinutes() async {
    setState(() => _isSaving = true);

    try {
      final meetingService = Provider.of<MeetingServiceRemote>(context, listen: false);
      
      final meetingMinutes = MeetingMinutes(
        meetingId: widget.meetingId,
        discussionPoints: _discussionPoints,
        decisions: _decisions,
        actionItems: _actionItems,
        generalNotes: _generalNotesController.text.trim().isEmpty
            ? null
            : _generalNotesController.text.trim(),
        attendeeNotes: _attendeeNotesController.text.trim().isEmpty
            ? null
            : _attendeeNotesController.text.trim(),
        createdAt: _meetingMinutes?.createdAt ?? DateTime.now(),
        lastUpdatedAt: DateTime.now(),
        createdBy: 'current_user@example.com', // TODO: Get from auth service
      );

      await meetingService.saveMeetingMinutes(widget.meetingId, meetingMinutes);
      
      if (mounted) {
        setState(() {
          _meetingMinutes = meetingMinutes;
          _isEditing = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Meeting minutes saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving meeting minutes: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _discussionController.dispose();
    _decisionController.dispose();
    _decisionDetailsController.dispose();
    _actionItemController.dispose();
    _actionItemDetailsController.dispose();
    _assigneeController.dispose();
    _generalNotesController.dispose();
    _attendeeNotesController.dispose();
    super.dispose();
  }
}
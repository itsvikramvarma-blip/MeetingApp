import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/meeting_service_remote.dart';
import '../../models/models.dart';

class EditMeetingScreen extends StatefulWidget {
  final String meetingId;
  
  const EditMeetingScreen({
    super.key,
    required this.meetingId,
  });

  @override
  State<EditMeetingScreen> createState() => _EditMeetingScreenState();
}

class _EditMeetingScreenState extends State<EditMeetingScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _agendaController = TextEditingController();
  
  DateTime _selectedStartDate = DateTime.now();
  TimeOfDay _selectedStartTime = TimeOfDay.now();
  DateTime _selectedEndDate = DateTime.now();
  TimeOfDay _selectedEndTime = TimeOfDay.now();
  
  bool _isLoading = true;
  bool _isEditMode = false;
  List<String> _agendaItems = [];
  List<String> _participants = [];
  List<String> _attachments = [];
  Meeting? _currentMeeting;
  
  // Check if meeting is completed and editing should be restricted
  bool get _isMeetingCompleted => _currentMeeting?.status == MeetingStatus.completed;

  @override
  void initState() {
    super.initState();
    _loadMeeting();
  }

  void _loadMeeting() {
    final meetingService = Provider.of<MeetingServiceRemote>(context, listen: false);
    
    try {
      final meeting = meetingService.meetings.firstWhere(
        (meeting) => meeting.id == widget.meetingId,
      );
      
      _currentMeeting = meeting;
      _titleController.text = meeting.title;
      _descriptionController.text = meeting.description ?? '';
      _agendaItems = List.from(meeting.agenda);
      _participants = List.from(meeting.participants);
      _attachments = List.from(meeting.attachments);
      
      _selectedStartDate = meeting.startTime;
      _selectedStartTime = TimeOfDay.fromDateTime(meeting.startTime);
      _selectedEndDate = meeting.endTime;
      _selectedEndTime = TimeOfDay.fromDateTime(meeting.endTime);
      
    } catch (e) {
      // Meeting not found
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Column(
      children: [
        // Header section with title and delete button
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Color(0xFFD4AF37),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isMeetingCompleted
                    ? (_isEditMode ? 'Edit Meeting Minutes' : 'Meeting Details (Completed)')
                    : (_isEditMode ? 'Edit Meeting' : 'Meeting Details'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // For completed meetings, only show edit button if not already editing
                  if (_isMeetingCompleted && !_isEditMode)
                    IconButton(
                      icon: const Icon(Icons.edit_note, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          _isEditMode = true;
                        });
                      },
                      tooltip: 'Edit Minutes & Attachments',
                    )
                  // For non-completed meetings, show full edit functionality
                  else if (!_isMeetingCompleted && !_isEditMode)
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          _isEditMode = true;
                        });
                      },
                      tooltip: 'Edit Meeting',
                    ),
                  if (_isEditMode) ...[
                    IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          _isEditMode = false;
                          // Reset any changes
                          _loadMeeting();
                        });
                      },
                      tooltip: 'Cancel Edit',
                    ),
                    IconButton(
                      icon: const Icon(Icons.save, color: Colors.white),
                      onPressed: _saveMeeting,
                      tooltip: 'Save Changes',
                    ),
                  ],
                  // Only allow deleting non-completed meetings
                  if (!_isMeetingCompleted)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.white),
                      onPressed: () {
                        _showDeleteDialog();
                      },
                      tooltip: 'Delete Meeting',
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTitleField(),
                const SizedBox(height: 16),
                _buildDescriptionField(),
                const SizedBox(height: 16),
                _buildDateTimeFields(),
                const SizedBox(height: 24),
                _buildParticipantsSection(),
                const SizedBox(height: 24),
                _buildAttachmentsSection(),
                const SizedBox(height: 24),
                _buildAgendaSection(),
                // Meeting Minutes section for completed meetings
                if (_isMeetingCompleted) ...[
                  const SizedBox(height: 24),
                  _buildMeetingMinutesSection(),
                ],
                if (_isEditMode) ...[
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _saveMeeting,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(_isMeetingCompleted ? 'Save Minutes & Attachments' : 'Save Meeting'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    if (_isEditMode && !_isMeetingCompleted) {
      return TextField(
        controller: _titleController,
        decoration: const InputDecoration(
          labelText: 'Meeting Title',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.title),
        ),
      );
    } else {
      return _buildReadOnlyField('Title', _titleController.text, Icons.title);
    }
  }

  Widget _buildDescriptionField() {
    if (_isEditMode && !_isMeetingCompleted) {
      return TextField(
        controller: _descriptionController,
        maxLines: 3,
        decoration: const InputDecoration(
          labelText: 'Description',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.description),
        ),
      );
    } else {
      return _buildReadOnlyField(
        'Description', 
        _descriptionController.text.isEmpty ? 'No description' : _descriptionController.text,
        Icons.description,
      );
    }
  }

  Widget _buildDateTimeFields() {
    if (_isEditMode && !_isMeetingCompleted) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _selectStartDate,
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    '${_selectedStartDate.day}/${_selectedStartDate.month}/${_selectedStartDate.year}',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _selectStartTime,
                  icon: const Icon(Icons.access_time),
                  label: Text(_selectedStartTime.format(context)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _selectEndDate,
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    '${_selectedEndDate.day}/${_selectedEndDate.month}/${_selectedEndDate.year}',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _selectEndTime,
                  icon: const Icon(Icons.access_time),
                  label: Text(_selectedEndTime.format(context)),
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      return Column(
        children: [
          _buildReadOnlyField(
            'Start Time', 
            '${_selectedStartDate.day}/${_selectedStartDate.month}/${_selectedStartDate.year} ${_selectedStartTime.format(context)}',
            Icons.schedule,
          ),
          const SizedBox(height: 16),
          _buildReadOnlyField(
            'End Time', 
            '${_selectedEndDate.day}/${_selectedEndDate.month}/${_selectedEndDate.year} ${_selectedEndTime.format(context)}',
            Icons.schedule_send,
          ),
        ],
      );
    }
  }

  Widget _buildParticipantsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Participants',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_isEditMode && !_isMeetingCompleted)
              IconButton(
                onPressed: _addParticipant,
                icon: const Icon(Icons.add_circle, color: Color(0xFFD4AF37)),
                tooltip: 'Add participant',
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (_participants.isNotEmpty)
          ...List.generate(_participants.length, (index) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFD4AF37),
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text(_participants[index]),
                trailing: (_isEditMode && !_isMeetingCompleted) 
                  ? IconButton(
                      onPressed: () => _removeParticipant(index),
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      tooltip: 'Remove participant',
                    )
                  : null,
              ),
            );
          })
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  _isEditMode ? 'No participants yet. Tap + to add participants.' : 'No participants added.',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildAttachmentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Attachments',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Attachments should be editable even for completed meetings
            if (_isEditMode)
              IconButton(
                onPressed: _addAttachment,
                icon: const Icon(Icons.add_circle, color: Color(0xFFD4AF37)),
                tooltip: 'Add attachment',
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (_attachments.isNotEmpty)
          ...List.generate(_attachments.length, (index) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFD4AF37),
                  child: Icon(Icons.attach_file, color: Colors.white),
                ),
                title: Text(_attachments[index]),
                // Attachments should be editable even for completed meetings
                trailing: _isEditMode 
                  ? IconButton(
                      onPressed: () => _removeAttachment(index),
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      tooltip: 'Remove attachment',
                    )
                  : null,
              ),
            );
          })
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  _isEditMode ? 'No attachments yet. Tap + to add attachments.' : 'No attachments added.',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildAgendaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Agenda Items',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_isEditMode && !_isMeetingCompleted)
              IconButton(
                onPressed: _addAgendaItem,
                icon: const Icon(Icons.add_circle, color: Color(0xFFD4AF37)),
                tooltip: 'Add agenda item',
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (_agendaItems.isNotEmpty)
          ...List.generate(_agendaItems.length, (index) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFD4AF37),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(_agendaItems[index]),
                trailing: (_isEditMode && !_isMeetingCompleted) 
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => _editAgendaItem(index),
                          icon: const Icon(Icons.edit, size: 20),
                          tooltip: 'Edit',
                        ),
                        IconButton(
                          onPressed: () => _removeAgendaItem(index),
                          icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                          tooltip: 'Delete',
                        ),
                      ],
                    )
                  : null,
              ),
            );
          })
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  _isEditMode ? 'No agenda items yet. Tap + to add items.' : 'No agenda items added.',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildReadOnlyField(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade50,
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate,
      firstDate: DateTime(2023),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _selectedStartDate = date;
      });
    }
  }

  Future<void> _selectStartTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedStartTime,
    );
    if (time != null) {
      setState(() {
        _selectedStartTime = time;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedEndDate,
      firstDate: DateTime(2023),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _selectedEndDate = date;
      });
    }
  }

  Future<void> _selectEndTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedEndTime,
    );
    if (time != null) {
      setState(() {
        _selectedEndTime = time;
      });
    }
  }

  void _saveMeeting() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a meeting title')),
      );
      return;
    }

    final meetingService = Provider.of<MeetingServiceRemote>(context, listen: false);
    
    try {
      if (_isMeetingCompleted) {
        // For completed meetings, only update attachments
        final currentMeeting = meetingService.meetings.firstWhere(
          (meeting) => meeting.id == widget.meetingId,
        );
        
        final updatedMeeting = Meeting(
          id: currentMeeting.id,
          title: currentMeeting.title,
          description: currentMeeting.description,
          startTime: currentMeeting.startTime,
          endTime: currentMeeting.endTime,
          organizer: currentMeeting.organizer,
          participants: currentMeeting.participants,
          meetingRoom: currentMeeting.meetingRoom,
          meetingLink: currentMeeting.meetingLink,
          status: currentMeeting.status,
          agenda: currentMeeting.agenda,
          attachments: _attachments, // Only update attachments
          notes: currentMeeting.notes,
          isRecurring: currentMeeting.isRecurring,
          recurrencePattern: currentMeeting.recurrencePattern,
          meetingMinutes: currentMeeting.meetingMinutes,
        );
        
        meetingService.updateMeeting(updatedMeeting);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attachments updated successfully')),
        );
      } else {
        // For non-completed meetings, update all fields
        final startDateTime = DateTime(
          _selectedStartDate.year,
          _selectedStartDate.month,
          _selectedStartDate.day,
          _selectedStartTime.hour,
          _selectedStartTime.minute,
        );
        
        final endDateTime = DateTime(
          _selectedEndDate.year,
          _selectedEndDate.month,
          _selectedEndDate.day,
          _selectedEndTime.hour,
          _selectedEndTime.minute,
        );

        final updatedMeeting = Meeting(
          id: widget.meetingId,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          startTime: startDateTime,
          endTime: endDateTime,
          organizer: 'Current User', // This should come from auth service
          participants: _participants,
          status: MeetingStatus.scheduled,
          agenda: _agendaItems,
          attachments: _attachments,
        );

        meetingService.updateMeeting(updatedMeeting);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meeting updated successfully')),
        );
      }

      setState(() {
        _isEditMode = false;
      });
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving meeting: $e')),
      );
    }
  }  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Meeting'),
        content: const Text('Are you sure you want to delete this meeting?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Meeting deleted')),
              );
              context.go('/meetings');
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _addParticipant() {
    showDialog(
      context: context,
      builder: (context) {
        final participantController = TextEditingController();
        return AlertDialog(
          title: const Text('Add Participant'),
          content: TextField(
            controller: participantController,
            decoration: const InputDecoration(
              hintText: 'Enter email address...',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final email = participantController.text.trim();
                if (email.isNotEmpty && _isValidEmail(email)) {
                  setState(() {
                    _participants.add(email);
                  });
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid email address')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.white,
              ),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _removeParticipant(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Participant'),
        content: Text('Remove "${_participants[index]}" from participants?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _participants.removeAt(index);
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _addAttachment() {
    showDialog(
      context: context,
      builder: (context) {
        final attachmentController = TextEditingController();
        return AlertDialog(
          title: const Text('Add Attachment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: attachmentController,
                decoration: const InputDecoration(
                  hintText: 'Enter file name or URL...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_file),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Note: File picker functionality would be implemented here in a real app.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final attachment = attachmentController.text.trim();
                if (attachment.isNotEmpty) {
                  setState(() {
                    _attachments.add(attachment);
                  });
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter an attachment name')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.white,
              ),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _removeAttachment(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Attachment'),
        content: Text('Remove "${_attachments[index]}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _attachments.removeAt(index);
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _addAgendaItem() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Agenda Item'),
        content: TextField(
          controller: _agendaController,
          decoration: const InputDecoration(
            hintText: 'Enter agenda item...',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () {
              _agendaController.clear();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_agendaController.text.trim().isNotEmpty) {
                setState(() {
                  _agendaItems.add(_agendaController.text.trim());
                });
                _agendaController.clear();
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: Colors.white,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _editAgendaItem(int index) {
    _agendaController.text = _agendaItems[index];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Agenda Item'),
        content: TextField(
          controller: _agendaController,
          decoration: const InputDecoration(
            hintText: 'Edit agenda item...',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () {
              _agendaController.clear();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_agendaController.text.trim().isNotEmpty) {
                setState(() {
                  _agendaItems[index] = _agendaController.text.trim();
                });
                _agendaController.clear();
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: Colors.white,
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _removeAgendaItem(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Agenda Item'),
        content: Text('Remove "${_agendaItems[index]}" from the agenda?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _agendaItems.removeAt(index);
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingMinutesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Meeting Minutes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                context.push('/meeting-minutes/${widget.meetingId}');
              },
              icon: const Icon(Icons.edit_note),
              label: const Text('Edit Minutes'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Meeting Minutes Preview Card
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_currentMeeting?.meetingMinutes != null) ...[
                  // Discussion Points Preview
                  if (_currentMeeting!.meetingMinutes!.discussionPoints.isNotEmpty) ...[
                    const Text(
                      'Discussion Points',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...(_currentMeeting!.meetingMinutes!.discussionPoints.take(3).map(
                      (point) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '• $point',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    )),
                    if (_currentMeeting!.meetingMinutes!.discussionPoints.length > 3)
                      Text(
                        '... and ${_currentMeeting!.meetingMinutes!.discussionPoints.length - 3} more',
                        style: const TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    const SizedBox(height: 12),
                  ],
                  
                  // Decisions and Action Items Summary
                  Row(
                    children: [
                      Expanded(
                        child: _buildMinutesSummaryCard(
                          'Decisions',
                          _currentMeeting!.meetingMinutes!.decisions.length.toString(),
                          Icons.gavel,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildMinutesSummaryCard(
                          'Action Items',
                          _currentMeeting!.meetingMinutes!.actionItems.length.toString(),
                          Icons.assignment,
                          Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  
                  if (_currentMeeting!.meetingMinutes!.generalNotes?.isNotEmpty == true) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'General Notes',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _currentMeeting!.meetingMinutes!.generalNotes!,
                      style: const TextStyle(fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ] else ...[
                  const Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.note_add,
                          size: 48,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'No meeting minutes added yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Tap "Edit Minutes" to add discussion points, decisions, and action items',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildMinutesSummaryCard(String title, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _agendaController.dispose();
    super.dispose();
  }
}
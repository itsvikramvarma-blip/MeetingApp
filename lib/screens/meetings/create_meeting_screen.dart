import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/meeting_service_remote.dart';
import '../../models/models.dart';

class CreateMeetingScreen extends StatefulWidget {
  const CreateMeetingScreen({super.key});

  @override
  State<CreateMeetingScreen> createState() => _CreateMeetingScreenState();
}

class _CreateMeetingScreenState extends State<CreateMeetingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _participantController = TextEditingController();
  final _agendaController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now().replacing(hour: TimeOfDay.now().hour + 1);
  
  List<String> _participants = [];
  List<String> _agenda = [];
  String? _selectedMeetingRoom;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Set default date to today
    _selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Meeting'),
        backgroundColor: const Color(0xFFD4AF37),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Meeting Title
                    _buildSectionTitle('Meeting Details'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Meeting Title*',
                        hintText: 'Enter meeting title',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Meeting title is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Meeting Description
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Enter meeting description (optional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Date and Time Section
                    _buildSectionTitle('Date & Time'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: _selectDate,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Text(_formatDate(_selectedDate)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Time Selection
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: _selectStartTime,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.access_time, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Text('Start: ${_startTime.format(context)}'),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: _selectEndTime,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.access_time_filled, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Text('End: ${_endTime.format(context)}'),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Meeting Room Selection
                    _buildSectionTitle('Meeting Room'),
                    const SizedBox(height: 8),
                    Consumer<MeetingServiceRemote>(
                      builder: (context, meetingService, child) {
                        return DropdownButtonFormField<String>(
                          initialValue: _selectedMeetingRoom,
                          decoration: const InputDecoration(
                            labelText: 'Select Meeting Room',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.room),
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('No meeting room'),
                            ),
                            ...meetingService.meetingRooms.map((room) {
                              return DropdownMenuItem(
                                value: room.name,
                                child: Text('${room.name} (${room.capacity} people)'),
                              );
                            }),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedMeetingRoom = value;
                            });
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Participants Section
                    _buildSectionTitle('Participants'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _participantController,
                            decoration: const InputDecoration(
                              labelText: 'Add Participant Email',
                              hintText: 'Enter email address',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person_add),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            onFieldSubmitted: (_) => _addParticipant(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _addParticipant,
                          icon: const Icon(Icons.add_circle),
                          color: const Color(0xFFD4AF37),
                          tooltip: 'Add Participant',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_participants.isNotEmpty) _buildParticipantsList(),
                    const SizedBox(height: 24),

                    // Agenda Section
                    _buildSectionTitle('Agenda'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _agendaController,
                            decoration: const InputDecoration(
                              labelText: 'Add Agenda Item',
                              hintText: 'Enter agenda item',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.list),
                            ),
                            onFieldSubmitted: (_) => _addAgendaItem(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _addAgendaItem,
                          icon: const Icon(Icons.add_circle),
                          color: const Color(0xFFD4AF37),
                          tooltip: 'Add Agenda Item',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_agenda.isNotEmpty) _buildAgendaList(),
                    const SizedBox(height: 32),

                    // Create Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _createMeeting,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4AF37),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text(
                          'Create Meeting',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFFD4AF37),
      ),
    );
  }

  Widget _buildParticipantsList() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Participants (${_participants.length})',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _participants.map((participant) {
              return Chip(
                label: Text(participant),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () => _removeParticipant(participant),
                backgroundColor: Colors.blue.shade50,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAgendaList() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Agenda Items (${_agenda.length})',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _agenda.length,
            itemBuilder: (context, index) {
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Text('${index + 1}.'),
                title: Text(_agenda[index]),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed: () => _removeAgendaItem(index),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _selectStartTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (time != null) {
      setState(() {
        _startTime = time;
        // Ensure end time is after start time
        if (_endTime.hour < _startTime.hour || 
            (_endTime.hour == _startTime.hour && _endTime.minute <= _startTime.minute)) {
          _endTime = TimeOfDay(
            hour: _startTime.hour + 1 > 23 ? 23 : _startTime.hour + 1,
            minute: _startTime.minute,
          );
        }
      });
    }
  }

  Future<void> _selectEndTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (time != null) {
      // Validate that end time is after start time
      final startMinutes = _startTime.hour * 60 + _startTime.minute;
      final endMinutes = time.hour * 60 + time.minute;
      
      if (endMinutes <= startMinutes) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('End time must be after start time'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      setState(() => _endTime = time);
    }
  }

  void _addParticipant() {
    final email = _participantController.text.trim();
    if (email.isNotEmpty && _isValidEmail(email)) {
      if (!_participants.contains(email)) {
        setState(() {
          _participants.add(email);
          _participantController.clear();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Participant already added')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeParticipant(String participant) {
    setState(() => _participants.remove(participant));
  }

  void _addAgendaItem() {
    final item = _agendaController.text.trim();
    if (item.isNotEmpty) {
      setState(() {
        _agenda.add(item);
        _agendaController.clear();
      });
    }
  }

  void _removeAgendaItem(int index) {
    setState(() => _agenda.removeAt(index));
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  DateTime _combineDateTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _createMeeting() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final meetingService = Provider.of<MeetingServiceRemote>(context, listen: false);
      
      final startDateTime = _combineDateTime(_selectedDate, _startTime);
      final endDateTime = _combineDateTime(_selectedDate, _endTime);

      final meeting = Meeting(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        startTime: startDateTime,
        endTime: endDateTime,
        organizer: 'current_user@example.com', // TODO: Get from auth service
        participants: _participants,
        meetingRoom: _selectedMeetingRoom,
        status: MeetingStatus.scheduled,
        agenda: _agenda,
        attachments: [], // Can be extended later
      );

      await meetingService.createMeeting(meeting);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Meeting created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating meeting: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _participantController.dispose();
    _agendaController.dispose();
    super.dispose();
  }
}
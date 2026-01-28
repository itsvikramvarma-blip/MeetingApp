import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/meeting_service_remote.dart';
import '../../models/models.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(_selectedDate.year, _selectedDate.month);
  }

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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Calendar',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.today, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _selectedDate = DateTime.now();
                    _currentMonth = DateTime(_selectedDate.year, _selectedDate.month);
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _buildCalendarHeader(),
        _buildCalendarGrid(),
        const Divider(),
        Expanded(
          child: _buildSelectedDateMeetings(),
        ),
      ],
    );
  }

  Widget _buildCalendarHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
              });
            },
          ),
          Text(
            _getMonthYearString(_currentMonth),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    return Consumer<MeetingServiceRemote>(
      builder: (context, meetingService, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              // Days of week header
              Row(
                children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                    .map((day) => Expanded(
                          child: Center(
                            child: Text(
                              day,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 8),
              // Calendar days
              ..._buildCalendarWeeks(meetingService),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildCalendarWeeks(MeetingServiceRemote meetingService) {
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final startDate = firstDayOfMonth.subtract(Duration(days: firstDayOfMonth.weekday % 7));
    
    List<Widget> weeks = [];
    DateTime currentWeekStart = startDate;
    
    while (currentWeekStart.isBefore(lastDayOfMonth)) {
      List<Widget> days = [];
      
      for (int i = 0; i < 7; i++) {
        final date = currentWeekStart.add(Duration(days: i));
        final isCurrentMonth = date.month == _currentMonth.month;
        final isSelected = _isSameDate(date, _selectedDate);
        final isToday = _isSameDate(date, DateTime.now());
        final meetingCount = _getMeetingCountForDate(date, meetingService);
        
        days.add(
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDate = date;
                });
              },
              child: Container(
                height: 50,
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.blue
                      : isToday
                          ? Colors.blue.withOpacity(0.3)
                          : null,
                  borderRadius: BorderRadius.circular(8),
                  border: isToday && !isSelected
                      ? Border.all(color: Colors.blue, width: 2)
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${date.day}',
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : isCurrentMonth
                                ? Colors.black
                                : Colors.grey,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    if (meetingCount > 0)
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
      
      weeks.add(
        Row(children: days),
      );
      
      currentWeekStart = currentWeekStart.add(const Duration(days: 7));
    }
    
    return weeks;
  }

  Widget _buildSelectedDateMeetings() {
    return Consumer<MeetingServiceRemote>(
      builder: (context, meetingService, child) {
        final meetings = _getMeetingsForDate(_selectedDate, meetingService);
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Meetings on ${_getDateString(_selectedDate)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: meetings.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_available,
                            size: 60,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No meetings scheduled',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: meetings.length,
                      itemBuilder: (context, index) {
                        final meeting = meetings[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: const Icon(
                                Icons.video_call,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(meeting.title),
                            subtitle: Text(
                              '${_formatTime(meeting.startTime)} - ${_formatTime(meeting.endTime)}\n${meeting.participants.length} participants',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.play_arrow),
                              onPressed: () {
                                _joinMeeting(meeting);
                              },
                            ),
                            onTap: () {
                              // Navigate to meeting details
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  int _getMeetingCountForDate(DateTime date, MeetingServiceRemote meetingService) {
    return meetingService.meetings
        .where((meeting) => _isSameDate(meeting.startTime, date))
        .length;
  }

  List<Meeting> _getMeetingsForDate(DateTime date, MeetingServiceRemote meetingService) {
    return meetingService.meetings
        .where((meeting) => _isSameDate(meeting.startTime, date))
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  String _getMonthYearString(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _getDateString(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  void _joinMeeting(Meeting meeting) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Join ${meeting.title}'),
        content: const Text('Starting video call...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
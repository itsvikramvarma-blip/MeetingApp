import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/meeting_service.dart';
import '../../models/models.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _DashboardHome(
        showTodaysMeetings: _showTodaysMeetings,
        showUpcomingMeetings: _showUpcomingMeetings,
        showCompletedMeetings: _showCompletedMeetings,
      ),
      _DashboardHome(
        showTodaysMeetings: _showTodaysMeetings,
        showUpcomingMeetings: _showUpcomingMeetings,
        showCompletedMeetings: _showCompletedMeetings,
      ),
      _DashboardHome(
        showTodaysMeetings: _showTodaysMeetings,
        showUpcomingMeetings: _showUpcomingMeetings,
        showCompletedMeetings: _showCompletedMeetings,
      ),
      _DashboardHome(
        showTodaysMeetings: _showTodaysMeetings,
        showUpcomingMeetings: _showUpcomingMeetings,
        showCompletedMeetings: _showCompletedMeetings,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meeting Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications')),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _handleLogout();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          _handleBottomNavTap(index);
        },
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_call),
            label: 'Meetings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task_alt),
            label: 'Tasks',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createMeeting,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _createMeeting() {
    showModalBottomSheet(
      context: context,
      builder: (context) => const CreateMeetingBottomSheet(),
    );
  }

  void _handleBottomNavTap(int index) {
    switch (index) {
      case 0: // Home - stay on dashboard
        // Already on home/dashboard, no action needed
        break;
      case 1: // Meetings
        context.go('/meetings');
        break;
      case 2: // Calendar
        context.go('/calendar');
        break;
      case 3: // Tasks
        context.go('/tasks');
        break;
    }
  }

  void _handleLogout() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.signOut();
    if (mounted) {
      context.go('/login');
    }
  }

  void _showTodaysMeetings(BuildContext context) {
    final meetingService = Provider.of<MeetingService>(context, listen: false);
    final todayMeetings = meetingService.meetings.where((m) => 
        m.startTime.year == DateTime.now().year &&
        m.startTime.month == DateTime.now().month &&
        m.startTime.day == DateTime.now().day).toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Today's Meetings"),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: todayMeetings.isEmpty
              ? const Center(child: Text('No meetings today'))
              : ListView.builder(
                  itemCount: todayMeetings.length,
                  itemBuilder: (context, index) {
                    final meeting = todayMeetings[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Text(meeting.title[0].toUpperCase()),
                      ),
                      title: Text(meeting.title),
                      subtitle: Text(
                        '${meeting.startTime.hour}:${meeting.startTime.minute.toString().padLeft(2, '0')}',
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        context.go('/edit-meeting/${meeting.id}');
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/meetings');
            },
            child: const Text('View All'),
          ),
        ],
      ),
    );
  }

  void _showUpcomingMeetings(BuildContext context) {
    final meetingService = Provider.of<MeetingService>(context, listen: false);
    final upcomingMeetings = meetingService.meetings.where((m) => 
        m.startTime.isAfter(DateTime.now()) &&
        !_isSameDay(m.startTime, DateTime.now())).toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upcoming Meetings'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: upcomingMeetings.isEmpty
              ? const Center(child: Text('No upcoming meetings'))
              : ListView.builder(
                  itemCount: upcomingMeetings.length,
                  itemBuilder: (context, index) {
                    final meeting = upcomingMeetings[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Text(meeting.title[0].toUpperCase()),
                      ),
                      title: Text(meeting.title),
                      subtitle: Text(
                        '${meeting.startTime.day}/${meeting.startTime.month}/${meeting.startTime.year}',
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        context.go('/edit-meeting/${meeting.id}');
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/meetings');
            },
            child: const Text('View All'),
          ),
        ],
      ),
    );
  }

  void _showCompletedMeetings(BuildContext context) {
    final meetingService = Provider.of<MeetingService>(context, listen: false);
    final completedMeetings = meetingService.meetings.where((m) => 
        m.status == MeetingStatus.completed ||
        m.endTime.isBefore(DateTime.now())).toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Completed Meetings'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: completedMeetings.isEmpty
              ? const Center(child: Text('No completed meetings'))
              : ListView.builder(
                  itemCount: completedMeetings.length,
                  itemBuilder: (context, index) {
                    final meeting = completedMeetings[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.purple,
                        child: Text(meeting.title[0].toUpperCase()),
                      ),
                      title: Text(meeting.title),
                      subtitle: Text(
                        'Completed ${meeting.endTime.day}/${meeting.endTime.month}/${meeting.endTime.year}',
                      ),
                      trailing: const Icon(Icons.check_circle, color: Colors.green),
                      onTap: () {
                        Navigator.pop(context);
                        context.go('/edit-meeting/${meeting.id}');
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/meetings');
            },
            child: const Text('View All'),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
}

class _DashboardHome extends StatelessWidget {
  final void Function(BuildContext) showTodaysMeetings;
  final void Function(BuildContext) showUpcomingMeetings;
  final void Function(BuildContext) showCompletedMeetings;

  const _DashboardHome({
    required this.showTodaysMeetings,
    required this.showUpcomingMeetings,
    required this.showCompletedMeetings,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome Back!',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          _buildQuickStats(context),
          const SizedBox(height: 24),
          _buildQuickActions(context),
          const SizedBox(height: 24),
          Text(
            'Recent Activity',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildRecentActivity(context),
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return Consumer<MeetingService>(
      builder: (context, meetingService, child) {
        final todayMeetings = meetingService.meetings
            .where((m) => 
                m.startTime.year == DateTime.now().year &&
                m.startTime.month == DateTime.now().month &&
                m.startTime.day == DateTime.now().day)
            .length;
        
        final upcomingMeetings = meetingService.meetings
            .where((m) => 
                m.startTime.isAfter(DateTime.now()) &&
                !_isSameDay(m.startTime, DateTime.now()))
            .length;

        final completedMeetings = meetingService.meetings
            .where((m) => 
                m.status == MeetingStatus.completed ||
                m.endTime.isBefore(DateTime.now()))
            .length;
        
        return Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Today\'s',
                value: todayMeetings.toString(),
                icon: Icons.today,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Upcoming',
                value: upcomingMeetings.toString(),
                icon: Icons.upcoming,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Completed',
                value: completedMeetings.toString(),
                icon: Icons.check_circle,
                color: Colors.purple,
              ),
            ),
          ],
        );
      },
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      children: [
        // Quick meeting filters
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => showTodaysMeetings(context),
                icon: const Icon(Icons.today, size: 16),
                label: const Text("Today's"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.withOpacity(0.1),
                  foregroundColor: Colors.green,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => showUpcomingMeetings(context),
                icon: const Icon(Icons.upcoming, size: 16),
                label: const Text('Upcoming'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  foregroundColor: Colors.blue,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => showCompletedMeetings(context),
                icon: const Icon(Icons.check_circle, size: 16),
                label: const Text('Completed'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.withOpacity(0.1),
                  foregroundColor: Colors.purple,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Navigation',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        // Main navigation buttons
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _ActionCard(
              title: 'Meetings',
              subtitle: 'View & manage meetings',
              icon: Icons.video_call,
              color: Colors.indigo,
              onTap: () => context.go('/meetings'),
            ),
            _ActionCard(
              title: 'Calendar',
              subtitle: 'Schedule & plan',
              icon: Icons.calendar_today,
              color: Colors.purple,
              onTap: () => context.go('/calendar'),
            ),
            _ActionCard(
              title: 'Tasks',
              subtitle: 'Track progress',
              icon: Icons.task_alt,
              color: Colors.teal,
              onTap: () => context.go('/tasks'),
            ),
            _ActionCard(
              title: 'Settings',
              subtitle: 'Preferences',
              icon: Icons.settings,
              color: Colors.grey,
              onTap: () => context.go('/settings'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return Consumer<MeetingService>(
      builder: (context, meetingService, child) {
        final recentMeetings = meetingService.meetings
            .take(3)
            .toList();
        
        if (recentMeetings.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No recent meetings'),
            ),
          );
        }
        
        return Column(
          children: recentMeetings
              .map((meeting) => Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Text(meeting.title[0].toUpperCase()),
                      ),
                      title: Text(meeting.title),
                      subtitle: Text(
                        '${meeting.startTime.day}/${meeting.startTime.month}/${meeting.startTime.year}',
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => context.go('/edit-meeting/${meeting.id}'),
                    ),
                  ))
              .toList(),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const Spacer(),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 32),
              const Spacer(),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CreateMeetingBottomSheet extends StatefulWidget {
  const CreateMeetingBottomSheet({super.key});

  @override
  State<CreateMeetingBottomSheet> createState() => _CreateMeetingBottomSheetState();
}

class _CreateMeetingBottomSheetState extends State<CreateMeetingBottomSheet> {
  final _titleController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Create New Meeting',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Meeting Title',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: Text('Date: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
            onTap: _selectDate,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _createMeeting,
                  child: const Text('Create'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
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

  void _createMeeting() async {
    if (_titleController.text.isNotEmpty) {
      final meetingService = Provider.of<MeetingService>(context, listen: false);
      final meeting = Meeting(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: 'New meeting created from dashboard',
        startTime: _selectedDate,
        endTime: _selectedDate.add(const Duration(hours: 1)),
        organizer: 'current_user@example.com',
        participants: [],
        status: MeetingStatus.scheduled,
      );
      await meetingService.createMeeting(meeting);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Meeting created successfully!')),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}

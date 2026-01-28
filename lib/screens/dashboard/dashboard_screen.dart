import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service_remote.dart';
import '../../services/meeting_service_remote.dart';
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
        automaticallyImplyLeading: false, // Remove back arrow
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
    context.go('/create-meeting');
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
    final authService = Provider.of<AuthServiceRemote>(context, listen: false);
    await authService.signOut();
    if (mounted) {
      context.go('/login');
    }
  }

  void _showTodaysMeetings(BuildContext context) {
    final meetingService = Provider.of<MeetingServiceRemote>(context, listen: false);
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
    final meetingService = Provider.of<MeetingServiceRemote>(context, listen: false);
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
    final meetingService = Provider.of<MeetingServiceRemote>(context, listen: false);
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
    return Consumer<MeetingServiceRemote>(
      builder: (context, meetingService, child) {
        final meetings = meetingService.meetings;
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
              child: _ClickableStatCard(
                title: 'Today\'s',
                value: todayMeetings.toString(),
                icon: Icons.today,
                color: Colors.green,
                onTap: () => showTodaysMeetings(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ClickableStatCard(
                title: 'Upcoming',
                value: upcomingMeetings.toString(),
                icon: Icons.upcoming,
                color: Colors.blue,
                onTap: () => showUpcomingMeetings(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ClickableStatCard(
                title: 'Completed',
                value: completedMeetings.toString(),
                icon: Icons.check_circle,
                color: Colors.purple,
                onTap: () => showCompletedMeetings(context),
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

  Widget _buildRecentActivity(BuildContext context) {
    return Consumer<MeetingServiceRemote>(
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
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.schedule,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatDateTime(meeting.startTime),
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.people,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${meeting.participants.length} participant${meeting.participants.length != 1 ? 's' : ''}',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              if (meeting.participants.isNotEmpty) ...[
                                const Text(' • ', style: TextStyle(color: Colors.grey)),
                                Expanded(
                                  child: Text(
                                    meeting.participants.length <= 2
                                        ? meeting.participants.join(', ')
                                        : '${meeting.participants.take(2).join(', ')} +${meeting.participants.length - 2} more',
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
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

class _ClickableStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ClickableStatCard({
    required this.title,
    required this.value,
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
      ),
    );
  }
}
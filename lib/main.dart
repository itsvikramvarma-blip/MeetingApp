import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'services/auth_service_remote.dart';
import 'services/meeting_service_remote.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/meetings/meetings_screen.dart';
import 'screens/calendar/calendar_screen.dart';
import 'screens/tasks/tasks_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/meetings/edit_meeting_screen.dart';
import 'screens/meetings/create_meeting_screen.dart';
import 'screens/meetings/meeting_minutes_screen.dart';

void main() {
  runApp(const MeetingApp());
}

class MeetingApp extends StatelessWidget {
  const MeetingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthServiceRemote()),
        ChangeNotifierProvider(create: (_) => MeetingServiceRemote()),
      ],
      child: Consumer<AuthServiceRemote>(
        builder: (context, authService, child) {
          return MaterialApp.router(
            title: 'Meeting App',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
              useMaterial3: true,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
            ),
            routerConfig: _createRouter(authService),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }

  GoRouter _createRouter(AuthServiceRemote authService) {
    return GoRouter(
      initialLocation: '/splash',
      redirect: (context, state) {
        final isAuthenticated = authService.isAuthenticated;
        final isOnLoginPage = state.matchedLocation == '/login';
        final isOnSplash = state.matchedLocation == '/splash';

        // If not authenticated and not on login or splash, go to login
        if (!isAuthenticated && !isOnLoginPage && !isOnSplash) {
          return '/login';
        }

        // If authenticated and on login page, go to dashboard
        if (isAuthenticated && isOnLoginPage) {
          return '/dashboard';
        }

        return null; // No redirect needed
      },
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/meetings',
          builder: (context, state) => const NavigationWrapper(
            child: MeetingsScreen(),
            currentIndex: 1,
          ),
        ),
        GoRoute(
          path: '/calendar',
          builder: (context, state) => const NavigationWrapper(
            child: CalendarScreen(),
            currentIndex: 2,
          ),
        ),
        GoRoute(
          path: '/tasks',
          builder: (context, state) => const NavigationWrapper(
            child: TasksScreen(),
            currentIndex: 3,
          ),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const NavigationWrapper(
            child: SettingsScreen(),
            currentIndex: -1, // No bottom nav highlight for settings
          ),
        ),
        GoRoute(
          path: '/edit-meeting/:id',
          builder: (context, state) {
            final meetingId = state.pathParameters['id']!;
            return NavigationWrapper(
              child: EditMeetingScreen(meetingId: meetingId),
              currentIndex: -1, // No bottom nav highlight for edit screen
            );
          },
        ),
        GoRoute(
          path: '/create-meeting',
          builder: (context, state) => const NavigationWrapper(
            child: CreateMeetingScreen(),
            currentIndex: -1, // No bottom nav highlight for create screen
          ),
        ),
        GoRoute(
          path: '/meeting-minutes/:id',
          builder: (context, state) {
            final meetingId = state.pathParameters['id']!;
            return NavigationWrapper(
              child: MeetingMinutesScreen(meetingId: meetingId),
              currentIndex: -1, // No bottom nav highlight for minutes screen
            );
          },
        ),
      ],
    );
  }
}

// Navigation wrapper that provides consistent back arrow and bottom navigation
class NavigationWrapper extends StatelessWidget {
  final Widget child;
  final int currentIndex;

  const NavigationWrapper({
    Key? key,
    required this.child,
    required this.currentIndex,
  }) : super(key: key);

  void _onBottomNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/meetings');
        break;
      case 2:
        context.go('/calendar');
        break;
      case 3:
        context.go('/tasks');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/dashboard');
            }
          },
        ),
        backgroundColor: const Color(0xFFD4AF37),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex >= 0 ? currentIndex : 0,
        selectedItemColor: const Color(0xFFD4AF37),
        unselectedItemColor: Colors.grey,
        onTap: (index) => _onBottomNavTap(context, index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Meetings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: 'Tasks',
          ),
        ],
      ),
    );
  }
}
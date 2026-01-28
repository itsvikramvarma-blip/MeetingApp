import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/models.dart';
import '../config/api_config.dart';

class MeetingServiceRemote extends ChangeNotifier {
  final List<Meeting> _meetings = [];
  final List<Task> _tasks = [];
  final List<MeetingRoom> _meetingRooms = [];
  String? _authToken;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Meeting> get meetings => List.unmodifiable(_meetings);
  List<Task> get tasks => List.unmodifiable(_tasks);
  List<MeetingRoom> get meetingRooms => List.unmodifiable(_meetingRooms);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Set auth token from AuthService
  void setAuthToken(String token) {
    _authToken = token;
  }

  // Initialize and fetch data
  Future<void> initialize() async {
    await fetchMeetings();
    await fetchTasks();
  }

  // Fetch all meetings
  Future<void> fetchMeetings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http
          .get(
            Uri.parse(ApiConfig.meetingsEndpoint),
            headers: _getHeaders(),
          )
          .timeout(const Duration(seconds: ApiConfig.requestTimeout));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _meetings.clear();
        _meetings.addAll(
          data.map((json) => Meeting.fromJson(json)).toList(),
        );
        _errorMessage = null;
      } else if (response.statusCode == 401) {
        _errorMessage = 'Unauthorized. Please login again.';
      } else {
        _errorMessage = 'Failed to fetch meetings: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error fetching meetings: ${e.toString()}';
      print('Fetch meetings error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Fetch all tasks
  Future<void> fetchTasks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/tasks'),
            headers: _getHeaders(),
          )
          .timeout(const Duration(seconds: ApiConfig.requestTimeout));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _tasks.clear();
        _tasks.addAll(
          data.map((json) => Task.fromJson(json)).toList(),
        );
        _errorMessage = null;
      } else {
        _errorMessage = 'Failed to fetch tasks: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error fetching tasks: ${e.toString()}';
      print('Fetch tasks error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Add new meeting
  Future<bool> addMeeting(Meeting meeting) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.meetingsEndpoint),
            headers: _getHeaders(),
            body: jsonEncode(meeting.toJson()),
          )
          .timeout(const Duration(seconds: ApiConfig.requestTimeout));

      if (response.statusCode == 201) {
        final newMeeting = Meeting.fromJson(jsonDecode(response.body));
        _meetings.add(newMeeting);
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to add meeting: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error adding meeting: ${e.toString()}';
      print('Add meeting error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Update meeting
  Future<bool> updateMeeting(Meeting meeting) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http
          .put(
            Uri.parse('${ApiConfig.meetingsEndpoint}/${meeting.id}'),
            headers: _getHeaders(),
            body: jsonEncode(meeting.toJson()),
          )
          .timeout(const Duration(seconds: ApiConfig.requestTimeout));

      if (response.statusCode == 200) {
        final index = _meetings.indexWhere((m) => m.id == meeting.id);
        if (index != -1) {
          _meetings[index] = Meeting.fromJson(jsonDecode(response.body));
        }
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to update meeting: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error updating meeting: ${e.toString()}';
      print('Update meeting error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Delete meeting
  Future<bool> deleteMeeting(String meetingId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http
          .delete(
            Uri.parse('${ApiConfig.meetingsEndpoint}/$meetingId'),
            headers: _getHeaders(),
          )
          .timeout(const Duration(seconds: ApiConfig.requestTimeout));

      if (response.statusCode == 200) {
        _meetings.removeWhere((m) => m.id == meetingId);
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to delete meeting: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error deleting meeting: ${e.toString()}';
      print('Delete meeting error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Add meeting minutes
  Future<bool> addMeetingMinutes(
    String meetingId,
    MeetingMinutes minutes,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.minutesEndpoint}/$meetingId/minutes'),
            headers: _getHeaders(),
            body: jsonEncode(minutes.toJson()),
          )
          .timeout(const Duration(seconds: ApiConfig.requestTimeout));

      if (response.statusCode == 201) {
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to add meeting minutes: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error adding meeting minutes: ${e.toString()}';
      print('Add minutes error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Mark meeting as completed
  Future<bool> markMeetingCompleted(String meetingId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http
          .patch(
            Uri.parse('${ApiConfig.meetingsEndpoint}/$meetingId/complete'),
            headers: _getHeaders(),
          )
          .timeout(const Duration(seconds: ApiConfig.requestTimeout));

      if (response.statusCode == 200) {
        final index = _meetings.indexWhere((m) => m.id == meetingId);
        if (index != -1) {
          _meetings[index] = Meeting.fromJson(jsonDecode(response.body));
        }
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to mark meeting completed: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error marking meeting completed: ${e.toString()}';
      print('Mark completed error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Create meeting (alias for addMeeting)
  Future<bool> createMeeting(Meeting meeting) async {
    return addMeeting(meeting);
  }

  // Save meeting minutes
  Future<bool> saveMeetingMinutes(String meetingId, MeetingMinutes minutes) async {
    return addMeetingMinutes(meetingId, minutes);
  }

  // Get meeting by ID
  Meeting? getMeetingById(String meetingId) {
    try {
      return _meetings.firstWhere((m) => m.id == meetingId);
    } catch (e) {
      return null;
    }
  }

  // Get authorization headers
  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      if (_authToken != null) 'Authorization': 'Bearer $_authToken',
    };
  }
}

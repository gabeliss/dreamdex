import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/dream.dart';

class ConvexService extends ChangeNotifier {
  late Dio _dio;
  String? _convexUrl;
  String? _userId;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  String? get userId => _userId;

  ConvexService() {
    _dio = Dio();
    _initializeService();
  }

  Future<void> _initializeService() async {
    // Load Convex URL from environment variables
    _convexUrl = dotenv.env['CONVEX_URL'];
    
    if (_convexUrl != null && _convexUrl!.isNotEmpty) {
      debugPrint('ConvexService initialized with URL: $_convexUrl');
      _isInitialized = true;
      notifyListeners();
    } else {
      debugPrint('ConvexService: CONVEX_URL not found in environment');
    }
  }

  void setUserId(String userId) {
    _userId = userId;
    notifyListeners();
  }

  Future<List<Dream>> getDreams() async {
    if (!_isInitialized || _userId == null) {
      return [];
    }

    try {
      final response = await _dio.post(
        '$_convexUrl/api/query',
        data: {
          'path': 'dreams:list',
          'args': {'userId': _userId},
        },
      );

      if (response.statusCode == 200) {
        // Check if response contains an error
        if (response.data is Map<String, dynamic> && 
            response.data['status'] == 'error') {
          debugPrint('❌ Convex API returned error: ${response.data['errorMessage']}');
          return [];
        }
        
        // Handle both response formats
        List<dynamic> dreamsList = [];
        
        if (response.data is List<dynamic>) {
          // Direct array response
          dreamsList = response.data;
        } else if (response.data is Map<String, dynamic> && 
                   response.data['status'] == 'success' &&
                   response.data['value'] is List<dynamic>) {
          // New format: {status: 'success', value: [...]}
          dreamsList = response.data['value'];
        } else {
          debugPrint('❌ Unexpected response format: ${response.data}');
          return [];
        }
        
        return dreamsList.map((dreamJson) => Dream.fromJson(dreamJson)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching dreams from Convex: $e');
    }

    return [];
  }

  Future<String?> createDream(Dream dream) async {
    debugPrint('=== CONVEX CREATE DREAM ===');
    debugPrint('ConvexService initialized: $_isInitialized');
    debugPrint('User ID: $_userId');
    debugPrint('Dream title: ${dream.title}');
    
    if (!_isInitialized || _userId == null) {
      debugPrint('ConvexService not initialized or userId null, aborting dream creation');
      return null;
    }

    try {
      final dreamData = dream.toJson();
      dreamData['userId'] = _userId;
      
      // Remove null values and system fields that Convex handles automatically
      dreamData.removeWhere((key, value) => 
          value == null || 
          key == '_creationTime' || 
          key == '_id' ||
          key == 'id' ||
          key == 'createdAt'
      );

      debugPrint('Dream data: $dreamData');

      final response = await _dio.post(
        '$_convexUrl/api/mutation',
        data: {
          'path': 'dreams:create',
          'args': dreamData,
        },
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response data: ${response.data}');

      if (response.statusCode == 200) {
        // Check if the response contains an error
        if (response.data is Map<String, dynamic> && 
            response.data['status'] == 'error') {
          debugPrint('❌ Convex API returned error: ${response.data['errorMessage']}');
          return null;
        }
        
        // Extract the ID from successful response
        final responseData = response.data;
        String? dreamId;
        
        if (responseData is Map<String, dynamic>) {
          if (responseData['status'] == 'success' && responseData['value'] != null) {
            dreamId = responseData['value'].toString();
          }
        } else {
          // Direct ID response
          dreamId = responseData?.toString();
        }
        
        debugPrint('✅ Dream created successfully with ID: $dreamId');
        return dreamId;
      } else {
        debugPrint('❌ Unexpected response status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error creating dream in Convex: $e');
    }

    return null;
  }

  Future<bool> updateDream(Dream dream) async {
    if (!_isInitialized || _userId == null) {
      return false;
    }

    try {
      final dreamData = dream.toJson();
      dreamData['userId'] = _userId;
      
      // Remove null values for optional fields to avoid validation errors
      dreamData.removeWhere((key, value) => value == null);

      final response = await _dio.post(
        '$_convexUrl/api/mutation',
        data: {
          'path': 'dreams:update',
          'args': {
            'id': dream.id,
            'updates': dreamData,
          },
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error updating dream in Convex: $e');
      return false;
    }
  }

  Future<bool> deleteDream(String dreamId) async {
    if (!_isInitialized || _userId == null) {
      return false;
    }

    try {
      final response = await _dio.post(
        '$_convexUrl/api/mutation',
        data: {
          'path': 'dreams:remove',
          'args': {'id': dreamId, 'userId': _userId},
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error deleting dream from Convex: $e');
      return false;
    }
  }

  Future<List<Dream>> searchDreams(String query) async {
    if (!_isInitialized || _userId == null || query.isEmpty) {
      return [];
    }

    try {
      final response = await _dio.post(
        '$_convexUrl/api/query',
        data: {
          'path': 'dreams:search',
          'args': {
            'userId': _userId,
            'query': query,
          },
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((dreamJson) => Dream.fromJson(dreamJson)).toList();
      }
    } catch (e) {
      debugPrint('Error searching dreams in Convex: $e');
    }

    return [];
  }

  Future<Map<String, int>> getDreamStats() async {
    if (!_isInitialized || _userId == null) {
      return {
        'total': 0,
        'thisWeek': 0,
        'thisMonth': 0,
        'favorites': 0,
      };
    }

    try {
      final response = await _dio.post(
        '$_convexUrl/api/query',
        data: {
          'path': 'dreams:stats',
          'args': {'userId': _userId},
        },
      );

      if (response.statusCode == 200) {
        return Map<String, int>.from(response.data);
      }
    } catch (e) {
      debugPrint('Error fetching dream stats from Convex: $e');
    }

    return {
      'total': 0,
      'thisWeek': 0,
      'thisMonth': 0,
      'favorites': 0,
    };
  }

  // Create or update user in Convex
  Future<String?> upsertUser({
    required String clerkId,
    required String email,
    String? firstName,
    String? lastName,
    String? profileImageUrl,
  }) async {
    debugPrint('=== CONVEX UPSERT USER ===');
    debugPrint('ConvexService initialized: $_isInitialized');
    debugPrint('Convex URL: $_convexUrl');
    debugPrint('Clerk ID: $clerkId');
    debugPrint('Email: $email');
    debugPrint('First Name: $firstName');
    debugPrint('Last Name: $lastName');
    
    if (!_isInitialized) {
      debugPrint('ConvexService not initialized, aborting user sync');
      return null;
    }

    try {
      // Build args object, excluding null values for optional fields
      final Map<String, dynamic> args = {
        'clerkId': clerkId,
        'email': email,
      };
      
      // Only add optional fields if they're not null
      if (firstName != null && firstName.isNotEmpty) {
        args['firstName'] = firstName;
      }
      if (lastName != null && lastName.isNotEmpty) {
        args['lastName'] = lastName;
      }
      if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
        args['profileImageUrl'] = profileImageUrl;
      }
      
      final payload = {
        'path': 'users:upsert',
        'args': args,
      };
      
      debugPrint('API Payload: $payload');
      
      final response = await _dio.post(
        '$_convexUrl/api/mutation',
        data: payload,
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response data: ${response.data}');

      if (response.statusCode == 200) {
        // Check if the response contains an error
        if (response.data is Map<String, dynamic> && 
            response.data['status'] == 'error') {
          debugPrint('❌ Convex API returned error: ${response.data['errorMessage']}');
          return null;
        } else {
          debugPrint('✅ User synced to Convex successfully: $email');
          return response.data.toString();
        }
      } else {
        debugPrint('❌ Unexpected response status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error syncing user to Convex: $e');
      if (e.toString().contains('DioException')) {
        debugPrint('This is likely a network or API format issue');
      }
    }

    debugPrint('=== END CONVEX UPSERT ===');
    return null;
  }

  // Sync local dreams to Convex (for migration)
  Future<bool> syncLocalDreams(List<Dream> localDreams) async {
    if (!_isInitialized || _userId == null) {
      return false;
    }

    try {
      for (final dream in localDreams) {
        await createDream(dream);
      }
      return true;
    } catch (e) {
      debugPrint('Error syncing local dreams to Convex: $e');
      return false;
    }
  }
}
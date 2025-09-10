import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
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
    debugPrint('✅ SECURITY: ConvexService userId set to: $_userId');
    // Defer notification to avoid calling during build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void clearUserId() {
    debugPrint('🔒 SECURITY: Clearing ConvexService userId (was: $_userId)');
    _userId = null;
    notifyListeners();
  }

  Future<List<Dream>> getDreams() async {
    if (!_isInitialized || _userId == null) {
      debugPrint('❌ SECURITY: Cannot fetch dreams - ConvexService not initialized or userId is null');
      debugPrint('_isInitialized: $_isInitialized, _userId: $_userId');
      return [];
    }
    
    debugPrint('✅ SECURITY: Fetching dreams for user: $_userId');

    try {
      final response = await _dio.post(
        '$_convexUrl/api/query',
        data: {
          'path': 'dreams:listWithImageUrls',
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

  Future<bool> updateDreamAnalysis(String dreamId, Map<String, dynamic> analysisData) async {
    debugPrint('=== CONVEX UPDATE DREAM ANALYSIS ===');
    debugPrint('Dream ID: $dreamId');
    debugPrint('User ID: $_userId');
    debugPrint('Analysis data keys: ${analysisData.keys}');
    debugPrint('Analysis data: ${analysisData.toString().substring(0, 200)}...');
    
    if (!_isInitialized || _userId == null) {
      debugPrint('❌ ConvexService not initialized or userId null');
      return false;
    }

    try {
      final payload = {
        'path': 'dreams:update',
        'args': {
          'id': dreamId,
          'userId': _userId,
          'updates': {
            'analysis': analysisData,
          },
        },
      };
      
      debugPrint('Update payload: $payload');
      
      final response = await _dio.post(
        '$_convexUrl/api/mutation',
        data: payload,
      );

      debugPrint('Update response status: ${response.statusCode}');
      debugPrint('Update response data: ${response.data}');

      if (response.statusCode == 200) {
        debugPrint('✅ Dream analysis update successful');
        return true;
      } else {
        debugPrint('❌ Dream analysis update failed with status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error updating dream analysis in Convex: $e');
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

  Future<bool> toggleFavorite(String dreamId) async {
    debugPrint('=== CONVEX TOGGLE FAVORITE ===');
    debugPrint('Dream ID: $dreamId');
    debugPrint('User ID: $_userId');
    
    if (!_isInitialized || _userId == null) {
      debugPrint('❌ ConvexService not initialized or userId null');
      return false;
    }

    try {
      final response = await _dio.post(
        '$_convexUrl/api/mutation',
        data: {
          'path': 'dreams:toggleFavorite',
          'args': {
            'id': dreamId, 
            'userId': _userId,
          },
        },
      );

      debugPrint('Toggle favorite response status: ${response.statusCode}');
      debugPrint('Toggle favorite response data: ${response.data}');

      if (response.statusCode == 200) {
        // Check if the response contains an error
        if (response.data is Map<String, dynamic> && 
            response.data['status'] == 'error') {
          debugPrint('❌ Convex API returned error: ${response.data['errorMessage']}');
          return false;
        } else {
          debugPrint('✅ Dream favorite status toggled successfully');
          return true;
        }
      } else {
        debugPrint('❌ Unexpected response status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error toggling favorite in Convex: $e');
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
    required String authId, // Firebase UID
    required String email,
    String? firstName,
    String? lastName,
    String? profileImageUrl,
  }) async {
    debugPrint('=== CONVEX UPSERT USER ===');
    debugPrint('ConvexService initialized: $_isInitialized');
    debugPrint('Convex URL: $_convexUrl');
    debugPrint('Auth ID: $authId');
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
        'authId': authId,
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

  // Upload image to Convex storage using proper upload flow
  Future<String?> uploadImage({
    required String base64Image,
    required String dreamId,
    required String userId,
  }) async {
    if (!_isInitialized) {
      return null;
    }

    try {
      debugPrint('=== CONVEX UPLOAD IMAGE ===');
      debugPrint('Dream ID: $dreamId');
      debugPrint('User ID: $userId');
      debugPrint('Base64 length: ${base64Image.length}');
      
      // Step 1: Get upload URL
      final uploadUrlResponse = await _dio.post(
        '$_convexUrl/api/mutation',
        data: {
          'path': 'dreams:generateUploadUrl',
          'args': {},
        },
      );

      if (uploadUrlResponse.statusCode != 200) {
        debugPrint('❌ Failed to generate upload URL');
        return null;
      }

      String uploadUrl;
      if (uploadUrlResponse.data is Map<String, dynamic> && 
          uploadUrlResponse.data['status'] == 'success') {
        uploadUrl = uploadUrlResponse.data['value'];
      } else {
        uploadUrl = uploadUrlResponse.data.toString();
      }
      
      debugPrint('✅ Got upload URL: $uploadUrl');

      // Step 2: Convert base64 to bytes
      final base64Data = base64Image.replaceAll(RegExp(r'^data:image\/[a-z]+;base64,'), '');
      final bytes = base64Decode(base64Data);
      
      debugPrint('Converted to bytes, length: ${bytes.length}');

      // Step 3: Upload file directly to Convex storage
      final uploadResponse = await _dio.post(
        uploadUrl,
        data: bytes,
        options: Options(
          headers: {
            'Content-Type': 'image/png',
          },
        ),
      );

      if (uploadResponse.statusCode != 200) {
        debugPrint('❌ Failed to upload image');
        return null;
      }

      final storageId = uploadResponse.data['storageId'];
      debugPrint('✅ Image uploaded, storage ID: $storageId');

      // Step 4: Update dream with storage ID
      final updateResponse = await _dio.post(
        '$_convexUrl/api/mutation',
        data: {
          'path': 'dreams:updateDreamWithImage',
          'args': {
            'dreamId': dreamId,
            'userId': userId,
            'storageId': storageId,
          },
        },
      );

      if (updateResponse.statusCode == 200) {
        debugPrint('✅ Dream updated with image storage ID');
        return storageId;
      } else {
        debugPrint('❌ Failed to update dream with image');
        return null;
      }
    } catch (e) {
      debugPrint('Error uploading image to Convex: $e');
    }

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

  /// Delete user account and all associated data from Convex
  Future<Map<String, dynamic>?> deleteAccount(String firebaseUid, String? _) async {
    debugPrint('=== CONVEX DELETE ACCOUNT ===');
    debugPrint('ConvexService initialized: $_isInitialized');
    debugPrint('Convex URL: $_convexUrl');
    debugPrint('Firebase UID: $firebaseUid');

    if (!_isInitialized) {
      debugPrint('ConvexService not initialized, aborting account deletion');
      return null;
    }

    try {
      final payload = {
        'authId': firebaseUid,
      };

      debugPrint('Delete account payload: $payload');

      final response = await _dio.post(
        '$_convexUrl/api/action',
        data: {
          'path': 'users:deleteAccount',
          'args': payload,
        },
      );

      debugPrint('Delete account response status: ${response.statusCode}');
      debugPrint('Delete account response data: ${response.data}');

      if (response.statusCode == 200) {
        if (response.data['error'] != null) {
          debugPrint('❌ Convex API returned error: ${response.data['error']}');
          return null;
        } else {
          debugPrint('✅ Account deleted successfully from Convex');
          return response.data as Map<String, dynamic>;
        }
      } else {
        debugPrint('❌ Unexpected response status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error deleting account from Convex: $e');
      if (e is DioException) {
        debugPrint('This is likely a network or API format issue');
      }
      return null;
    } finally {
      debugPrint('=== END CONVEX DELETE ACCOUNT ===');
    }
  }
}
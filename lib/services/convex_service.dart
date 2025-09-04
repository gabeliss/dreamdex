import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
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
    // You'll need to add your Convex deployment URL to .env
    _convexUrl = const String.fromEnvironment('CONVEX_URL');
    
    if (_convexUrl != null && _convexUrl!.isNotEmpty) {
      _isInitialized = true;
      notifyListeners();
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
          'function': 'dreams:list',
          'args': {'userId': _userId},
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((dreamJson) => Dream.fromJson(dreamJson)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching dreams from Convex: $e');
    }

    return [];
  }

  Future<String?> createDream(Dream dream) async {
    if (!_isInitialized || _userId == null) {
      return null;
    }

    try {
      final dreamData = dream.toJson();
      dreamData['userId'] = _userId;
      dreamData['_creationTime'] = DateTime.now().millisecondsSinceEpoch;

      final response = await _dio.post(
        '$_convexUrl/api/mutation',
        data: {
          'function': 'dreams:create',
          'args': dreamData,
        },
      );

      if (response.statusCode == 200) {
        return response.data['_id'];
      }
    } catch (e) {
      debugPrint('Error creating dream in Convex: $e');
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

      final response = await _dio.post(
        '$_convexUrl/api/mutation',
        data: {
          'function': 'dreams:update',
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
          'function': 'dreams:remove',
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
          'function': 'dreams:search',
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
          'function': 'dreams:stats',
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
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import '../models/dream.dart';
import 'convex_service.dart';

class DreamService extends ChangeNotifier {
  final ConvexService _convexService;
  
  List<Dream> _dreams = [];
  bool _isLoading = false;
  
  List<Dream> get dreams => _dreams;
  bool get isLoading => _isLoading;
  
  List<Dream> get recentDreams => _dreams.take(5).toList();
  List<Dream> get favoriteDreams => _dreams.where((d) => d.isFavorite).toList();

  DreamService(this._convexService, authService) {
    // Load dreams initially - Clerk handles auth state
    _loadDreams();
  }

  Future<void> _loadDreams() async {
    // Clerk handles auth state, so we can always try to load
    
    _isLoading = true;
    notifyListeners();
    
    try {
      _dreams = await _convexService.getDreams();
      _dreams.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      debugPrint('Error loading dreams: $e');
    }
    
    _isLoading = false;
    notifyListeners();
  }


  Future<void> addDream(Dream dream) async {
    try {
      final dreamId = await _convexService.createDream(dream);
      if (dreamId != null) {
        final savedDream = Dream(
          id: dreamId,
          title: dream.title,
          content: dream.content,
          rawTranscript: dream.rawTranscript,
          createdAt: dream.createdAt,
          type: dream.type,
          analysis: dream.analysis,
          aiGeneratedImageUrl: dream.aiGeneratedImageUrl,
          aiImagePrompt: dream.aiImagePrompt,
          isGeneratingImage: dream.isGeneratingImage,
          tags: dream.tags,
          isFavorite: dream.isFavorite,
        );
        _dreams.insert(0, savedDream);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error adding dream: $e');
      rethrow;
    }
  }

  Future<void> updateDream(Dream updatedDream) async {
    try {
      final success = await _convexService.updateDream(updatedDream);
      if (success) {
        final index = _dreams.indexWhere((d) => d.id == updatedDream.id);
        if (index != -1) {
          _dreams[index] = updatedDream;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error updating dream: $e');
      rethrow;
    }
  }

  Future<void> deleteDream(String dreamId) async {
    try {
      await _convexService.deleteDream(dreamId);
      _dreams.removeWhere((d) => d.id == dreamId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting dream: $e');
      rethrow;
    }
  }

  Future<void> toggleFavorite(String dreamId) async {
    final dream = _dreams.firstWhere((d) => d.id == dreamId);
    final updatedDream = dream.copyWith(isFavorite: !dream.isFavorite);
    await updateDream(updatedDream);
  }

  List<Dream> searchDreams(String query) {
    if (query.isEmpty) return _dreams;
    
    return _dreams.where((dream) {
      final searchLower = query.toLowerCase();
      return dream.title.toLowerCase().contains(searchLower) ||
             dream.content.toLowerCase().contains(searchLower) ||
             dream.tags.any((tag) => tag.toLowerCase().contains(searchLower));
    }).toList();
  }

  List<Dream> getDreamsByType(DreamType type) {
    return _dreams.where((dream) => dream.type == type).toList();
  }

  List<Dream> getDreamsByDateRange(DateTime start, DateTime end) {
    return _dreams.where((dream) {
      return dream.createdAt.isAfter(start) && dream.createdAt.isBefore(end);
    }).toList();
  }

  Map<String, int> getDreamStats() {
    return {
      'total': _dreams.length,
      'thisWeek': _dreams.where((d) {
        final weekAgo = DateTime.now().subtract(const Duration(days: 7));
        return d.createdAt.isAfter(weekAgo);
      }).length,
      'thisMonth': _dreams.where((d) {
        final monthAgo = DateTime.now().subtract(const Duration(days: 30));
        return d.createdAt.isAfter(monthAgo);
      }).length,
      'favorites': favoriteDreams.length,
    };
  }
}
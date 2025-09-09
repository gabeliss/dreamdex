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

  // Public method to refresh dreams (e.g., after authentication)
  Future<void> refreshDreams() async {
    await _loadDreams();
  }


  Future<Dream?> addDream(Dream dream) async {
    try {
      final dreamId = await _convexService.createDream(dream);
      if (dreamId != null) {
        final savedDream = Dream(
          id: dreamId,
          title: dream.title,
          content: dream.content,
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
        return savedDream;
      }
    } catch (e) {
      debugPrint('Error adding dream: $e');
      rethrow;
    }
    return null;
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
    try {
      // First update the local state optimistically
      final index = _dreams.indexWhere((d) => d.id == dreamId);
      if (index == -1) return;

      final dream = _dreams[index];
      final updatedDream = dream.copyWith(isFavorite: !dream.isFavorite);
      _dreams[index] = updatedDream;
      notifyListeners();

      // Then sync with backend
      final success = await _convexService.toggleFavorite(dreamId);
      if (!success) {
        // Revert on failure
        _dreams[index] = dream;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      // Find the dream again and revert
      final index = _dreams.indexWhere((d) => d.id == dreamId);
      if (index != -1) {
        final currentDream = _dreams[index];
        final revertedDream = currentDream.copyWith(isFavorite: !currentDream.isFavorite);
        _dreams[index] = revertedDream;
        notifyListeners();
      }
      rethrow;
    }
  }

  Future<void> updateDreamAnalysis(String dreamId, Map<String, dynamic> analysisData) async {
    try {
      final success = await _convexService.updateDreamAnalysis(dreamId, analysisData);
      if (success) {
        // Find the dream and update it locally
        final index = _dreams.indexWhere((d) => d.id == dreamId);
        if (index != -1) {
          final dream = _dreams[index];
          final analysis = DreamAnalysis.fromJson(analysisData);
          final updatedDream = dream.copyWith(analysis: analysis);
          _dreams[index] = updatedDream;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error updating dream analysis: $e');
      rethrow;
    }
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

  // Generate image for an existing dream
  Future<bool> generateImageForDream(String dreamId, String userId, String dreamDescription) async {
    try {
      // Update dream to show it's generating
      final dreamIndex = _dreams.indexWhere((d) => d.id == dreamId);
      if (dreamIndex == -1) return false;
      
      final dream = _dreams[dreamIndex];
      final updatingDream = dream.copyWith(isGeneratingImage: true);
      _dreams[dreamIndex] = updatingDream;
      notifyListeners();
      
      // Generate and store the image in Convex
      await _convexService.uploadImage(
        base64Image: dreamDescription, // This will be handled by AIService
        dreamId: dreamId,
        userId: userId,
      );
      
      // Refresh dreams to get the updated dream with image URL
      await _loadDreams();
      
      return true;
    } catch (e) {
      debugPrint('Error generating image for dream: $e');
      
      // Reset generating state on error
      final dreamIndex = _dreams.indexWhere((d) => d.id == dreamId);
      if (dreamIndex != -1) {
        final dream = _dreams[dreamIndex];
        final updatedDream = dream.copyWith(isGeneratingImage: false);
        _dreams[dreamIndex] = updatedDream;
        notifyListeners();
      }
      
      return false;
    }
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
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../models/dream.dart';
import '../services/dream_service.dart';
import '../services/speech_service.dart';
import '../services/ai_service.dart';
import '../services/convex_service.dart';
import '../services/subscription_service.dart';
import '../utils/dream_image_utils.dart';
import '../widgets/paywall_dialog.dart';

class AddDreamScreen extends StatefulWidget {
  const AddDreamScreen({super.key});

  @override
  State<AddDreamScreen> createState() => _AddDreamScreenState();
}

class _AddDreamScreenState extends State<AddDreamScreen>
    with TickerProviderStateMixin {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _titleFocusNode = FocusNode();
  final _contentFocusNode = FocusNode();
  final _scrollController = ScrollController();

  DreamType _selectedType = DreamType.normal;
  bool _isRecording = false;
  bool _isSaving = false;
  String? _generatedImageData; // Store base64 image data temporarily
  String _contentBeforeRecording = ''; // Store content before starting new recording
  String _displayTranscript = ''; // Store transcript for display beneath microphone
  late AnimationController _pulseController;
  late AnimationController _waveController;
  bool _hasContentText = false; // Track if content text exists for button state

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _waveController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Listen to content text changes to update button state
    _contentController.addListener(() {
      final hasText = _contentController.text.trim().isNotEmpty;
      if (_hasContentText != hasText) {
        setState(() {
          _hasContentText = hasText;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _adjustScrollForKeyboard();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _titleFocusNode.dispose();
    _contentFocusNode.dispose();
    _scrollController.dispose();
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  void _adjustScrollForKeyboard() {
    _titleFocusNode.addListener(() {
      if (_titleFocusNode.hasFocus) {
        _scrollToWidget(0);
      }
    });

    _contentFocusNode.addListener(() {
      if (_contentFocusNode.hasFocus) {
        _scrollToWidget(200);
      }
    });
  }

  void _scrollToWidget(double offset) {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          offset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            // Dismiss keyboard when tapping outside text fields
            FocusScope.of(context).unfocus();
          },
          child: Consumer3<SpeechService, DreamService, AIService>(
            builder: (context, speechService, dreamService, aiService, child) {
              // Handle automatic stop (when recording was active but speech service stopped)
              if (_isRecording && !speechService.isListening) {
                debugPrint('🔄 Auto-stop detected in Consumer. Text: "${speechService.transcribedText}"');
                debugPrint('🔄 Current display transcript: "$_displayTranscript"');
                
                // Use post-frame callback to avoid calling setState during build
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_isRecording && !speechService.isListening) {
                    setState(() {
                      _isRecording = false;
                      // Update display transcript and append to content (same logic as manual stop)
                      final newText = speechService.transcribedText.trim();
                      
                      // Update display transcript for beneath microphone
                      final oldDisplayTranscript = _displayTranscript;
                      if (_displayTranscript.isEmpty) {
                        _displayTranscript = newText;
                      } else if (newText.isNotEmpty) {
                        _displayTranscript = '$_displayTranscript $newText';
                      }
                      debugPrint('🔄 Updated display transcript from "$oldDisplayTranscript" to "$_displayTranscript"');
                      
                      // Update content field
                      if (_contentBeforeRecording.isEmpty) {
                        _contentController.text = newText;
                      } else if (newText.isNotEmpty) {
                        _contentController.text = '$_contentBeforeRecording $newText';
                      } else {
                        _contentController.text = _contentBeforeRecording;
                      }
                    });
                    _pulseController.stop();
                    _waveController.stop();
                  }
                });
              }
              
              return SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 30),
                  _buildVoiceRecordingSection(speechService),
                  const SizedBox(height: 30),
                  _buildDreamTypeSelector(),
                  const SizedBox(height: 20),
                  _buildTitleField(),
                  const SizedBox(height: 20),
                  _buildContentField(),
                  const SizedBox(height: 20),
                  _buildImageGenerationSection(aiService),
                  const SizedBox(height: 30),
                  _buildSaveButton(dreamService),
                  const SizedBox(height: 100),
                ],
              ),
            );
          },
        ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<SubscriptionService>(
      builder: (context, subscriptionService, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Capture Your Dream',
              style: Theme.of(context).textTheme.displayMedium,
            ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.2),
            const SizedBox(height: 8),
            Text(
              'Record your dream while it\'s fresh in your memory',
              style: Theme.of(context).textTheme.bodyMedium,
            ).animate().fadeIn(duration: 500.ms, delay: 100.ms).slideX(begin: -0.2),
            
            // Free user progress bar
            if (!subscriptionService.isPremium) ...[
              const SizedBox(height: 20),
              _buildFreeDreamProgress(subscriptionService),
            ],
          ],
        );
      },
    );
  }

  Widget _buildFreeDreamProgress(SubscriptionService subscriptionService) {
    debugPrint('=== BUILD FREE DREAM PROGRESS ===');
    return FutureBuilder<int>(
      future: subscriptionService.getFreeDreamCount(),
      builder: (context, snapshot) {
        debugPrint('FutureBuilder state: ${snapshot.connectionState}');
        debugPrint('FutureBuilder hasData: ${snapshot.hasData}');
        debugPrint('FutureBuilder data: ${snapshot.data}');
        debugPrint('FutureBuilder hasError: ${snapshot.hasError}');
        if (snapshot.hasError) {
          debugPrint('FutureBuilder error: ${snapshot.error}');
        }
        
        final currentCount = snapshot.data ?? 0;
        final maxCount = SubscriptionService.freeDreamLimit;
        final progress = currentCount / maxCount;
        
        debugPrint('Current count: $currentCount');
        debugPrint('Max count: $maxCount');
        debugPrint('Progress: $progress');
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cloudWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.shadowGrey.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Free Dreams Used',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$currentCount / $maxCount',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: currentCount >= maxCount 
                          ? AppColors.errorRed 
                          : AppColors.primaryPurple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.shadowGrey.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    currentCount >= maxCount 
                        ? AppColors.errorRed 
                        : AppColors.primaryPurple,
                  ),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                currentCount >= maxCount
                    ? 'Upgrade to Premium for unlimited dreams and AI analysis!'
                    : 'Upgrade to Premium for unlimited dreams and AI analysis',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.shadowGrey,
                ),
              ),
              if (currentCount >= maxCount) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => showPaywall(context, PremiumFeature.unlimitedDreams),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPurple,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Upgrade Now',
                      style: TextStyle(color: AppColors.cloudWhite),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ).animate().fadeIn(duration: 500.ms, delay: 150.ms).slideY(begin: 0.2);
      },
    );
  }

  Widget _buildVoiceRecordingSection(SpeechService speechService) {
    return Container(
      width: double.infinity, // Make container take full width
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.dreamGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            speechService.isListening 
                ? 'Listening...' 
                : 'Tap to record your dream',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.cloudWhite,
            ),
            textAlign: TextAlign.center,
          ).animate(target: speechService.isListening ? 1 : 0)
              .shimmer(duration: 1000.ms, color: AppColors.cloudWhite.withOpacity(0.3)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Clear button (only show if there's content to clear)
              if (_contentController.text.trim().isNotEmpty && !speechService.isListening) ...[
                GestureDetector(
                  onTap: _clearTranscript,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.cloudWhite.withOpacity(0.8),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.cloudWhite.withOpacity(0.2),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.clear,
                      size: 24,
                      color: AppColors.primaryPurple,
                    ),
                  ),
                ).animate().fadeIn(duration: 300.ms).scale(),
                const SizedBox(width: 20),
              ],
              // Main microphone button
              GestureDetector(
                onTap: () => _toggleRecording(speechService),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.cloudWhite,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.cloudWhite.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: speechService.isListening ? 10 : 0,
                      ),
                    ],
                  ),
                  child: Icon(
                    speechService.isListening ? Icons.stop : Icons.mic,
                    size: 36,
                    color: AppColors.primaryPurple,
                  ),
                ).animate(target: speechService.isListening ? 1 : 0)
                    .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1))
                    .then()
                    .shimmer(duration: 1500.ms, color: AppColors.cloudWhite.withOpacity(0.5)),
              ),
            ],
          ),
          if (_displayTranscript.isNotEmpty || speechService.isListening) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cloudWhite.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                speechService.isListening 
                    ? (_displayTranscript.isEmpty 
                        ? speechService.transcribedText 
                        : '$_displayTranscript ${speechService.transcribedText}')
                    : _displayTranscript,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.cloudWhite,
                ),
              ),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 200.ms).slideY(begin: 0.3);
  }

  Widget _buildDreamTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dream Type',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: DreamType.values.map((type) {
            final isSelected = _selectedType == type;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedType = type;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppColors.primaryPurple 
                      : AppColors.fogGrey,
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected 
                      ? null 
                      : Border.all(color: AppColors.mistGrey),
                ),
                child: Text(
                  _formatDreamType(type),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isSelected 
                        ? AppColors.cloudWhite 
                        : AppColors.shadowGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ).animate(target: isSelected ? 1 : 0)
                  .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05)),
            );
          }).toList(),
        ),
      ],
    ).animate().fadeIn(duration: 500.ms, delay: 300.ms).slideY(begin: 0.2);
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dream Title',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _titleController,
          focusNode: _titleFocusNode,
          decoration: const InputDecoration(
            hintText: 'Give your dream a title...',
          ),
          textCapitalization: TextCapitalization.words,
        ),
      ],
    ).animate().fadeIn(duration: 500.ms, delay: 400.ms).slideY(begin: 0.2);
  }

  Widget _buildContentField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dream Description',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _contentController,
          focusNode: _contentFocusNode,
          decoration: const InputDecoration(
            hintText: 'Describe your dream in detail...',
            alignLabelWithHint: true,
          ),
          maxLines: 8,
          textCapitalization: TextCapitalization.sentences,
        ),
      ],
    ).animate().fadeIn(duration: 500.ms, delay: 500.ms).slideY(begin: 0.2);
  }

  Widget _buildImageGenerationSection(AIService aiService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dream Visualization',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Generate an AI image to visualize your dream',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        if (_generatedImageData != null) ...[
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: MemoryImage(base64Decode(_generatedImageData!)),
                fit: BoxFit.cover,
              ),
            ),
          ).animate().fadeIn(duration: 500.ms).scale(),
          const SizedBox(height: 16),
        ],
        Consumer<SubscriptionService>(
          builder: (context, subscriptionService, child) {
            final isPremium = subscriptionService.isPremium;
            final isButtonDisabled = !_hasContentText ||
                                   aiService.isGeneratingImage ||
                                   !isPremium;
            
            return Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: isButtonDisabled
                        ? null
                        : () => _generateDreamImage(aiService),
                    icon: aiService.isGeneratingImage
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: isPremium ? AppColors.primaryPurple : Colors.grey,
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(
                            isPremium ? Icons.auto_awesome : Icons.lock,
                            color: isPremium ? AppColors.primaryPurple : Colors.grey,
                          ),
                    label: Text(
                      aiService.isGeneratingImage
                          ? 'Generating Image...'
                          : _generatedImageData != null
                              ? 'Regenerate Image'
                              : 'Generate Dream Image'
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isPremium ? AppColors.primaryPurple : Colors.grey,
                      side: BorderSide(color: isPremium ? AppColors.primaryPurple : Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                  ),
                ),
                if (!isPremium) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => showPaywall(context, PremiumFeature.imageGeneration),
                    child: Text(
                      'Tap to upgrade and unlock image generation',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primaryPurple,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    ).animate().fadeIn(duration: 500.ms, delay: 550.ms).slideY(begin: 0.2);
  }

  Widget _buildSaveButton(DreamService dreamService) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSaving ? null : () => _saveDream(dreamService),
        child: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: AppColors.cloudWhite,
                  strokeWidth: 2,
                ),
              )
            : const Text('Save Dream'),
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 600.ms).slideY(begin: 0.2);
  }

  Future<void> _toggleRecording(SpeechService speechService) async {
    if (speechService.isListening) {
      await speechService.stopListening();
      setState(() {
        _isRecording = false;
        // Update display transcript and append to content
        final newText = speechService.transcribedText.trim();
        
        // Update display transcript for beneath microphone
        if (_displayTranscript.isEmpty) {
          _displayTranscript = newText;
        } else if (newText.isNotEmpty) {
          _displayTranscript = '$_displayTranscript $newText';
        }
        
        // Update content field
        if (_contentBeforeRecording.isEmpty) {
          _contentController.text = newText;
        } else if (newText.isNotEmpty) {
          _contentController.text = '$_contentBeforeRecording $newText';
        } else {
          _contentController.text = _contentBeforeRecording;
        }
      });
      _pulseController.stop();
      _waveController.stop();
    } else {
      try {
        // Store the current content before starting recording
        _contentBeforeRecording = _contentController.text.trim();
        
        await speechService.startListening(
          onResult: (text) {
            setState(() {
              // During recording, show original content + new transcription
              final newText = text.trim();
              
              if (_contentBeforeRecording.isEmpty) {
                _contentController.text = newText;
              } else if (newText.isNotEmpty) {
                _contentController.text = '$_contentBeforeRecording $newText';
              } else {
                _contentController.text = _contentBeforeRecording;
              }
            });
          },
        );
        setState(() {
          _isRecording = true;
        });
        _pulseController.repeat();
        _waveController.repeat();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceFirst('Exception: ', '')),
              backgroundColor: AppColors.errorRed,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }

  void _clearTranscript() {
    setState(() {
      _contentController.clear();
      _displayTranscript = '';
      _contentBeforeRecording = '';
      _hasContentText = false;
    });
    final speechService = Provider.of<SpeechService>(context, listen: false);
    speechService.clearTranscription();
  }

  Future<void> _saveDream(DreamService dreamService) async {
    if (_titleController.text.trim().isEmpty || _contentController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please provide both a title and description for your dream.'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
      return;
    }

    // Check if free user has reached dream limit
    final subscriptionService = Provider.of<SubscriptionService>(context, listen: false);
    if (!subscriptionService.isPremium) {
      final canCreate = await subscriptionService.canCreateDream();
      if (!canCreate) {
        if (mounted) {
          // Show limit reached dialog with upgrade option
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Dream Limit Reached'),
              content: const Text(
                'You\'ve reached your free limit of 15 dreams. Upgrade to Premium for unlimited dreams and AI analysis!',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    showPaywall(context, PremiumFeature.unlimitedDreams);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                  ),
                  child: const Text('Upgrade Now'),
                ),
              ],
            ),
          );
        }
        return;
      }
    }

    setState(() {
      _isSaving = true;
    });

    final dream = Dream(
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      type: _selectedType,
    );

    final savedDream = await dreamService.addDream(dream);

    // Increment dream count for free users when dream is successfully saved
    if (savedDream != null) {
      await subscriptionService.incrementDreamCount();
    }

    // If we have generated image data and the dream was saved, store the image in Convex
    if (savedDream != null && _generatedImageData != null) {
      try {
        final convexService = Provider.of<ConvexService>(context, listen: false);
        await convexService.uploadImage(
          base64Image: _generatedImageData!,
          dreamId: savedDream.id,
          userId: convexService.userId!,
        );
        // Force refresh dreams to get updated image URLs
        await dreamService.forceRefresh();
      } catch (e) {
        debugPrint('Error storing image: $e');
        // Still show success for dream save, just mention image issue
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Dream saved, but image storage failed. You can regenerate it later.'),
              backgroundColor: AppColors.sunsetOrange,
            ),
          );
        }
      }
    }

    // Automatically analyze the dream content (premium users only)
    if (savedDream != null) {
      final subscriptionService = Provider.of<SubscriptionService>(context, listen: false);
      
      if (subscriptionService.isPremium) {
        try {
          if (!mounted) return;
          final aiService = Provider.of<AIService>(context, listen: false);
          final analysisData = await aiService.analyzeDream(_contentController.text.trim());
          
          if (analysisData != null) {
            debugPrint('✅ AI analysis received: ${analysisData.keys}');
            // Update the dream with analysis results
            await dreamService.updateDreamAnalysis(savedDream.id, analysisData);
            debugPrint('✅ Dream analysis saved to database successfully');
          } else {
            debugPrint('❌ Dream analysis failed - no data returned');
          }
        } catch (e) {
          debugPrint('Error during dream analysis: $e');
          // Analysis failure shouldn't prevent dream saving success
        }
      } else {
        debugPrint('🔒 AI analysis skipped - premium feature for free user');
      }
    }

    setState(() {
      _isSaving = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dream saved successfully!'),
          backgroundColor: AppColors.successGreen,
        ),
      );
    }

    _titleController.clear();
    _contentController.clear();
    setState(() {
      _selectedType = DreamType.normal;
      _generatedImageData = null;
      _displayTranscript = '';
      _contentBeforeRecording = '';
      _hasContentText = false;
    });
  }

  Future<void> _generateDreamImage(AIService aiService) async {
    final imageData = await DreamImageUtils.generateDreamImage(
      context: context,
      aiService: aiService,
      dreamContent: _contentController.text,
    );
    
    if (imageData != null) {
      setState(() {
        _generatedImageData = imageData;
      });
    }
  }

  String _formatDreamType(DreamType type) {
    return type.name.substring(0, 1).toUpperCase() + type.name.substring(1);
  }
}
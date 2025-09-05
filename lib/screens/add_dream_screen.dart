import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../models/dream.dart';
import '../services/dream_service.dart';
import '../services/speech_service.dart';
import '../services/ai_service.dart';

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
  String _rawTranscript = '';
  String? _generatedImagePath;
  late AnimationController _pulseController;
  late AnimationController _waveController;

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
      ],
    );
  }

  Widget _buildVoiceRecordingSection(SpeechService speechService) {
    return Container(
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
          if (speechService.transcribedText.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cloudWhite.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                speechService.transcribedText,
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
        if (_generatedImagePath != null) ...[
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: FileImage(File(_generatedImagePath!)),
                fit: BoxFit.cover,
              ),
            ),
          ).animate().fadeIn(duration: 500.ms).scale(),
          const SizedBox(height: 16),
        ],
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: (_contentController.text.trim().isEmpty || aiService.isGeneratingImage)
                ? null
                : () => _generateDreamImage(aiService),
            icon: aiService.isGeneratingImage
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: AppColors.primaryPurple,
                      strokeWidth: 2,
                    ),
                  )
                : Icon(Icons.auto_awesome),
            label: Text(
              aiService.isGeneratingImage
                  ? 'Generating Image...'
                  : _generatedImagePath != null
                      ? 'Regenerate Image'
                      : 'Generate Dream Image',
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryPurple,
              side: BorderSide(color: AppColors.primaryPurple),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
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
        _rawTranscript = speechService.transcribedText;
        _contentController.text = speechService.transcribedText;
      });
      _pulseController.stop();
      _waveController.stop();
    } else {
      try {
        await speechService.startListening(
          onResult: (text) {
            setState(() {
              _contentController.text = text;
              _rawTranscript = text;
            });
          },
        );
        setState(() {
          _isRecording = true;
        });
        _pulseController.repeat();
        _waveController.repeat();
      } catch (e) {
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

  Future<void> _saveDream(DreamService dreamService) async {
    if (_titleController.text.trim().isEmpty || _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide both a title and description for your dream.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final dream = Dream(
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      rawTranscript: _rawTranscript,
      type: _selectedType,
      aiGeneratedImageUrl: _generatedImagePath,
    );

    await dreamService.addDream(dream);

    setState(() {
      _isSaving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dream saved successfully!'),
        backgroundColor: AppColors.successGreen,
      ),
    );

    _titleController.clear();
    _contentController.clear();
    setState(() {
      _rawTranscript = '';
      _selectedType = DreamType.normal;
      _generatedImagePath = null;
    });
  }

  Future<void> _generateDreamImage(AIService aiService) async {
    if (_contentController.text.trim().isEmpty) return;

    try {
      final imagePath = await aiService.generateDreamImage(_contentController.text.trim());
      
      if (imagePath != null) {
        setState(() {
          _generatedImagePath = imagePath;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dream image generated successfully!'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to generate dream image. Please try again.'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating image: ${e.toString()}'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  String _formatDreamType(DreamType type) {
    return type.name.substring(0, 1).toUpperCase() + type.name.substring(1);
  }
}
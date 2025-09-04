import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../models/dream.dart';
import '../services/dream_service.dart';
import '../widgets/dream_image_widget.dart';

class DreamDetailScreen extends StatefulWidget {
  final Dream dream;

  const DreamDetailScreen({
    super.key,
    required this.dream,
  });

  @override
  State<DreamDetailScreen> createState() => _DreamDetailScreenState();
}

class _DreamDetailScreenState extends State<DreamDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _showRawTranscript = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.dream.analysis != null ? 3 : 2,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<DreamService>(
          builder: (context, dreamService, child) {
            return Column(
              children: [
                _buildAppBar(dreamService),
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildDreamTab(),
                      _buildRawTranscriptTab(),
                      if (widget.dream.analysis != null) _buildAnalysisTab(),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar(DreamService dreamService) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.dream.title,
                  style: Theme.of(context).textTheme.titleLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  DateFormat('MMM dd, yyyy • hh:mm a').format(widget.dream.createdAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              widget.dream.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: widget.dream.isFavorite ? AppColors.dreamPink : AppColors.shadowGrey,
            ),
            onPressed: () => dreamService.toggleFavorite(widget.dream.id),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteDialog(dreamService);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: AppColors.errorRed),
                    SizedBox(width: 8),
                    Text('Delete Dream'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2);
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.fogGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primaryPurple,
          borderRadius: BorderRadius.circular(10),
        ),
        labelColor: AppColors.cloudWhite,
        unselectedLabelColor: AppColors.shadowGrey,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        tabs: [
          const Tab(text: 'Dream'),
          const Tab(text: 'Transcript'),
          if (widget.dream.analysis != null) const Tab(text: 'Analysis'),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 100.ms).slideY(begin: -0.1);
  }

  Widget _buildDreamTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDreamTypeChip(),
          const SizedBox(height: 20),
          if (widget.dream.aiGeneratedImageUrl != null) ...[
            DreamImageWidget(
              imagePath: widget.dream.aiGeneratedImageUrl,
              height: 250,
            ),
            const SizedBox(height: 24),
          ],
          Text(
            'Description',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.ultraLightPurple,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.lightPurple),
            ),
            child: Text(
              widget.dream.content,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.6,
              ),
            ),
          ),
          if (widget.dream.tags.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Tags',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.dream.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.lightBlue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '#$tag',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.dreamBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 200.ms);
  }

  Widget _buildRawTranscriptTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.mic,
                color: AppColors.primaryPurple,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Voice Recording Transcript',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (widget.dream.rawTranscript.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.fogGrey,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                widget.dream.rawTranscript,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ] else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(
                    Icons.mic_off,
                    size: 48,
                    color: AppColors.shadowGrey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No voice transcript available',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This dream was entered manually',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 200.ms);
  }

  Widget _buildAnalysisTab() {
    final analysis = widget.dream.analysis!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAnalysisSection('Summary', analysis.summary, Icons.summarize),
          const SizedBox(height: 24),
          _buildAnalysisSection('Themes', analysis.themes.join(', '), Icons.category),
          const SizedBox(height: 24),
          _buildAnalysisSection('Characters', analysis.characters.join(', '), Icons.people),
          const SizedBox(height: 24),
          _buildAnalysisSection('Locations', analysis.locations.join(', '), Icons.location_on),
          const SizedBox(height: 24),
          _buildEmotionsSection(analysis.emotions),
          const SizedBox(height: 24),
          _buildScoresSection(analysis),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 200.ms);
  }

  Widget _buildAnalysisSection(String title, String content, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primaryPurple, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.ultraLightPurple,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.lightPurple),
          ),
          child: Text(
            content.isEmpty ? 'Not analyzed' : content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: content.isEmpty ? AppColors.shadowGrey : null,
              fontStyle: content.isEmpty ? FontStyle.italic : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmotionsSection(List<EmotionType> emotions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.mood, color: AppColors.primaryPurple, size: 20),
            const SizedBox(width: 8),
            Text(
              'Emotions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (emotions.isEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.ultraLightPurple,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.lightPurple),
            ),
            child: Text(
              'No emotions detected',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.shadowGrey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ] else ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: emotions.map((emotion) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getEmotionColor(emotion).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _getEmotionColor(emotion)),
                ),
                child: Text(
                  _formatEmotion(emotion),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _getEmotionColor(emotion),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildScoresSection(DreamAnalysis analysis) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.analytics, color: AppColors.primaryPurple, size: 20),
            const SizedBox(width: 8),
            Text(
              'Scores',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildScoreCard(
                'Lucidity',
                analysis.lucidityScore,
                AppColors.starYellow,
                Icons.lightbulb,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildScoreCard(
                'Emotional Intensity',
                analysis.emotionalIntensity,
                AppColors.dreamPink,
                Icons.favorite,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScoreCard(String title, double score, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            '${(score * 100).toInt()}%',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDreamTypeChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getDreamTypeColor(widget.dream.type).withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _getDreamTypeColor(widget.dream.type)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getDreamTypeIcon(widget.dream.type),
            size: 16,
            color: _getDreamTypeColor(widget.dream.type),
          ),
          const SizedBox(width: 6),
          Text(
            _formatDreamType(widget.dream.type),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: _getDreamTypeColor(widget.dream.type),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(DreamService dreamService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Dream'),
        content: const Text('Are you sure you want to delete this dream? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              dreamService.deleteDream(widget.dream.id);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.errorRed,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  IconData _getDreamTypeIcon(DreamType type) {
    switch (type) {
      case DreamType.lucid:
        return Icons.lightbulb;
      case DreamType.nightmare:
        return Icons.warning;
      case DreamType.recurring:
        return Icons.replay;
      case DreamType.prophetic:
        return Icons.visibility;
      case DreamType.healing:
        return Icons.healing;
      default:
        return Icons.bedtime;
    }
  }

  Color _getDreamTypeColor(DreamType type) {
    switch (type) {
      case DreamType.lucid:
        return AppColors.starYellow;
      case DreamType.nightmare:
        return AppColors.errorRed;
      case DreamType.recurring:
        return AppColors.dreamBlue;
      case DreamType.prophetic:
        return AppColors.secondaryPurple;
      case DreamType.healing:
        return AppColors.successGreen;
      default:
        return AppColors.shadowGrey;
    }
  }

  String _formatDreamType(DreamType type) {
    return type.name.substring(0, 1).toUpperCase() + type.name.substring(1);
  }

  Color _getEmotionColor(EmotionType emotion) {
    switch (emotion) {
      case EmotionType.joy:
        return AppColors.starYellow;
      case EmotionType.fear:
        return AppColors.errorRed;
      case EmotionType.love:
        return AppColors.dreamPink;
      case EmotionType.peace:
        return AppColors.successGreen;
      case EmotionType.excitement:
        return AppColors.sunsetOrange;
      default:
        return AppColors.primaryPurple;
    }
  }

  String _formatEmotion(EmotionType emotion) {
    return emotion.name.substring(0, 1).toUpperCase() + emotion.name.substring(1);
  }
}
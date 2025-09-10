import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../models/dream.dart';
import '../services/dream_service.dart';
import '../services/subscription_service.dart';
import '../services/ai_service.dart';
import '../widgets/dream_image_widget.dart';
import '../widgets/paywall_dialog.dart';

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
  bool _isGeneratingAnalysis = false;
  Dream? _currentDream;

  @override
  void initState() {
    super.initState();
    _currentDream = widget.dream;
    _tabController = TabController(
      length: 2,
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
                      _buildAnalysisTab(),
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
    // Get the current dream state from the service to reflect real-time changes
    final currentDream = dreamService.dreams.firstWhere(
      (d) => d.id == widget.dream.id,
      orElse: () => widget.dream,
    );

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
                  currentDream.title,
                  style: Theme.of(context).textTheme.titleLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  DateFormat('MMM dd, yyyy • hh:mm a').format(currentDream.createdAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              currentDream.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: currentDream.isFavorite ? AppColors.dreamPink : AppColors.shadowGrey,
            ),
            onPressed: () => dreamService.toggleFavorite(currentDream.id),
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
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: AppColors.cloudWhite,
        unselectedLabelColor: AppColors.shadowGrey,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        tabs: [
          const Tab(text: 'Dream'),
          const Tab(text: 'Analysis'),
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

  Widget _buildAnalysisTab() {
    final analysis = _currentDream?.analysis;
    
    if (analysis == null) {
      return Consumer<SubscriptionService>(
        builder: (context, subscriptionService, child) {
          final isPremium = subscriptionService.isPremium;
          
          if (_isGeneratingAnalysis) {
            // Show loading state when generating analysis
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 100),
                    CircularProgressIndicator(
                      color: AppColors.primaryPurple,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Analyzing your dream...',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Our AI is studying your dream content to provide insights',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 500.ms, delay: 200.ms);
          }
          
          // Show empty state with generate button
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 100),
                  Icon(
                    isPremium ? Icons.psychology : Icons.lock,
                    size: 64,
                    color: isPremium ? AppColors.primaryPurple : Colors.grey,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    isPremium ? 'No Analysis Yet' : 'Analysis Unavailable',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isPremium 
                        ? 'Generate an AI analysis to understand your dream\'s meaning'
                        : 'Dream analysis is a premium feature',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isPremium 
                          ? () => _generateAnalysis()
                          : null,
                      icon: Icon(
                        isPremium ? Icons.auto_awesome : Icons.lock,
                        color: isPremium ? AppColors.cloudWhite : Colors.grey,
                      ),
                      label: Text(
                        'Generate Dream Analysis',
                        style: TextStyle(
                          color: isPremium ? AppColors.cloudWhite : Colors.grey,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isPremium ? AppColors.primaryPurple : Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  if (!isPremium) ...[
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => showPaywall(context, PremiumFeature.aiAnalysis),
                      child: Text(
                        'Tap to upgrade and unlock dream analysis',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primaryPurple,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 200.ms);
        },
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAnalysisSection('Summary', analysis.summary, Icons.summarize),
          const SizedBox(height: 24),
          _buildAnalysisSection('Interpretation', analysis.interpretation, Icons.psychology),
          const SizedBox(height: 24),
          _buildAnalysisSection('Personal Reflection', analysis.personalReflection, Icons.self_improvement),
          const SizedBox(height: 24),
          if (analysis.symbolism.isNotEmpty) ...[
            _buildSymbolismSection(analysis.symbolism),
            const SizedBox(height: 24),
          ],
          if (analysis.possibleMeanings.isNotEmpty) ...[
            _buildPossibleMeaningsSection(analysis.possibleMeanings),
            const SizedBox(height: 24),
          ],
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

  Widget _buildSymbolismSection(List<DreamSymbol> symbolism) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.auto_awesome, color: AppColors.primaryPurple, size: 20),
            const SizedBox(width: 8),
            Text(
              'Symbolism',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...symbolism.map((symbol) => Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.ultraLightPurple,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.lightPurple),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                symbol.symbol,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryPurple,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                symbol.meaning,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildPossibleMeaningsSection(List<String> meanings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.lightbulb_outline, color: AppColors.primaryPurple, size: 20),
            const SizedBox(width: 8),
            Text(
              'Possible Meanings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...meanings.map((meaning) => Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.ultraLightPurple,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.lightPurple),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(top: 8, right: 12),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Text(
                  meaning,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }

  Future<void> _generateAnalysis() async {
    setState(() {
      _isGeneratingAnalysis = true;
    });

    try {
      final aiService = Provider.of<AIService>(context, listen: false);
      final dreamService = Provider.of<DreamService>(context, listen: false);
      
      final analysisData = await aiService.analyzeDream(_currentDream!.content);
      
      if (analysisData != null && mounted) {
        debugPrint('✅ AI analysis received: ${analysisData.keys}');
        // Update the dream with analysis results
        await dreamService.updateDreamAnalysis(_currentDream!.id, analysisData);
        debugPrint('✅ Dream analysis saved to database successfully');
        
        // Update the current dream with the new analysis data
        if (mounted) {
          setState(() {
            _currentDream = _currentDream!.copyWith(
              analysis: DreamAnalysis.fromJson(analysisData),
            );
          });
        }
        
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Dream analysis generated successfully!'),
              backgroundColor: AppColors.primaryPurple,
            ),
          );
        }
      } else {
        debugPrint('❌ Dream analysis failed - no data returned');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to generate analysis. Please try again.'),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error during dream analysis: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error generating analysis. Please try again.'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingAnalysis = false;
        });
      }
    }
  }
}
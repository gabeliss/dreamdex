import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_colors.dart';
import '../services/dream_service.dart';
import '../models/dream.dart';
import '../widgets/dream_card.dart';
import '../widgets/stats_card.dart';
import 'dream_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            // Dismiss keyboard when tapping outside
            FocusScope.of(context).unfocus();
          },
          child: Consumer<DreamService>(
            builder: (context, dreamService, child) {
              final dreams = _searchQuery.isEmpty
                  ? dreamService.dreams
                  : dreamService.searchDreams(_searchQuery);

              return CustomScrollView(
                slivers: [
                  _buildHeader(dreamService),
                  if (dreamService.dreams.isNotEmpty) _buildStats(dreamService),
                  _buildSearchBar(),
                  _buildDreamsList(dreams, dreamService),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(DreamService dreamService) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            final user = snapshot.data;
            final fullName = user?.displayName ?? 
                             user?.email?.split('@')[0] ?? 
                             'Dreamer';
            final userName = fullName.split(' ')[0];
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good ${_getTimeOfDayGreeting()}, $userName',
                  style: Theme.of(context).textTheme.titleMedium,
                ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.2),
                const SizedBox(height: 8),
                Text(
                  'Your Dream Journal',
                  style: Theme.of(context).textTheme.displayMedium,
                ).animate().fadeIn(duration: 500.ms, delay: 100.ms).slideX(begin: -0.2),
                if (dreamService.dreams.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${dreamService.dreams.length} dreams captured',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ).animate().fadeIn(duration: 500.ms, delay: 200.ms).slideX(begin: -0.2),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStats(DreamService dreamService) {
    final stats = dreamService.getDreamStats();
    
    return SliverToBoxAdapter(
      child: Container(
        height: 120,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: AnimationLimiter(
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            itemBuilder: (context, index) {
              final statsData = [
                {'title': 'Total Dreams', 'value': stats['total']!, 'icon': Icons.auto_stories},
                {'title': 'This Week', 'value': stats['thisWeek']!, 'icon': Icons.calendar_today},
                {'title': 'This Month', 'value': stats['thisMonth']!, 'icon': Icons.calendar_month},
                {'title': 'Favorites', 'value': stats['favorites']!, 'icon': Icons.favorite},
              ];

              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  horizontalOffset: 50.0,
                  child: FadeInAnimation(
                    child: StatsCard(
                      title: statsData[index]['title'] as String,
                      value: statsData[index]['value'] as int,
                      icon: statsData[index]['icon'] as IconData,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Search your dreams...',
            prefixIcon: const Icon(Icons.search, color: AppColors.shadowGrey),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: AppColors.shadowGrey),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                : null,
          ),
        ).animate().fadeIn(duration: 500.ms, delay: 300.ms).slideY(begin: 0.2),
      ),
    );
  }

  Widget _buildDreamsList(List<Dream> dreams, DreamService dreamService) {
    if (dreamService.isLoading) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(50),
            child: CircularProgressIndicator(
              color: AppColors.primaryPurple,
            ),
          ),
        ),
      );
    }

    if (dreams.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(50),
            child: Column(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    gradient: AppColors.dreamGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.bedtime,
                    size: 60,
                    color: AppColors.cloudWhite,
                  ),
                ).animate().scale(duration: 500.ms),
                const SizedBox(height: 24),
                Text(
                  _searchQuery.isEmpty ? 'No dreams yet' : 'No dreams found',
                  style: Theme.of(context).textTheme.headlineMedium,
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 12),
                Text(
                  _searchQuery.isEmpty
                      ? 'Start capturing your dreams and let AI help you understand them'
                      : 'Try a different search term',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 300.ms),
              ],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final dream = dreams[index];
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: DreamCard(
                      dream: dream,
                      onTap: () => _navigateToDreamDetail(dream),
                      onFavoriteToggle: () => dreamService.toggleFavorite(dream.id),
                    ),
                  ),
                ),
              ),
            );
          },
          childCount: dreams.length,
        ),
      ),
    );
  }

  void _navigateToDreamDetail(Dream dream) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            DreamDetailScreen(dream: dream),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                  .chain(CurveTween(curve: Curves.easeInOut)),
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  String _getTimeOfDayGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }
}
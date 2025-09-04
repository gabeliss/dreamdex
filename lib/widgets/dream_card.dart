import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../models/dream.dart';

class DreamCard extends StatelessWidget {
  final Dream dream;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const DreamCard({
    super.key,
    required this.dream,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _getDreamTypeIcon(dream.type),
                              size: 16,
                              color: _getDreamTypeColor(dream.type),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _formatDreamType(dream.type),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: _getDreamTypeColor(dream.type),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          dream.title,
                          style: Theme.of(context).textTheme.titleLarge,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      dream.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: dream.isFavorite ? AppColors.dreamPink : AppColors.shadowGrey,
                    ),
                    onPressed: onFavoriteToggle,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                dream.content,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: AppColors.shadowGrey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM dd, yyyy • hh:mm a').format(dream.createdAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  if (dream.analysis != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.lightBlue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.psychology,
                            size: 12,
                            color: AppColors.dreamBlue,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Analyzed',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.dreamBlue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              if (dream.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: dream.tags.take(3).map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.ultraLightPurple,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '#$tag',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primaryPurple,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
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
}
import 'package:flutter/material.dart';
import '../../models/notification_model.dart';
import '../theme/colors.dart';
import '../constants/dimensions.dart';
import '../utils/formatters.dart';
import 'robinhood_card.dart';

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    this.onTap,
  });

  IconData get _icon {
    switch (notification.type) {
      case 'profit':
        return Icons.trending_up_rounded;
      case 'investment':
        return Icons.savings_outlined;
      case 'goal':
        return Icons.flag_rounded;
      case 'kyc':
        return Icons.verified_user_outlined;
      case 'market':
        return Icons.show_chart_rounded;
      case 'referral':
        return Icons.card_giftcard_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: RobinhoodCard(
        glow: !notification.isRead,
        glowColor: AppColors.green,
        onTap: onTap,
        padding: const EdgeInsets.all(AppDimensions.paddingMd),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.green.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_icon, color: AppColors.green, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w700,
                              ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    DateFormatter.displayWithTime(notification.date),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hanouty/app_colors.dart';

import '../../../../Core/theme/AppColors.dart';

class MarketDescription extends StatelessWidget {
  final bool isDesktop;

  const MarketDescription({
    super.key,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = !isDesktop && MediaQuery.of(context).size.width >= 768;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ClientColors.primary.withOpacity(0.1), // Subtle border
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: ClientColors.primary.withOpacity(0.05), // Very subtle shadow
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.store_outlined,
                color: ClientColors.primary, // Updated icon color
                size: isDesktop ? 24 : 20,
              ),
              const SizedBox(width: 8),
              Text(
                "About This Market",
                style: TextStyle(
                  fontSize: isDesktop ? 22 : (isTablet ? 20 : 18),
                  fontWeight: FontWeight.bold,
                  color: ClientColors.text, // Updated text color
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Welcome to our local market where we provide fresh produce and quality goods direct from local farmers and artisans. Our market is committed to bringing you the best seasonal items at fair prices.',
            style: TextStyle(
              fontSize: isDesktop ? 16 : 14,
              color: ClientColors.textLight, // Updated text color
              height: 1.6, // Slightly increased line height for readability
            ),
          ),
          const SizedBox(height: 16),
          // Market features
          _buildFeatureRow(
            icon: Icons.timer_outlined,
            text: 'Fast Delivery - within 25 minutes',
          ),
          const SizedBox(height: 8),
          _buildFeatureRow(
            icon: Icons.agriculture_outlined,
            text: 'Fresh Produce - sourced daily',
          ),
          const SizedBox(height: 8),
          _buildFeatureRow(
            icon: Icons.eco_outlined,
            text: 'Eco Friendly - sustainable practices',
          ),
          const SizedBox(height: 12),
          // Special tag
          Align(
            alignment: Alignment.topRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: ClientColors.background, // Light background
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: ClientColors.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Text(
                'Open since 2020',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: ClientColors.primary, // Updated text color
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(
          icon,
          color: ClientColors.secondary, // Updated icon color
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: ClientColors.text, // Updated text color
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
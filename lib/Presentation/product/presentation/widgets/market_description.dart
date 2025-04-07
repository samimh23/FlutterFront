import 'package:flutter/material.dart';
import 'package:hanouty/app_colors.dart';

class MarketDescription extends StatelessWidget {
  final bool isDesktop;

  const MarketDescription({
    super.key,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = !isDesktop && MediaQuery.of(context).size.width >= 768;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "About",
          style: TextStyle(
            fontSize: isDesktop ? 22 : (isTablet ? 20 : 18),
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'good market',
          style: TextStyle(
            fontSize: isDesktop ? 16 : 14,
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
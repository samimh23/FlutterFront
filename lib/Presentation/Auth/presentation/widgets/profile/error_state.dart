import 'package:flutter/material.dart';
import 'package:hanouty/Presentation/Auth/presentation/controller/profilep%5Erovider.dart';

class ProfileErrorState extends StatelessWidget {
  final ProfileProvider provider;
  final VoidCallback onRetry;

  const ProfileErrorState({
    Key? key,
    required this.provider,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 768;
    
    return Center(
      child: Container(
        width: isWeb ? 500 : double.infinity,
        padding: EdgeInsets.all(isWeb ? 40.0 : 24.0),
        margin: EdgeInsets.all(isWeb ? 24.0 : 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isWeb ? 24 : 16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(isWeb ? 24 : 16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: isWeb ? 80 : 60,
                color: Colors.red,
              ),
            ),
            SizedBox(height: isWeb ? 32 : 24),
            Text(
              'Error Loading Profile',
              style: TextStyle(
                fontSize: isWeb ? 28 : 20,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade800,
              ),
            ),
            SizedBox(height: isWeb ? 16 : 12),
            Text(
              provider.errorMessage ?? "Unknown error occurred",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isWeb ? 18 : 16,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: isWeb ? 32 : 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(
                'Retry',
                style: TextStyle(
                  fontSize: isWeb ? 18 : 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: isWeb ? 32 : 24,
                  vertical: isWeb ? 16 : 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isWeb ? 12 : 8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
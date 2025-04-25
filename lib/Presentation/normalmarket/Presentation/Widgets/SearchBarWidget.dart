// lib/Presentation/order/presentation/Page/widgets/search_bar.dart

import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final bool isSmallScreen;
  final bool isDarkMode;
  final Color bgColor;
  final Color borderColor;
  final Color hintColor;
  final Color accentColor;
  final bool isSearching;
  final TextEditingController searchController;
  final Function(String) onChanged;
  final VoidCallback onClear;

  const SearchBarWidget({
    Key? key,
    required this.isSmallScreen,
    required this.isDarkMode,
    required this.bgColor,
    required this.borderColor,
    required this.hintColor,
    required this.accentColor,
    required this.isSearching,
    required this.searchController,
    required this.onChanged,
    required this.onClear,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : 16,
        vertical: isSmallScreen ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            isSearching ? Icons.search : Icons.search_outlined,
            color: isSearching ? accentColor : (isDarkMode ? Colors.grey.shade500 : const Color(0xFF888888)),
            size: isSmallScreen ? 18 : 24,
          ),
          SizedBox(width: isSmallScreen ? 8 : 12),
          Expanded(
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search markets...',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: hintColor,
                  fontSize: isSmallScreen ? 14 : 16,
                ),
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
              onChanged: onChanged,
              onTap: () {
                if (searchController.text.isNotEmpty) {
                  onChanged(searchController.text);
                }
              },
              onSubmitted: onChanged,
            ),
          ),
          if (isSearching)
            IconButton(
              icon: Icon(Icons.close, size: isSmallScreen ? 18 : 20),
              color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600,
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(
                minWidth: isSmallScreen ? 32 : 40,
                minHeight: isSmallScreen ? 32 : 40,
              ),
              onPressed: onClear,
            )
          else
            Container(
              height: isSmallScreen ? 24 : 30,
              width: 1,
              color: borderColor,
              margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 12),
            ),
          if (!isSearching)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 8 : 12,
                vertical: isSmallScreen ? 4 : 6,
              ),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.filter_alt_outlined,
                    size: isSmallScreen ? 14 : 16,
                    color: accentColor,
                  ),
                  SizedBox(width: isSmallScreen ? 4 : 6),
                  Text(
                    'Filters',
                    style: TextStyle(
                      color: accentColor,
                      fontSize: isSmallScreen ? 12 : 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:hanouty/Presentation/product/presentation/pages/category_products_screen.dart';
import 'package:hanouty/app_colors.dart';

class CategoriesSection extends StatelessWidget {
  const CategoriesSection({super.key});

  // Categories list
  final List<Map<String, dynamic>> categories = const [
    {
      'title': 'All',
      'image': 'assets/icons/flame.png',
    },
    {
      'title': 'Sweets',
      'image': 'assets/icons/sweets.png',
    },
    {
      'title': 'Drinks',
      'image': 'assets/icons/drinks.png',
    },
    {
      'title': 'Vegetables',
      'image': 'assets/icons/vegies.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 24.0, top: 16.0, bottom: 8.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Categories',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 100,
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Calculate item width based on available width
              final availableWidth = constraints.maxWidth;
              final itemWidth = (availableWidth - 32) / categories.length;
              
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: itemWidth,
                    child: Center(
                      child: CategoryItem(
                        title: categories[index]['title'],
                        image: categories[index]['image'],
                        onTap: () {
                          // Navigate to the category screen, passing the chosen category title
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CategoryProductsScreen(
                                category: categories[index]['title'],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class CategoryItem extends StatefulWidget {
  final String title;
  final String image;
  final VoidCallback onTap;

  const CategoryItem({
    super.key,
    required this.title,
    required this.image,
    required this.onTap,
  });

  @override
  State<CategoryItem> createState() => _CategoryItemState();
}

class _CategoryItemState extends State<CategoryItem> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isHovered ? 75 : 70,
              height: isHovered ? 75 : 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                
                image: DecorationImage(
                  image: AssetImage(widget.image),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isHovered ? FontWeight.bold : FontWeight.w500,
                color: isHovered ? AppColors.black : AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
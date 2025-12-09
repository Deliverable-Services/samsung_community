import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../helper_widgets/bottom_nav_bar.dart';
import '../helper_widgets/custom_app_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: CustomAppBar(
                totalPoints: 1200,
                onNotificationPressed: () {
                  // TODO: Handle notifications tap
                },
                onMenuPressed: () {
                  // TODO: Handle menu tap
                },
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Home',
                      style: const TextStyle(
                        fontFamily: 'Rubik',
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.0,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Scrollable content goes here. Add your sections, lists, '
                      'and cards inside this area. It will scroll while the '
                      'header and bottom navigation stay fixed.',
                      style: TextStyle(
                        fontFamily: 'Rubik',
                        fontSize: 14,
                        letterSpacing: 0.0,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Example placeholder cards to demonstrate scrolling.
                    ...List.generate(8, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.buttonGrey.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Item ${index + 1}',
                                      style: const TextStyle(
                                        fontFamily: 'Rubik',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'This is a sample description for the home item.',
                                      style: TextStyle(
                                        fontFamily: 'Rubik',
                                        fontSize: 13,
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(
                                Icons.chevron_right,
                                color: AppColors.white,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: BottomNavBar(
          items: [
            BottomNavItemData(
              icon: const Icon(
                Icons.home_filled,
                color: AppColors.white,
                size: 24,
              ),
              label: 'Home',
            ),
            BottomNavItemData(
              icon: const Icon(Icons.explore, color: AppColors.white, size: 24),
              label: 'Explore',
            ),
            BottomNavItemData(
              icon: const Icon(Icons.person, color: AppColors.white, size: 24),
              label: 'Profile',
            ),
          ],
          currentIndex: _currentIndex,
          onItemSelected: (index) {
            setState(() => _currentIndex = index);
            // TODO: Handle bottom navigation item changes here.
          },
        ),
      ),
    );
  }
}

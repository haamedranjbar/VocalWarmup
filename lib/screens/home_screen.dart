import 'package:flutter/material.dart';
import '../models/warmup.dart';
import '../data/warmup_data.dart';
import '../theme/app_theme.dart';
import '../widgets/warmup_card.dart';
import '../widgets/filter_chip_widget.dart';
import 'player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FilterType selectedFilter = FilterType.all;

  List<Warmup> get filteredWarmups {
    final allWarmups = WarmupData.getWarmups();
    if (selectedFilter == FilterType.all) {
      return allWarmups;
    }

    final difficultyMap = {
      FilterType.beginner: Difficulty.beginner,
      FilterType.intermediate: Difficulty.intermediate,
      FilterType.advanced: Difficulty.advanced,
    };

    return allWarmups
        .where((w) => w.difficulty == difficultyMap[selectedFilter])
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              decoration: BoxDecoration(
                color: (isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight)
                    .withOpacity(0.95),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Top bar with profile and icons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Profile avatar
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [AppTheme.primaryColor, Colors.purple],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.3),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.backgroundDark,
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      // Search and notifications
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.search),
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.notifications_outlined),
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Title
                  Align(
                    alignment: Alignment.centerLeft,
                    child: RichText(
                      text: TextSpan(
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 36,
                          height: 1.2,
                        ),
                        children: [
                          const TextSpan(text: 'Vocal\n'),
                          TextSpan(
                            text: 'Warmups',
                            style: TextStyle(color: AppTheme.primaryColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Filter chips
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChipWidget(
                      filterType: FilterType.all,
                      isSelected: selectedFilter == FilterType.all,
                      onTap: () => setState(() => selectedFilter = FilterType.all),
                      label: 'All',
                    ),
                    const SizedBox(width: 12),
                    FilterChipWidget(
                      filterType: FilterType.beginner,
                      isSelected: selectedFilter == FilterType.beginner,
                      onTap: () =>
                          setState(() => selectedFilter = FilterType.beginner),
                      label: 'Beginner',
                    ),
                    const SizedBox(width: 12),
                    FilterChipWidget(
                      filterType: FilterType.intermediate,
                      isSelected: selectedFilter == FilterType.intermediate,
                      onTap: () =>
                          setState(() => selectedFilter = FilterType.intermediate),
                      label: 'Intermediate',
                    ),
                    const SizedBox(width: 12),
                    FilterChipWidget(
                      filterType: FilterType.advanced,
                      isSelected: selectedFilter == FilterType.advanced,
                      onTap: () =>
                          setState(() => selectedFilter = FilterType.advanced),
                      label: 'Advanced',
                    ),
                  ],
                ),
              ),
            ),
            // Warmup list
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
                itemCount: filteredWarmups.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final warmup = filteredWarmups[index];
                  return WarmupCard(
                    warmup: warmup,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PlayerScreen(warmup: warmup),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: (isDark
                  ? const Color(0xFF151520)
                  : Colors.white)
              .withOpacity(0.9),
          border: Border(
            top: BorderSide(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : const Color(0xFFE2E8F0),
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context,
                  icon: Icons.library_music,
                  label: 'Library',
                  isSelected: true,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.favorite_outline,
                  label: 'Favorites',
                  isSelected: false,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  isSelected: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primaryColor.withOpacity(0.1)
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isSelected
                  ? AppTheme.primaryColor
                  : theme.colorScheme.onSurface.withOpacity(0.5),
              size: 28,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? AppTheme.primaryColor
                  : theme.colorScheme.onSurface.withOpacity(0.5),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}




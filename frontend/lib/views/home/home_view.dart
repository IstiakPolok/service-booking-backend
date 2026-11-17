import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/service_provider.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/error_state_widget.dart';
import '../../widgets/loading_indicator.dart';
import 'widgets/category_chip_list.dart';
import 'widgets/featured_carousel.dart';
import 'widgets/service_card.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
      if (serviceProvider.services.isEmpty) {
        serviceProvider.fetchInitialData();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final serviceProvider = Provider.of<ServiceProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => serviceProvider.refresh(),
          color: AppColors.primary,
          child: CustomScrollView(
            slivers: [
              // Top Bar with Greeting
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, ${user?.name.split(' ').first ?? 'Customer'} 👋',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'What service do you need today?',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.primary.withAlpha(30),
                        backgroundImage: user?.avatar != null ? NetworkImage(user!.avatar!) : null,
                        child: user?.avatar == null
                            ? const Icon(Icons.person, color: AppColors.primary)
                            : null,
                      ),
                    ],
                  ),
                ),
              ),

              // Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => serviceProvider.setSearchQuery(val),
                    decoration: InputDecoration(
                      hintText: 'Search services, haircuts, massage...',
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
                      suffixIcon: serviceProvider.searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 20),
                              onPressed: () {
                                _searchController.clear();
                                serviceProvider.clearSearch();
                              },
                            )
                          : null,
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // Featured Carousel (shown only if not searching)
              if (serviceProvider.searchQuery.isEmpty && serviceProvider.selectedCategory == 'All')
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: FeaturedCarousel(
                      featuredServices: serviceProvider.featuredServices,
                    ),
                  ),
                ),

              // Categories Header & Chips
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Categories',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    CategoryChipList(
                      categories: serviceProvider.categories,
                      selectedCategory: serviceProvider.selectedCategory,
                      onSelected: (cat) => serviceProvider.selectCategory(cat),
                    ),
                    const SizedBox(height: 18),
                  ],
                ),
              ),

              // Services Section Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        serviceProvider.selectedCategory == 'All'
                            ? 'All Services'
                            : '${serviceProvider.selectedCategory} Services',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${serviceProvider.filteredServices.length} found',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 8)),

              // Body content: Loading, Error, Empty, or Services List
              if (serviceProvider.isLoading && serviceProvider.services.isEmpty)
                const SliverFillRemaining(
                  child: LoadingIndicator(message: 'Loading available services...'),
                )
              else if (serviceProvider.errorMessage != null && serviceProvider.services.isEmpty)
                SliverFillRemaining(
                  child: ErrorStateWidget(
                    message: serviceProvider.errorMessage!,
                    onRetry: () => serviceProvider.fetchInitialData(),
                  ),
                )
              else if (serviceProvider.filteredServices.isEmpty)
                SliverFillRemaining(
                  child: EmptyStateWidget(
                    icon: Icons.search_off_rounded,
                    title: 'No Services Found',
                    description: 'We couldn’t find any services matching your criteria. Try adjusting your search or category filter.',
                    buttonText: 'Reset Filters',
                    onButtonPressed: () {
                      _searchController.clear();
                      serviceProvider.clearSearch();
                      serviceProvider.selectCategory('All');
                    },
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final service = serviceProvider.filteredServices[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: ServiceCard(service: service),
                        );
                      },
                      childCount: serviceProvider.filteredServices.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

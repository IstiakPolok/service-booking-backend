import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/appointment_provider.dart';
import 'ai_assistant/ai_chat_view.dart';
import 'home/home_view.dart';
import 'my_bookings/my_bookings_view.dart';
import 'profile/profile_view.dart';

class MainNavigationView extends StatefulWidget {
  final int initialIndex;

  const MainNavigationView({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationView> createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView> {
  late int _currentIndex;

  final List<Widget> _views = const [
    HomeView(),
    MyBookingsView(),
    AiChatView(),
    ProfileView(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final appointmentProvider = Provider.of<AppointmentProvider>(context);
    final upcomingCount = appointmentProvider.upcomingCount;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _views,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: AppColors.border, width: 0.8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(6),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          backgroundColor: Colors.white,
          indicatorColor: AppColors.primary.withAlpha(25),
          elevation: 0,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded, color: AppColors.primary),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: upcomingCount > 0,
                label: Text('$upcomingCount'),
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.calendar_month_outlined),
              ),
              selectedIcon: Badge(
                isLabelVisible: upcomingCount > 0,
                label: Text('$upcomingCount'),
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.calendar_month_rounded, color: AppColors.primary),
              ),
              label: 'Bookings',
            ),
            const NavigationDestination(
              icon: Icon(Icons.auto_awesome_outlined),
              selectedIcon: Icon(Icons.auto_awesome_rounded, color: AppColors.primary),
              label: 'AI Assistant',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded, color: AppColors.primary),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

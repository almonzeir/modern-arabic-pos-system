
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/pos_provider.dart';
import 'screens/cashier_screen.dart';
import 'screens/admin_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => POSProvider()..fetchMenu(),
      child: const SilverPOSApp(),
    ),
  );
}

class SilverPOSApp extends StatelessWidget {
  const SilverPOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'نظام المبيعات الحديث',
      locale: const Locale('ar', 'SA'),
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.indigoAccent,
        scaffoldBackgroundColor: const Color(0xFFF0F2F5), // Soft clean grey background
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(color: Color(0xFF2D3436), fontSize: 20, fontWeight: FontWeight.bold),
          iconTheme: IconThemeData(color: Color(0xFF2D3436)),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.05),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3436)),
          bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF2D3436)),
        ),
      ),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const CashierScreen(),
    const AdminScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar: Clean White Navigation
          Container(
            width: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(left: BorderSide(color: Colors.grey.withOpacity(0.1))),
            ),
            child: NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                setState(() => _selectedIndex = index);
              },
              labelType: NavigationRailLabelType.all,
              backgroundColor: Colors.white,
              unselectedIconTheme: const IconThemeData(color: Colors.grey, size: 28),
              selectedIconTheme: const IconThemeData(color: Colors.indigoAccent, size: 32),
              unselectedLabelTextStyle: const TextStyle(color: Colors.grey, fontSize: 12),
              selectedLabelTextStyle: const TextStyle(color: Colors.indigoAccent, fontWeight: FontWeight.bold, fontSize: 13),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.grid_view_rounded),
                  label: Text('المبيعات'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.inventory_2_outlined),
                  label: Text('الأصناف'),
                ),
              ],
            ),
          ),
          Expanded(child: _screens[_selectedIndex]),
        ],
      ),
    );
  }
}

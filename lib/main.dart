
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
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
        scaffoldBackgroundColor: const Color(0xFFF8F9FA), 
        textTheme: GoogleFonts.cairoTextTheme(ThemeData.light().textTheme).copyWith(
          headlineMedium: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: const Color(0xFF2D3436)),
          bodyLarge: GoogleFonts.cairo(fontSize: 16, color: const Color(0xFF2D3436)),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: GoogleFonts.cairo(color: const Color(0xFF2D3436), fontSize: 20, fontWeight: FontWeight.bold),
          iconTheme: const IconThemeData(color: Color(0xFF2D3436)),
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
    final pos = context.watch<POSProvider>();
    
    return Scaffold(
      body: Row(
        children: [
          // Sidebar: Professional White Navigation
          Container(
            width: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(5, 0),
                )
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 40),
                // Logo placeholder or Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.indigoAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Icon(Icons.storefront_rounded, color: Colors.indigoAccent, size: 32),
                  ),
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: NavigationRail(
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: (int index) {
                      setState(() => _selectedIndex = index);
                    },
                    labelType: NavigationRailLabelType.all,
                    backgroundColor: Colors.white,
                    unselectedIconTheme: const IconThemeData(color: Colors.grey, size: 28),
                    selectedIconTheme: const IconThemeData(color: Colors.indigoAccent, size: 32),
                    unselectedLabelTextStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                    selectedLabelTextStyle: const TextStyle(color: Colors.indigoAccent, fontWeight: FontWeight.bold, fontSize: 14),
                    destinations: const [
                      NavigationRailDestination(
                        icon: Icon(Icons.dashboard_outlined),
                        selectedIcon: Icon(Icons.dashboard),
                        label: Text('المبيعات'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.inventory_2_outlined),
                        selectedIcon: Icon(Icons.inventory_2),
                        label: Text('الأصناف'),
                      ),
                    ],
                  ),
                ),
                // Today's Sales Summary (Bottom of Sidebar)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
                  child: Column(
                    children: [
                      const Text('مبيعات اليوم', style: TextStyle(color: Colors.grey, fontSize: 11)),
                      Text(
                        '${pos.todayTotalSales.toInt()}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16),
                      ),
                      const Text('ج.س', style: TextStyle(color: Colors.grey, fontSize: 10)),
                    ],
                  ),
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

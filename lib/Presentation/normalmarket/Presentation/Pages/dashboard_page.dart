import 'package:flutter/material.dart';
import 'package:hanouty/Presentation/Farm/Presentation_Layer/pages/mobile/FarmMobileMarketSceen.dart';
import 'package:hanouty/Presentation/normalmarket/Presentation/Pages/Setting_page.dart';
import 'package:hanouty/Presentation/normalmarket/Presentation/Pages/normal_market_page.dart';
import 'package:hanouty/Presentation/normalmarket/Presentation/Provider/normal_market_provider.dart';
import 'package:hanouty/wallet_screen.dart';
import 'package:provider/provider.dart';
import '../../../Auth/presentation/controller/profilep^rovider.dart';
import '../../../Auth/presentation/pages/login_page.dart';
import '../../../order/presentation/pages/orderpage.dart';
import 'auction_market_screen.dart' show MarketOwnerAuctionsScreen;

// RouteObserver to be provided to MaterialApp if needed
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();

  // Helper for child widgets to trigger reload
  static _DashboardPageState? of(BuildContext context) =>
      context.findAncestorStateOfType<_DashboardPageState>();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  final GlobalKey<_NormalMarketsPageWrapperState> _marketsKey = GlobalKey();
  final GlobalKey<_SettingsPageWrapperState> _settingsKey = GlobalKey();
  final GlobalKey<_OrdersPageWrapperState> _ordersKey = GlobalKey();
  final GlobalKey<_FarmPageWrapperState> _farmKey = GlobalKey();


  late final List<Widget> _pages = [
    NormalMarketsPageWrapper(key: _marketsKey),
    MarketOwnerAuctionsScreen(),
    SettingsPageWrapper(key: _settingsKey),
    OrdersPageWrapper(key: _ordersKey),
    FarmMarketplaceScreen(key: _farmKey),
    WalletScreen(),

  ];

  final List<String> _titles = ['Fresh Markets', 'Auctions' ,'Settings', 'Market Orders','Farms','My Wallet'];
  final List<IconData> _pageIcons = [
    Icons.storefront_outlined,
    Icons.gavel,
    Icons.settings,
    Icons.receipt_long,
    Icons.storefront,
    Icons.wallet
  ];

  void _reloadCurrentPage() {
    switch (_selectedIndex) {
      case 0:
        _marketsKey.currentState?.reload();
        break;
      case 1:
        _settingsKey.currentState?.reload();
        break;
      case 2:
        _ordersKey.currentState?.reload();
        break;
      case 3:
        _farmKey.currentState?.reload();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5EC),
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: _pages[_selectedIndex],

    );
  }

  PreferredSizeWidget _buildAppBar() {
    const List<Color> veggieMarketGradient = [
      Color(0xFFFDF6ED),
      Color(0xFFE2C79E),
      Color(0xFFA8CF6A),
    ];
    final bool showGradient = _selectedIndex == 0;

    return AppBar(
      backgroundColor: showGradient ? Colors.transparent : const Color(0xFFFDF6ED),
      elevation: showGradient ? 0 : 2,
      scrolledUnderElevation: 0,
      flexibleSpace: showGradient
          ? Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: veggieMarketGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      )
          : null,
      title: _selectedIndex == 0
          ? Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFA8CF6A).withOpacity(0.16),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.eco_rounded,
              size: 28,
              color: Color(0xFFA8CF6A),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            "Tokenized Veg Markets",
            style: TextStyle(
              color: Color(0xFF6A4D24),
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      )
          : Row(
        children: [
          Icon(
            _pageIcons[_selectedIndex],
            color: const Color(0xFFA8CF6A),
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            _titles[_selectedIndex],
            style: const TextStyle(
              color: Color(0xFF6A4D24),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      iconTheme: IconThemeData(
        color: showGradient ? const Color(0xFF6A4D24) : const Color(0xFFA8CF6A),
      ),
      actions: [
        if (_selectedIndex == 1)
          IconButton(
            icon: const Icon(Icons.account_circle, size: 28),
            tooltip: 'Profile',
            onPressed: () {},
            color: const Color(0xFFA8CF6A),
          ),
        const SizedBox(width: 8),
      ],
      shadowColor: showGradient ? Colors.transparent : null,
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      elevation: 2,
      surfaceTintColor: Colors.transparent,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(),
          const SizedBox(height: 8),
          _buildNavItem(0, 'Markets', Icons.storefront_outlined, 'Manage your produce markets'),
          _buildNavItem(1, 'Auctions', Icons.gavel, 'All auctions'),
          _buildNavItem(2, 'Settings', Icons.settings_outlined, 'Account & app preferences'),
          _buildNavItem(3, 'Orders', Icons.receipt_long, 'View Current orders'),
          _buildNavItem(4, 'Farms', Icons.receipt_long, 'View Current Farms'),
          _buildNavItem(5, 'My Wallet', Icons.wallet, 'View Your Funds'),

          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(color: Colors.black12),
          ),
          const SizedBox(height: 8),
          _buildLogoutItem(),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFA8CF6A).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.eco, size: 14, color: Color(0xFFA8CF6A)),
                      SizedBox(width: 6),
                      Text(
                        'FreshToken v1.0.0',
                        style: TextStyle(
                          color: Color(0xFFA8CF6A),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return DrawerHeader(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFA8CF6A),
            Color(0xFFE2C79E),
            Color(0xFFF9F5EC),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.eco, size: 32, color: Color(0xFFA8CF6A)),
                ),
              ),
              const SizedBox(width: 16),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '',
                    style: TextStyle(
                      color: Color(0xFF6A4D24),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Market Owner',
                    style: TextStyle(
                      color: Color(0xFF6A4D24),
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified,
                  color: Color(0xFFA8CF6A),
                  size: 16,
                ),
                SizedBox(width: 6),
                Text(
                  'Tokenized Marketplace',
                  style: TextStyle(
                    color: Color(0xFF6A4D24),
                    fontSize: 14,
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

  Widget _buildNavItem(int index, String title, IconData icon, String subtitle) {
    final isSelected = _selectedIndex == index;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isSelected
            ? const Color(0xFFA8CF6A).withOpacity(0.08)
            : Colors.transparent,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? const Color(0xFFA8CF6A) : Colors.grey[700],
          size: 26,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? const Color(0xFF6A4D24) : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        selected: isSelected,
        selectedTileColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
          Navigator.pop(context);
          _reloadCurrentPage();
        },
      ),
    );
  }

  Widget _buildLogoutItem() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: const Icon(
          Icons.logout_outlined,
          color: Colors.redAccent,
          size: 24,
        ),
        title: const Text(
          'Logout',
          style: TextStyle(
            color: Colors.redAccent,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          'Sign out of your account',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: () async {
          // --- Show Confirmation Dialog ---
          final shouldLogout = await showDialog<bool>(
            context: context,
            builder: (dialogContext) => AlertDialog( // Use dialogContext
              title: const Text("Log out"),
              content: const Text("Are you sure you want to disconnect?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false), // Use dialogContext
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true), // Use dialogContext
                  child: const Text(
                    "Disconnect",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          );

          // --- Proceed if confirmed ---
          // Check if the widget is still mounted before proceeding after the dialog
          if (shouldLogout == true && mounted) {
            // Capture the provider and navigator using the current context
            // before the async gap, in case the context becomes invalid.
            final profileProvider = context.read<ProfileProvider>();
            final navigator = Navigator.of(context);
            final scaffoldMessenger = ScaffoldMessenger.of(context); // Capture ScaffoldMessenger

            try {
              // --- Call Logout Logic ---
              await profileProvider.logout(); // Clears state and tokens

              // --- Navigate AFTER logout ---
              // Check if the navigator is still mounted before navigation
              if (navigator.mounted) {
                navigator.pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                      (route) => false, // Remove all previous routes
                );
              }
            } catch (e) {
              // --- Handle Logout Errors ---
              // Check if the scaffoldMessenger's context is still valid
              if (scaffoldMessenger.mounted) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(content: Text('Error during logout: ${e.toString()}')),
                );
              }
              // Optionally print the error for debugging
              print('Logout error: $e');
            }
          }
        },
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    Navigator.pop(context); // Close the drawer

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.redAccent),
            SizedBox(width: 12),
            Text('Logout', style: TextStyle(color: Colors.black87)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to logout?',
              style: TextStyle(color: Colors.black87),
            ),
            SizedBox(height: 8),
            Text(
              'You will need to sign in again to access your markets.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[700],
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              // Add your logout logic here
            },
          ),
        ],
      ),
    );
  }
}

// --- Wrappers for each main page to support reload on reentry ---

class NormalMarketsPageWrapper extends StatefulWidget {
  const NormalMarketsPageWrapper({Key? key}) : super(key: key);
  @override
  State<NormalMarketsPageWrapper> createState() => _NormalMarketsPageWrapperState();
}

class _NormalMarketsPageWrapperState extends State<NormalMarketsPageWrapper> with RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
    reload();
  }



  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const NormalMarketsPage();

  @override
  void didPopNext() {
    reload();
  }
  @override
  void didPush() {
    reload();
  }
  @override
  void didPop() {}
  @override
  void didPushNext() {}

  void reload() {
    final provider = Provider.of<NormalMarketProvider>(context, listen: false);
    provider.loadMarkets();
  }
}
class FarmPageWrapper extends StatefulWidget {
  const FarmPageWrapper({Key? key}) : super(key: key);

  @override
  State<FarmPageWrapper> createState() => _FarmPageWrapperState();
}

class _FarmPageWrapperState extends State<FarmPageWrapper> {
  // Optional: Add any state variables here

  void reload() {
    setState(() {
      // Trigger rebuild, optionally reset data
    });
  }

  @override
  Widget build(BuildContext context) {
    return const FarmMarketplaceScreen();
  }
}


class SettingsPageWrapper extends StatefulWidget {
  const SettingsPageWrapper({Key? key}) : super(key: key);
  @override
  State<SettingsPageWrapper> createState() => _SettingsPageWrapperState();
}

class _SettingsPageWrapperState extends State<SettingsPageWrapper> with RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
    reload();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SettingsPage();

  @override
  void didPopNext() {
    reload();
  }
  @override
  void didPush() {
    reload();
  }
  @override
  void didPop() {}
  @override
  void didPushNext() {}
  void reload() {
    setState(() {});
  }
}

class OrdersPageWrapper extends StatefulWidget {
  const OrdersPageWrapper({Key? key}) : super(key: key);
  @override
  State<OrdersPageWrapper> createState() => _OrdersPageWrapperState();
}

class _OrdersPageWrapperState extends State<OrdersPageWrapper> with RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
    reload();
  }



  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const OrdersPage();

  @override
  void didPopNext() {
    reload();
  }
  @override
  void didPush() {
    reload();
  }
  @override
  void didPop() {}
  @override
  void didPushNext() {}
  void reload() {
    setState(() {});
  }
}
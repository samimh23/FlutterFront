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


  final List<String> _titles = [
    'Fresh Markets',
    'Auctions',
    'Settings',
    'Market Orders',
    'Farms',
    'My Wallet'
  ];
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
      // If MarketOwnerAuctionsScreen needs reload, add logic here
        break;
      case 2:
        _settingsKey.currentState?.reload();
        break;
      case 3:
        _ordersKey.currentState?.reload();
        break;
      case 4:
        _farmKey.currentState?.reload();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: _buildAppBar(theme, colorScheme),
      drawer: _buildDrawer(theme, colorScheme),
      body: _pages[_selectedIndex],
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme, ColorScheme colorScheme) {
    return AppBar(
      backgroundColor: colorScheme.secondary, // Use your teal accent for a fresh look
      elevation: 2,
      scrolledUnderElevation: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: colorScheme.onSecondary.withOpacity(0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _selectedIndex == 0 ? Icons.eco_rounded : _pageIcons[_selectedIndex],
              size: 28,
              color: colorScheme.onSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _selectedIndex == 0 ? "Tokenized Veg Markets" : _titles[_selectedIndex],
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSecondary,
              fontSize: _selectedIndex == 0 ? 22 : 20,
              fontWeight: _selectedIndex == 0 ? FontWeight.w700 : FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
      iconTheme: IconThemeData(
        color: colorScheme.onSecondary,
      ),
      actions: [
        if (_selectedIndex == 1)
          IconButton(
            icon: const Icon(Icons.account_circle, size: 28),
            tooltip: 'Profile',
            onPressed: () {},
            color: colorScheme.onSecondary,
          ),
        const SizedBox(width: 8),
      ],
      shadowColor: Colors.black12,
    );
  }
  Widget _buildDrawer(ThemeData theme, ColorScheme colorScheme) {
    return Drawer(
      backgroundColor: colorScheme.surface,
      elevation: 2,
      surfaceTintColor: Colors.transparent,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(theme, colorScheme),
          const SizedBox(height: 8),
          _buildNavItem(0, 'Markets', Icons.storefront_outlined, 'Manage your produce markets'),
          _buildNavItem(1, 'Auctions', Icons.gavel, 'All auctions'),
          _buildNavItem(2, 'Settings', Icons.settings_outlined, 'Account & app preferences'),
          _buildNavItem(3, 'Orders', Icons.receipt_long, 'View Current orders'),
          _buildNavItem(4, 'Farms', Icons.storefront, 'View Current Farms'),
          _buildNavItem(5, 'My Wallet', Icons.wallet, 'View Your Funds'),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(color: Colors.black12),
          ),
          const SizedBox(height: 8),
          _buildLogoutItem(theme, colorScheme),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.eco, size: 14, color: colorScheme.secondary),
                      const SizedBox(width: 6),
                      Text(
                        'FreshToken v1.0.0',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.secondary,
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
  Widget _buildDrawerHeader(ThemeData theme, ColorScheme colorScheme) {
    return DrawerHeader(
      decoration: BoxDecoration(
        color: colorScheme.secondary, // Use solid teal for a modern, bold look
        // OR you can keep a gradient (if you want it softer):
        // gradient: LinearGradient(
        //   begin: Alignment.topLeft,
        //   end: Alignment.bottomRight,
        //   colors: [
        //     colorScheme.secondary,
        //     colorScheme.primary,
        //   ],
        // ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: colorScheme.onSecondary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: colorScheme.surface,
                  child: Icon(Icons.eco, size: 32, color: colorScheme.secondary),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '', // You can add the market owner name here if available
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: colorScheme.onSecondary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Market Owner',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSecondary,
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
              color: colorScheme.onSecondary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified,
                  color: colorScheme.onSecondary,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'Tokenized Marketplace',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSecondary,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isSelected
            ? colorScheme.secondary.withOpacity(0.12)
            : Colors.transparent,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? colorScheme.secondary : colorScheme.onSurface.withOpacity(0.7),
          size: 26,
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: isSelected ? colorScheme.primary : colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.6),
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
  Widget _buildLogoutItem(ThemeData theme, ColorScheme colorScheme) {
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
        title: Text(
          'Logout',
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.redAccent,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          'Sign out of your account',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: () async {
          final shouldLogout = await showDialog<bool>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: const Text("Log out"),
              content: const Text("Are you sure you want to disconnect?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text(
                    "Disconnect",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          );
          if (shouldLogout == true && mounted) {
            final profileProvider = context.read<ProfileProvider>();
            final navigator = Navigator.of(context);
            final scaffoldMessenger = ScaffoldMessenger.of(context);
            try {
              await profileProvider.logout();
              if (navigator.mounted) {
                navigator.pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                      (route) => false,
                );
              }
            } catch (e) {
              if (scaffoldMessenger.mounted) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(content: Text('Error during logout: ${e.toString()}')),
                );
              }
              print('Logout error: $e');
            }
          }
        },
      ),
    );
  }}

// --- Wrappers for each main page to support reload on reentry ---



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
    // Subscribe to route changes for reload logic
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
  void didPopNext() => reload();
  @override
  void didPush() => reload();
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
  void reload() {
    setState(() {});
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
  void didPopNext() => reload();
  @override
  void didPush() => reload();
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
  void didPopNext() => reload();
  @override
  void didPush() => reload();
  @override
  void didPop() {}
  @override
  void didPushNext() {}

  void reload() {
    setState(() {});
  }
}
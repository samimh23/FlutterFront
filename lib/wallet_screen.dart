import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'Core/Utils/secure_storage.dart';
import 'hedera_api_service.dart';
import 'Core/theme/AppColors.dart';
import 'Presentation/Auth/presentation/controller/profilep^rovider.dart';

// Define color themes for different user roles
class WalletTheme {
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color background;
  final Color surface;
  final Color text;
  final Color textLight;
  final LinearGradient cardGradient;
  final String roleName;

  const WalletTheme({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.background,
    required this.surface,
    required this.text,
    required this.textLight,
    required this.cardGradient,
    required this.roleName,
  });

  // Market owner theme - blue scheme
  static const WalletTheme marketOwner = WalletTheme(
    primary: MarketOwnerColors.primary,
    secondary: MarketOwnerColors.secondary,
    accent: MarketOwnerColors.accent,
    background: Color(0xFFF8F9FA),
    surface: Colors.white,
    text: Color(0xFF1A1D1F),
    textLight: Color(0xFF6E7C87),
    cardGradient: LinearGradient(
      colors: [MarketOwnerColors.primary, MarketOwnerColors.secondary],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    roleName: 'Merchant',
  );

  // Farmer theme - green scheme
  static const WalletTheme farmer = WalletTheme(
    primary: Color(0xFF2E7D32),
    secondary: Color(0xFF66BB6A),
    accent: Color(0xFFA5D6A7),
    background: Color(0xFFF1F8E9),
    surface: Colors.white,
    text: Color(0xFF1B5E20),
    textLight: Color(0xFF558B2F),
    cardGradient: LinearGradient(
      colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    roleName: 'Farmer',
  );

  // Client theme - orange/amber scheme
  // Client theme - maroon/burgundy scheme (premium)
  // Client theme - teal/turquoise scheme
  // Client theme - using your ClientColors palette
  static const WalletTheme client = WalletTheme(
    primary: ClientColors.primary,         // Warm orange
    secondary: ClientColors.secondary,     // Light coral
    accent: ClientColors.accent,           // Deep orange
    background: ClientColors.background,   // Very light orange
    surface: ClientColors.surface,         // White
    text: ClientColors.text,               // Dark warm brown text
    textLight: ClientColors.textLight,     // Light brown text
    cardGradient: LinearGradient(
      colors: [ClientColors.primary, ClientColors.secondary],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    roleName: 'Client',
  );
}

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final HederaApiService _apiService = HederaApiService();
  final SecureStorageService _secureStorage = SecureStorageService();
  bool _isThemeInitialized = false; // Theme initialization flag

  late WalletTheme _theme;

  // Balance state
  bool _isLoading = true;
  bool _isProcessing = false;
  String _mainBalance = '0';
  String _lockedBalance = '0';
  String _storeBalance = '0';
  String _accountId = '';
  String _errorMessage = '';

  // Transaction history state
  bool _isLoadingTransactions = false;
  List<dynamic> _transactions = [];
  String _transactionError = '';

  // Controllers for text fields
  final TextEditingController _receiverController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _lockAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Make sure we have a default theme
    _theme = WalletTheme.marketOwner;

    // Add debugging for role on initialization
    _loadAndDebugUserRole();

    _loadAccountInfo();
    _fetchBalance();
    _fetchTransactionHistory();
  }
  Future<void> _loadAndDebugUserRole() async {
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);

    // Check if user is already available in provider
    if (profileProvider.user != null && profileProvider.user!.role != null) {
      print("DEBUG - User role from provider on init: ${profileProvider.user!.role}");
    } else {
      print("DEBUG - No user in provider on init, will check secure storage");
    }

    // Check secureStorage for role
    String? storedRole = await _secureStorage.getUserRole();
    if (storedRole != null) {
      print("DEBUG - Found role in secure storage: $storedRole");
    } else {
      print("DEBUG - No role found in secure storage");
    }
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Set the theme based on user role from ProfileProvider
    _setThemeFromProfile();

    // Listen for changes in the ProfileProvider
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);

    // Use a Future to avoid setState during build
    Future.microtask(() {
      profileProvider.addListener(() {
        if (mounted) {
          _setThemeFromProfile();
        }
      });
    });
  }

  void _setThemeFromProfile() {
    // First try to get the role from the ProfileProvider
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    final user = profileProvider.user;
    String? role;

    if (user != null && user.role != null) {
      // User is loaded in ProfileProvider
      role = user.role!.toLowerCase();
      print("DEBUG - Got role from ProfileProvider: $role");
    } else {
      // Try to get role from SecureStorage as fallback
      _secureStorage.getUserRole().then((storedRole) {
        if (storedRole != null) {
          print("DEBUG - Got role from SecureStorage: $storedRole");
          _applyThemeBasedOnRole(storedRole.toLowerCase());
        } else {
          print("DEBUG - No role found in either ProfileProvider or SecureStorage");
        }
      });
      return; // Exit here since we're using async call for SecureStorage
    }

    // If we got a role from ProfileProvider, apply it directly
    if (role != null) {
      _applyThemeBasedOnRole(role);
    }
  }

// Helper method to apply theme based on role
  void _applyThemeBasedOnRole(String roleLowerCase) {
    WalletTheme newTheme;

    if (roleLowerCase.contains('farm') || roleLowerCase == 'farmer') {
      print("DEBUG - Setting farmer theme");
      newTheme = WalletTheme.farmer;
    }
    else if (roleLowerCase.contains('client') || roleLowerCase == 'customer' ||
        roleLowerCase == 'buyer' || roleLowerCase.contains('user')) {
      print("DEBUG - Setting client theme");
      newTheme = WalletTheme.client;
    }
    else if (roleLowerCase.contains('market') || roleLowerCase.contains('merchant') ||
        roleLowerCase == 'admin' || roleLowerCase == 'owner') {
      print("DEBUG - Setting merchant theme");
      newTheme = WalletTheme.marketOwner;
    }
    else {
      print("DEBUG - No matching role found, defaulting to marketOwner theme");
      newTheme = WalletTheme.marketOwner; // Default theme
    }

    // Only update state if the theme has changed
    if (_theme != newTheme) {
      setState(() {
        _theme = newTheme;
        _isThemeInitialized = true;
      });
    } else {
      _isThemeInitialized = true;
    }
  }

  @override
  void dispose() {
    _receiverController.dispose();
    _amountController.dispose();
    _lockAmountController.dispose();
    super.dispose();
  }

  Future<void> _loadAccountInfo() async {
    final accountId = await _secureStorage.getHederaAccountId();
    if (accountId != null) {
      setState(() {
        _accountId = accountId;
      });
    } else {
      print('No Hedera account found in secure storage');
      setState(() {
        _errorMessage = 'No wallet account found. Please create or import a wallet.';
      });
    }
  }

  // Add this method to force profile loading
  Future<void> _ensureProfileLoaded() async {
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);

    // If profile is not loaded, load it
    if (profileProvider.status != ProfileStatus.loaded) {
      print("DEBUG - Profile not loaded, loading now...");
      try {
        await profileProvider.loadProfile();
        print("DEBUG - Profile loaded successfully");

        // Now set the theme based on the loaded profile
        if (mounted) {
          _setThemeFromProfile();
        }
      } catch (e) {
        print("DEBUG - Error loading profile: $e");
      }
    }
  }

  Future<void> _fetchBalance() async {
    if (_isProcessing) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      print('Attempting to fetch balance...');
      final balanceData = await _apiService.getBalance();
      print('Balance response: $balanceData');

      setState(() {
        if (balanceData.containsKey('balance')) {
          _mainBalance = balanceData['balance'].toString();
        } else if (balanceData.containsKey('hbars')) {
          _mainBalance = balanceData['hbars'].toString();
        } else {
          _mainBalance = balanceData.values.first?.toString() ?? '0';
        }

        _lockedBalance = '56,734'; // Replace with actual value
        _storeBalance = '345,67'; // Replace with actual value
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching balance: $e');
      setState(() {
        _errorMessage = 'Could not fetch balance. Please try again later.';
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not connect to wallet server. Check your internet connection.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _fetchBalance,
            textColor: Colors.white,
          ),
        ),
      );
    }
  }

  Future<void> _fetchTransactionHistory() async {
    if (_isProcessing) return;

    setState(() {
      _isLoadingTransactions = true;
      _transactionError = '';
    });

    try {
      print('Fetching transaction history...');
      final result = await _apiService.traceTransactions();

      setState(() {
        _transactions = result['traced'] ?? [];
        _isLoadingTransactions = false;
      });

      print('Loaded ${_transactions.length} transactions');
    } catch (e) {
      print('Error fetching transactions: $e');
      setState(() {
        _transactionError = 'Could not load transaction history.';
        _isLoadingTransactions = false;
      });
    }
  }

  Future<void> _transferTokens() async {
    if (_isProcessing) return;

    // Basic validation
    if (_receiverController.text.isEmpty || _amountController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Receiver account ID and amount are required';
      });
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = '';
    });

    try {
      await _apiService.transferTokens(
        receiverAccountId: _receiverController.text.trim(),
        amount: _amountController.text.trim(),
      );

      // Clear fields and refresh balance
      _receiverController.clear();
      _amountController.clear();

      // Refresh both balance and transactions
      await _fetchBalance();
      await _fetchTransactionHistory();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transfer successful'),
          backgroundColor: _theme.primary.withOpacity(0.8),
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Transfer failed: ${e.toString().split('\n')[0]}';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transfer failed. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  // Function to show transfer dialog
  void _showTransferDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Transfer Tokens'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _receiverController,
                decoration: InputDecoration(
                  labelText: 'Receiver Account ID',
                  border: OutlineInputBorder(),
                  hintText: '0.0.12345',
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: _theme.primary, width: 2),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Amount (HC)',
                  border: OutlineInputBorder(),
                  hintText: '10.0',
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: _theme.primary, width: 2),
                  ),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          _isProcessing
              ? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(_theme.primary))
              : ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _transferTokens();
            },
            child: Text('Transfer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _theme.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Format Hedera timestamp to readable date
  String _formatHederaTimestamp(String timestamp) {
    try {
      final parts = timestamp.split('.');
      final seconds = int.parse(parts[0]);
      final dateTime = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
      return DateFormat('MMM d, h:mm a').format(dateTime);
    } catch (e) {
      print('Error formatting timestamp: $e');
      return 'Unknown date';
    }
  }

  // Format transaction amount with currency symbol
  String _formatAmount(dynamic amount) {
    if (amount is num) {
      final formatted = amount.abs().toStringAsFixed(2);
      return amount < 0 ? "-\HC $formatted" : "+\HC $formatted";
    }
    return amount.toString();
  }

  // Widget to display transaction list item
  Widget _transactionTile(String title, String subtitle, String amount, String date) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 2),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _theme.primary.withOpacity(0.2),
          child: Icon(
            amount.startsWith("-") ? Icons.arrow_upward : Icons.arrow_downward,
            color: amount.startsWith("-") ? Colors.red : Colors.green,
          ),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: _theme.text)),
        subtitle: Text(subtitle, style: TextStyle(color: _theme.textLight)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              amount,
              style: TextStyle(
                color: amount.startsWith("-") ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              date,
              style: TextStyle(fontSize: 12, color: _theme.textLight),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listen to changes in the ProfileProvider
    final profileProvider = Provider.of<ProfileProvider>(context);

    return Scaffold(
      backgroundColor: _theme.background,
      body: Stack(
        children: [
          // Role indicator badge
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _theme.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _theme.primary.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getRoleIcon(),
                    size: 14,
                    color: _theme.primary,
                  ),
                  SizedBox(width: 4),
                  Text(
                    _theme.roleName,
                    style: TextStyle(
                      color: _theme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main wallet content
          _buildWalletContent(profileProvider),
        ],
      ),
      floatingActionButton: _isLoading || _accountId.isEmpty
          ? null
          : FloatingActionButton.extended(
        onPressed: () async {
          await _fetchBalance();
          await _fetchTransactionHistory();
        },
        tooltip: 'Refresh',
        icon: Icon(Icons.refresh),
        label: Text("Refresh"),
        backgroundColor: _theme.primary,
      ),
    );
  }

  IconData _getRoleIcon() {
    if (_theme == WalletTheme.farmer) {
      return Icons.agriculture;
    } else if (_theme == WalletTheme.client) {
      return Icons.person;
    } else {
      return Icons.store;
    }
  }

  Widget _buildWalletContent(ProfileProvider profileProvider) {
    return _accountId.isEmpty && !_isLoading
        ? Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 80,
            color: _theme.primary.withOpacity(0.5),
          ),
          SizedBox(height: 16),
          Text(
            'No wallet account found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _theme.text,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Create or import a wallet to continue',
            style: TextStyle(color: _theme.textLight),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Handle wallet creation or import
            },
            child: Text('Create Wallet'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _theme.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    )
        : _isLoading
        ? Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(_theme.primary)),
          SizedBox(height: 16),
          Text('Loading your wallet data...', style: TextStyle(color: _theme.text)),
        ],
      ),
    )
        : RefreshIndicator(
      onRefresh: () async {
        await _fetchBalance();
        await _fetchTransactionHistory();
      },
      color: _theme.primary,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 32), // Space for the role badge

              // Account ID section with role-specific styling
              if (_accountId.isNotEmpty)
                Card(
                  elevation: 2,
                  color: _theme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: _theme.primary.withOpacity(0.1), width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Icon(Icons.account_circle, color: _theme.primary),
                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Account ID",
                                style: TextStyle(
                                  color: _theme.textLight,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                _accountId,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _theme.text,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.copy, size: 18, color: _theme.primary),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _accountId));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Account ID copied to clipboard'),
                                backgroundColor: _theme.primary.withOpacity(0.8),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

              SizedBox(height: 16),

              // Balance card with role-specific gradient
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: _theme.cardGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Available Balance",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 10),
                      _errorMessage.isNotEmpty
                          ? Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _errorMessage,
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                          : Text(
                        "\HC $_mainBalance",
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text(
                                "Locked",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "\HC $_lockedBalance",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                "Store",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "\HC $_storeBalance",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Action buttons with role-specific colors
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _actionButton(
                    Icons.shopping_cart,
                    "Shop",
                        () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Shop feature coming soon'),
                          backgroundColor: _theme.primary.withOpacity(0.8),
                        ),
                      );
                    },
                  ),
                  _actionButton(
                    Icons.credit_card,
                    "Transfer",
                    _showTransferDialog,
                  ),
                ],
              ),

              SizedBox(height: 24),

              // Transaction history section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Recent Transactions",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _theme.text,
                    ),
                  ),
                  TextButton(
                    onPressed: _fetchTransactionHistory,
                    child: Text(
                      "Refresh",
                      style: TextStyle(color: _theme.primary),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),

              // Transaction list with role-specific styling
              _isLoadingTransactions
                  ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(_theme.primary)),
                ),
              )
                  : _transactionError.isNotEmpty
                  ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        _transactionError,
                        style: TextStyle(color: Colors.red),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchTransactionHistory,
                        child: Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _theme.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  : _transactions.isEmpty
                  ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.history,
                        size: 48,
                        color: _theme.primary.withOpacity(0.3),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No transaction history found',
                        style: TextStyle(color: _theme.textLight),
                      ),
                    ],
                  ),
                ),
              )
                  : ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _transactions.length > 5 ? 5 : _transactions.length,
                itemBuilder: (context, index) {
                  final tx = _transactions[index];
                  final isOutgoing = tx['direction'] == 'SEND';
                  final isSuccessful = tx['result'] == 'SUCCESS';

                  return _transactionTile(
                    // Type of transaction
                    tx['type'] ?? 'Transaction',

                    // Subtitle shows direction and status
                    isOutgoing
                        ? "Sent ${isSuccessful ? 'successfully' : 'failed'}"
                        : "Received ${isSuccessful ? 'successfully' : 'failed'}",

                    // Amount with sign
                    _formatAmount(tx['amount']),

                    // Format timestamp
                    _formatHederaTimestamp(tx['timestamp']),
                  );
                },
              ),

              // "View All" button for transactions with role-specific color
              if (_transactions.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TransactionHistoryScreen(_apiService, _theme),
                          ),
                        );
                      },
                      child: Text("View All Transactions"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _theme.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method for action buttons with role-specific colors
  Widget _actionButton(IconData icon, String label, VoidCallback onPressed) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: _theme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(icon, color: _theme.primary, size: 28),
            onPressed: onPressed,
            padding: EdgeInsets.all(16),
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _theme.text,
          ),
        ),
      ],
    );
  }
}

// Separate transaction history screen with role-specific styling
class TransactionHistoryScreen extends StatefulWidget {
  final HederaApiService apiService;
  final WalletTheme theme;

  TransactionHistoryScreen(this.apiService, this.theme);

  @override
  _TransactionHistoryScreenState createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  bool _isLoading = true;
  List<dynamic> _transactions = [];
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final result = await widget.apiService.traceTransactions();
      setState(() {
        _transactions = result['traced'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatHederaTimestamp(String timestamp) {
    try {
      final parts = timestamp.split('.');
      final seconds = int.parse(parts[0]);
      final dateTime = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
      return DateFormat('MMM d, yyyy h:mm a').format(dateTime);
    } catch (e) {
      return 'Unknown date';
    }
  }

  String _formatAmount(dynamic amount) {
    if (amount is num) {
      final formatted = amount.abs().toStringAsFixed(2);
      return amount < 0 ? "-\HC $formatted" : "+\HC $formatted";
    }
    return amount.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.theme.background,
      appBar: AppBar(
        title: Text('Transaction History'),
        backgroundColor: widget.theme.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(widget.theme.primary),
        ),
      )
          : _error.isNotEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error, style: TextStyle(color: Colors.red)),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchTransactions,
              child: Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.theme.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      )
          : _transactions.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: widget.theme.primary.withOpacity(0.3),
            ),
            SizedBox(height: 16),
            Text(
              'No transactions found',
              style: TextStyle(
                color: widget.theme.text,
                fontSize: 18,
              ),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _fetchTransactions,
        color: widget.theme.primary,
        child: ListView.builder(
          itemCount: _transactions.length,
          itemBuilder: (context, index) {
            final tx = _transactions[index];
            final isOutgoing = tx['direction'] == 'SEND';
            final isSuccessful = tx['result'] == 'SUCCESS';

            return Card(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: widget.theme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isOutgoing ? Icons.arrow_upward : Icons.arrow_downward,
                              color: isOutgoing ? Colors.red : Colors.green,
                            ),
                            SizedBox(width: 8),
                            Text(
                              tx['type'] ?? 'Transaction',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: widget.theme.text,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          _formatAmount(tx['amount']),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isOutgoing ? Colors.red : Colors.green,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Status: ${tx['result']}',
                      style: TextStyle(
                        color: isSuccessful ? Colors.green : Colors.red,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Date: ${_formatHederaTimestamp(tx['timestamp'])}',
                      style: TextStyle(color: widget.theme.textLight),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Transaction ID: ${tx['id']}',
                      style: TextStyle(fontSize: 12, color: widget.theme.textLight),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
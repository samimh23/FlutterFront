import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'Core/Utils/secure_storage.dart';
import 'hedera_api_service.dart';

class WalletScreen extends StatefulWidget {
  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final HederaApiService _apiService = HederaApiService();
  final SecureStorageService _secureStorage = SecureStorageService();

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
    _loadAccountInfo();
    _fetchBalance();
    _fetchTransactionHistory();
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
        // Parse the balance data according to your API response format
        if (balanceData.containsKey('balance')) {
          _mainBalance = balanceData['balance'].toString();
        } else if (balanceData.containsKey('hbars')) {
          _mainBalance = balanceData['hbars'].toString();
        } else {
          // If format is different, adjust according to your API
          _mainBalance = balanceData.values.first?.toString() ?? '0';
        }

        // You may need to adjust these based on your actual API response structure
        _lockedBalance = '56,734'; // Replace with actual value from API if available
        _storeBalance = '345,67'; // Replace with actual value from API if available
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching balance: $e');
      setState(() {
        _errorMessage = 'Could not fetch balance. Please try again later.';
        _isLoading = false;
      });

      // Show a more user-friendly error message
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
        SnackBar(content: Text('Transfer successful')),
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
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Amount (HC)',
                  border: OutlineInputBorder(),
                  hintText: '10.0',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          _isProcessing
              ? CircularProgressIndicator()
              : ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _transferTokens();
            },
            child: Text('Transfer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
            ),
          ),
        ],
      ),
    );
  }

  // Format Hedera timestamp to readable date
  String _formatHederaTimestamp(String timestamp) {
    try {
      // Hedera timestamp is in seconds.nanoseconds format
      final parts = timestamp.split('.');
      final seconds = int.parse(parts[0]);

      // Convert to DateTime
      final dateTime = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);

      // Format the date
      return DateFormat('MMM d, h:mm a').format(dateTime);
    } catch (e) {
      print('Error formatting timestamp: $e');
      return 'Unknown date';
    }
  }

  // Format transaction amount with currency symbol
  String _formatAmount(dynamic amount) {
    // Format the amount with 2 decimal places
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
          backgroundColor: Colors.indigo.withOpacity(0.2),
          child: Icon(
            amount.startsWith("-") ? Icons.arrow_upward : Icons.arrow_downward,
            color: amount.startsWith("-") ? Colors.red : Colors.green,
          ),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
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
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        leading: Icon(Icons.account_balance_wallet),
        title: Text("My Wallet"),
        elevation: 4,
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Settings coming soon')),
              );
            },
            icon: Icon(Icons.settings),
          )
        ],
      ),
      body: _accountId.isEmpty && !_isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance_wallet_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No wallet account found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Create or import a wallet to continue'),
            SizedBox(height: 24),
          ],
        ),
      )
          : _isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.indigo),
            SizedBox(height: 16),
            Text('Loading your wallet data...'),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: () async {
          await _fetchBalance();
          await _fetchTransactionHistory();
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Account ID section
                if (_accountId.isNotEmpty)
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Icon(Icons.account_circle, color: Colors.indigo),
                          SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Account ID",
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  _accountId,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.copy, size: 18),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: _accountId));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Account ID copied to clipboard')),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                SizedBox(height: 16),

                // Balance section
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.indigo, Colors.indigo.shade800],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Available Balance",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
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

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _actionButton(
                      Icons.shopping_cart,
                      "Shop",
                          () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Shop feature coming soon')),
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
                      ),
                    ),
                    TextButton(
                      onPressed: _fetchTransactionHistory,
                      child: Text("Refresh"),
                    ),
                  ],
                ),
                SizedBox(height: 8),

                // Transaction list with real data
                _isLoadingTransactions
                    ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
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
                        ElevatedButton(
                          onPressed: _fetchTransactionHistory,
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
                    : _transactions.isEmpty
                    ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      'No transaction history found',
                      style: TextStyle(color: Colors.grey[600]),
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

                // "View All" button for transactions
                if (_transactions.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => TransactionHistoryScreen(_apiService)),
                          );
                        },
                        child: Text("View All Transactions"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await _fetchBalance();
          await _fetchTransactionHistory();
        },
        tooltip: 'Refresh',
        icon: Icon(Icons.refresh),
        label: Text("Refresh"),
        backgroundColor: Colors.indigo,
      ),
    );
  }

  // Helper method for action buttons
  Widget _actionButton(IconData icon, String label, VoidCallback onPressed) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.indigo.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.indigo, size: 28),
            onPressed: onPressed,
            padding: EdgeInsets.all(16),
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

// Separate transaction history screen
class TransactionHistoryScreen extends StatefulWidget {
  final HederaApiService apiService;

  TransactionHistoryScreen(this.apiService);

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
      appBar: AppBar(
        title: Text('Transaction History'),
        backgroundColor: Colors.indigo,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
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
            ),
          ],
        ),
      )
          : _transactions.isEmpty
          ? Center(child: Text('No transactions found'))
          : RefreshIndicator(
        onRefresh: _fetchTransactions,
        child: ListView.builder(
          itemCount: _transactions.length,
          itemBuilder: (context, index) {
            final tx = _transactions[index];
            final isOutgoing = tx['direction'] == 'SEND';
            final isSuccessful = tx['result'] == 'SUCCESS';

            return Card(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    Text('Date: ${_formatHederaTimestamp(tx['timestamp'])}'),
                    SizedBox(height: 4),
                    Text('Transaction ID: ${tx['id']}',
                        style: TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis),
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
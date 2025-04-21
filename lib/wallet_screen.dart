import 'package:flutter/material.dart';

void main() => runApp(WalletApp());

class WalletApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WalletHomePage(),
    );
  }
}

class WalletHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        leading: Icon(Icons.arrow_back),
        title: Text("My wallet"),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.settings))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                  children: [
                  Text("Balance:", style: TextStyle(color: Colors.grey[700])),
              SizedBox(height: 8),
                Text("\HC267,345",
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
                ],
              ),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    IconButton(
                      icon: Icon(Icons.attach_money, color: Colors.indigo, size: 36),
                      onPressed: () {
                        print('Refound pressed');
                      },
                    ),
                    Text("Refound")
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                      icon: Icon(Icons.shopping_cart, color: Colors.indigo, size: 36),
                      onPressed: () {
                        print('Shop pressed');
                      },
                    ),
                    Text("Shop")
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                      icon: Icon(Icons.credit_card, color: Colors.indigo, size: 36),
                      onPressed: () {
                        print('Transfer pressed');
                      },
                    ),
                    Text("Transfer")
                  ],
                ),
              ],
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text("Locked", style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text("\$56,734",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo))
                  ],
                ),
                Column(
                  children: [
                    Text("Store Account", style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text("HC345,67",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo))
                  ],
                ),
              ],
            ),
            SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: [
                  transactionTile("Lorem ipsum", "Dolor", "-375.45", "4 Aug 9:15 am"),
                  transactionTile("Lorem ipsum", "Dolor", "+324.45", "4 Aug 9:10 am"),
                  transactionTile("Lorem ipsum", "Dolor", "-195.45", "4 Aug 9:05 am"),
                ],
              ),
            )
          ],
        ),
      ),

    );
  }

  Widget transactionTile(String title, String subtitle, String amount, String date) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.monetization_on, color: Colors.indigo),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(amount,
                style: TextStyle(
                    color: amount.startsWith("-") ? Colors.red : Colors.green)),
            Text(date, style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
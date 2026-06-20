import 'package:flutter/material.dart';

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Metode Pembayaran'),
      ),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.account_balance),
            title: Text('Bank BCA'),
            subtitle: Text('**** 1234'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.account_balance_wallet),
            title: Text('DANA'),
            subtitle: Text('0812xxxxxxx'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.payments),
            title: Text('GoPay'),
            subtitle: Text('0812xxxxxxx'),
          ),
        ],
      ),
    );
  }
}
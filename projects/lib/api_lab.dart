import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(CoinbaseApp());
}

class CoinbaseApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coinbase Prices',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PriceListScreen(),
    );
  }
}

class PriceListScreen extends StatefulWidget {
  @override
  _PriceListScreenState createState() => _PriceListScreenState();
}

class _PriceListScreenState extends State<PriceListScreen> {
  List<String> currencies = ['BTC', 'ETH', 'LTC'];
  Map<String, String> prices = {};

  @override
  void initState() {
    super.initState();
    fetchPrices();
  }

  Future<void> fetchPrices() async {
    for (String currency in currencies) {
      final response = await http.get(
        Uri.parse('https://api.coinbase.com/v2/prices/$currency-USD/spot'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          prices[currency] = data['data']['amount'];
        });
      } else {
        setState(() {
          prices[currency] = 'Error';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Coinbase Prices'),
      ),
      body: ListView.builder(
        itemCount: currencies.length,
        itemBuilder: (context, index) {
          String currency = currencies[index];
          String price = prices[currency] ?? 'Loading...';
          return ListTile(
            title: Text('$currency'),
            subtitle: Text('USD $price'),
          );
        },
      ),
    );
  }
}

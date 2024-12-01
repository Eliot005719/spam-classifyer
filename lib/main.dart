import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(SpamClassifierApp());
}

class SpamClassifierApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SpamClassifierScreen(),
    );
  }
}

class SpamClassifierScreen extends StatefulWidget {
  @override
  _SpamClassifierScreenState createState() => _SpamClassifierScreenState();
}

class _SpamClassifierScreenState extends State<SpamClassifierScreen> {
  final TextEditingController _controller = TextEditingController();
  String _result = '';
  String _probability = '';

  Future<void> classifyMessage(String message) async {
    final url = Uri.parse('http://127.0.0.1:5000/classify'); // Replace with live API URL when deployed
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'message': message}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _result = 'Classification: ${data['classification']}';
        _probability = 'Spam Probability: ${data['spam_probability'].toStringAsFixed(2)}%';
      });
    } else {
      setState(() {
        _result = 'Error: Unable to classify message.';
        _probability = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Spam Classifier')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter a message',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    final message = _controller.text;
                    if (message.isNotEmpty) {
                      classifyMessage(message);
                    }
                  },
                  child: Text('Classify'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _result = '';
                      _probability = '';
                      _controller.clear();
                    });
                  },
                  child: Text('Reset'),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              _result,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (_probability.isNotEmpty)
              Text(
                _probability,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
          ],
        ),
      ),
    );
  }
}

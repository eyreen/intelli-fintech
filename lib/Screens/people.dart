import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:managment/Screens/financial_literacy_page.dart';

class People extends StatefulWidget {
  const People({Key? key}) : super(key: key);

  @override
  State<People> createState() => _PeopleState();
}

class _PeopleState extends State<People> {
  final TextEditingController goalController = TextEditingController();
  final TextEditingController incomeController = TextEditingController();
  final TextEditingController expensesController = TextEditingController();
  final TextEditingController savingsController = TextEditingController();
  String riskLevel = 'Low'; // Default risk level
  bool isMarried = false; // Default marital status
  String aiResponse = ''; // To store AI-generated response

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 207, 173, 216),
        title: const Text(
          'Wealth Accumulation Profiling',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: Stack (
        children:[
          // Background Image
        Positioned.fill(
          child: Image.network(
            'https://t3.ftcdn.net/jpg/03/44/52/88/360_F_344528805_o1LwyPDkkDZ7TEbTE5J08e9m00ZifmGK.jpg', // Replace with your actual online image URL
            fit: BoxFit.cover,
          ),
        ),
      SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Tell us about your financial goals and situation:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              // Financial Goal
              TextField(
                controller: goalController,
                decoration: InputDecoration(labelText: 'Financial Goal'),
              ),
              SizedBox(height: 10),
              // Monthly Income
              TextField(
                controller: incomeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Monthly Income'),
              ),
              SizedBox(height: 10),
              // Monthly Expenses
              TextField(
                controller: expensesController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Monthly Expenses'),
              ),
              SizedBox(height: 10),
              // Monthly Savings
              TextField(
                controller: savingsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Monthly Savings'),
              ),
              SizedBox(height: 10),
              // Risk Level Dropdown
              DropdownButtonFormField<String>(
                value: riskLevel,
                onChanged: (value) {
                  setState(() {
                    riskLevel = value!;
                  });
                },
                items: ['Low', 'Medium', 'High']
                    .map((level) => DropdownMenuItem(
                          value: level,
                          child: Text(level),
                        ))
                    .toList(),
                decoration: InputDecoration(labelText: 'Risk Level'),
              ),
              SizedBox(height: 10),
              // Marital Status Radio Buttons
              Row(
                children: [
                  Text('Marital Status:'),
                  SizedBox(width: 10),
                  Row(
                    children: [
                      Radio(
                        value: true,
                        groupValue: isMarried,
                        onChanged: (value) {
                          setState(() {
                            isMarried = value as bool;
                          });
                        },
                      ),
                      Text('Married'),
                    ],
                  ),
                  Row(
                    children: [
                      Radio(
                        value: false,
                        groupValue: isMarried,
                        onChanged: (value) {
                          setState(() {
                            isMarried = value as bool;
                          });
                        },
                      ),
                      Text('Single'),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Process the form data or send it to the AI for analysis
                  // You can call a function here to handle the form data
                  processForm();
                },
                child: Text('Submit'),
              ),
              // Display AI response
              if (aiResponse.isNotEmpty)
                Card(
                  margin: EdgeInsets.all(16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Recommendations',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(aiResponse),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            // Navigate to the ToDoListPage
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => FinancialLiteracyPage()),
                            );
                          },
                          child: Text('Next'),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ]));
  }

  void processForm() async {
    // Retrieve user input from controllers and state
    String goal = goalController.text;
    double income = double.tryParse(incomeController.text) ?? 0.0;
    double expenses = double.tryParse(expensesController.text) ?? 0.0;
    double savings = double.tryParse(savingsController.text) ?? 0.0;

    // Additional data
    print('Risk Level: $riskLevel');
    print('Marital Status: ${isMarried ? 'Married' : 'Single'}');

    // You can now use this data to send it to the AI for analysis and advice
    String aiPrompt = """
      Financial Goal: $goal
      Monthly Income: $income
      Monthly Expenses: $expenses
      Monthly Savings: $savings
      Risk Level: $riskLevel
      Marital Status: ${isMarried ? 'Married' : 'Single'}
    """;

    // Make an HTTP request to the OpenAI API
    await getAIResponse(aiPrompt);
  }

  Future getAIResponse(String prompt) async {
    // TODO: Replace 'YOUR_OPENAI_API_KEY' with your actual OpenAI API key
    const String apiKey = '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';
    const String model = 'gpt-3.5-turbo-instruct'; // Use GPT-3.5-turbo model

    final Uri apiUrl = Uri.parse('https://api.openai.com/v1/engines/$model/completions');

    final http.Response response = await http.post(
      apiUrl,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'prompt': prompt,
        'max_tokens': 200,
      }),
    );

    if (response.statusCode == 200) {
      // Parse and use the AI-generated response
      final Map<String, dynamic> data = jsonDecode(response.body);
      final String aiResult = data['choices'][0]['text'];

      setState(() {
        aiResponse = aiResult;
      });
    } else {
      // Handle errors
      print('Failed to fetch AI response. Status code: ${response.statusCode}');
      print('API Response: ${response.body}');
    }
  }
}
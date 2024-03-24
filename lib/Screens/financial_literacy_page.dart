import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FinancialLiteracyPage extends StatefulWidget {
  @override
  _FinancialLiteracyPageState createState() => _FinancialLiteracyPageState();
}

class _FinancialLiteracyPageState extends State<FinancialLiteracyPage> {
  // Tickbox section
  List<ContentItem> tickboxList = [
    ContentItem(
      title: 'Create a budget plan',
      content: 'Tick this box after creating a budget plan.',
      isCompleted: false,
    ),
    ContentItem(
      title: 'Start saving 10% of income',
      content: 'Tick this box after starting to save 10% of your income.',
      isCompleted: false,
    ),
    ContentItem(
      title: 'Invest in low-risk funds',
      content: 'Tick this box after investing in low-risk funds.',
      isCompleted: false,
    ),
    ContentItem(
      title: 'Review expenses monthly',
      content: 'Tick this box after reviewing expenses monthly.',
      isCompleted: false,
    ),
  ];

  // AI-generated content and quizzes section
  List<ContentItem> contentList = [
    ContentItem(
      title: 'Understanding Budgeting',
      content: 'AI-generated content for understanding budgeting.',
    ),
    ContentItem(
      title: 'Importance of Saving',
      content: 'AI-generated content highlighting the importance of saving.',
    ),
    ContentItem(
      title: 'General/Others',
      content: '',
    ),
  ];

  List<QuizItem> quizList = [
    QuizItem(
      question: 'What is the primary purpose of budgeting?',
      options: ['A. Save money', 'B. Spend more', 'C. Track expenses', 'D. None of the above'],
      correctAnswer: 'C. Track expenses',
    ),
    QuizItem(
      question: 'How can saving benefit your financial future?',
      options: ['A. Higher expenses', 'B. Financial security', 'C. Increased debt', 'D. None of the above'],
      correctAnswer: 'B. Financial security',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    int completedCount = tickboxList.where((item) => item.isCompleted).length;
    double progress = completedCount / tickboxList.length;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 207, 173, 216),
        title: const Text(
          'Wealth Accumulation Pathway',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.network(
              'https://t3.ftcdn.net/jpg/03/44/52/88/360_F_344528805_o1LwyPDkkDZ7TEbTE5J08e9m00ZifmGK.jpg', // Replace with your actual online image URL
              fit: BoxFit.cover,
            ),
          ),
      
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            SizedBox(height: 20),
            Text(
              'Tickboxes ✅',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            // Display tickboxes and progress bar
            LinearProgressIndicator(
              value: progress,
            ),
            ...tickboxList.map((item) => TaskCard(item: item)).toList(),
            SizedBox(height: 20),
            Text(
              'Financial Knowledge Base 💰',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            // Display AI-generated content
            ...contentList.map((item) => ContentCard(item: item)).toList(),
            SizedBox(height: 20),
            Text(
              'Financial Literacy Quizzes 📜',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            // Display quizzes
            ...quizList.map((item) => QuizCard(item: item)).toList(),
          ],
        ),
      ),
    ]));
  }
  void _handleCheckboxChanged(ContentItem item, bool value) {
    setState(() {
      item.isCompleted = value;
    });
  }
}
class ContentItem {
  final String title;
  final String content;
  bool isCompleted;

  ContentItem({required this.title, required this.content, this.isCompleted = false});
}

class QuizItem {
  final String question;
  final List<String> options;
  final String correctAnswer;

  QuizItem({required this.question, required this.options, required this.correctAnswer});
}

class TaskCard extends StatelessWidget {
  final ContentItem item;

  TaskCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Checkbox(
              value: item.isCompleted,
              onChanged: (value) {
                // Update the tickbox status
                // Add logic for handling state or additional actions if needed
                // For now, just toggle the checkbox
                if (value != null) {
                  item.isCompleted = value;
                }
              },
            ),
            SizedBox(width: 16.0),
            Expanded(
              child: Text(
                item.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class ContentCard extends StatefulWidget {
  final ContentItem item;

  ContentCard({required this.item});

  @override
  _ContentCardState createState() => _ContentCardState();
}

class _ContentCardState extends State<ContentCard> {
  String aiContent = '';
  TextEditingController promptController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.item.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            SizedBox(height: 8.0),
            TextField(
              controller: promptController,
              decoration: InputDecoration(
                hintText: 'Enter a prompt for AI content generation',
              ),
            ),
            SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: () {
                generateAIContent(promptController.text);
              },
              child: Text('Generate Content'),
            ),
            SizedBox(height: 8.0),
            Text(aiContent.isNotEmpty ? aiContent : 'Generated content will appear here'),
          ],
        ),
      ),
    );
  }

  Future<void> generateAIContent(String prompt) async {
    // TODO: Add your OpenAI API key
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

      if (mounted) {
        setState(() {
          aiContent = aiResult;
        });
      }
    } else {
      // Handle errors
      print('Failed to fetch AI response. Status code: ${response.statusCode}');
      print('API Response: ${response.body}');
    }
  }

  @override
  void dispose() {
    promptController.dispose();
    super.dispose();
  }
}


class QuizCard extends StatefulWidget {
  final QuizItem item;

  QuizCard({required this.item});

  @override
  _QuizCardState createState() => _QuizCardState();
}

class _QuizCardState extends State<QuizCard> {
  List<String> quizOptions = [];
  String selectedOption = '';
  bool showFeedback = false;

  @override
  void initState() {
    super.initState();

    // Fetch AI-generated quizzes when the widget is initialized
    fetchAIQuizzes();
  }

  Future<void> fetchAIQuizzes() async {
    // TODO: Replace 'YOUR_OPENAI_API_KEY' with your actual OpenAI API key
    const String apiKey = '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';
    const String model = 'gpt-3.5-turbo-instruct';

    final Uri apiUrl = Uri.parse('https://api.openai.com/v1/engines/$model/completions');

    final http.Response response = await http.post(
      apiUrl,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'prompt': widget.item.question,
        'max_tokens': 200,
      }),
    );

    if (response.statusCode == 200) {
      // Parse and use the AI-generated response
      final Map<String, dynamic> data = jsonDecode(response.body);
      final String aiResult = data['choices'][0]['text'];

      // Split the AI-generated content into quiz options
      final List<String> options = aiResult.split('\n').where((option) => option.isNotEmpty).toList();

      if (mounted) {
        setState(() {
          quizOptions.addAll(options);
        });
      }
    } else {
      // Handle errors
      print('Failed to fetch AI response. Status code: ${response.statusCode}');
      print('API Response: ${response.body}');
    }
  }

  void checkAnswer() {
    setState(() {
      showFeedback = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.item.question,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            SizedBox(height: 8.0),
            // Display quiz options
            ...quizOptions.map(
              (option) => RadioListTile(
                title: Text(option),
                value: option,
                groupValue: selectedOption,
                onChanged: (value) {
                  setState(() {
                    selectedOption = value.toString();
                    showFeedback = false; // Reset feedback on option change
                  });
                },
              ),
            ).toList(),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                checkAnswer();
              },
              child: Text('Submit Answer'),
            ),
            SizedBox(height: 8.0),
            // Display feedback
            if (showFeedback)
              Text(
                selectedOption == widget.item.correctAnswer ? 'Correct!' : 'Wrong!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: selectedOption == widget.item.correctAnswer ? Colors.green : Colors.red,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: FinancialLiteracyPage(),
  ));
}

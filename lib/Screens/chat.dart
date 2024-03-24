import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_document_picker/flutter_document_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:pdf/pdf.dart' as pdf;
import 'package:pdf/widgets.dart' as pw;
import 'package:read_pdf_text/read_pdf_text.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:flutter_tts/flutter_tts.dart';


// Create a custom ChatUser class to include the avatar property
class CustomChatUser extends ChatUser {
  final String avatar;

  CustomChatUser({
    required String id,
    required String firstName,
    required String lastName,
    required this.avatar,
  }) : super(id: id, firstName: firstName, lastName: lastName);
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final String OPENAI_API_KEY;
  late final OpenAI _openAI;
  String? _attachedFilePath;
  FlutterTts flutterTts = FlutterTts(); // Initialize TTS engine
  _ChatScreenState() {
    OPENAI_API_KEY = "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";
    _openAI = OpenAI.instance.build(
      token: OPENAI_API_KEY,
      baseOption: HttpSetup(
        receiveTimeout: const Duration(seconds: 5),
      ),
      enableLog: true,
    );
  }

  final CustomChatUser _currentuser = CustomChatUser(
    id: '1',
    firstName: 'Arinn',
    lastName: 'Danish',
    avatar: 'assets/user_avatar.png',
  );
  final CustomChatUser _gptChatUser = CustomChatUser(
    id: '2',
    firstName: 'Intelli-Fintech',
    lastName: 'Wallet Advisor',
    avatar: 'assets/bot_avatar.png',
  );
  List<ChatMessage> _messages = [];
  List<ChatUser> _typingUsers = [];

  @override
  void initState() {
    super.initState();
    _sendInitialBotMessage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 207, 173, 216),
        title: const Text(
          'Wallet Advisor 🤖',
          style: TextStyle(
            color: Colors.black, // Change text color to black
          ),
        ),
      ),
      body: Stack(
        children: [ // Background image
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage('https://t3.ftcdn.net/jpg/03/44/52/88/360_F_344528805_o1LwyPDkkDZ7TEbTE5J08e9m00ZifmGK.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Column(
          children: [
          Expanded(
            child: DashChat(
              currentUser: _currentuser,
              typingUsers: _typingUsers,
              messageOptions: const MessageOptions(
                containerColor: Color.fromARGB(255, 207, 173, 216),
              ),
              onSend: getChatResponse,
              messages: _messages,
            ),
          ),
          // Buttons and prompt suggestions
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => onButtonPressed("Check spending"),
                        child: Text("Check spending"),
                      ),
                      ElevatedButton(
                        onPressed: () => onButtonPressed("Check savings"),
                        child: Text("Check savings"),
                      ),
                      ElevatedButton(
                        onPressed: () => onButtonPressed("Budget analysis"),
                        child: Text("Budget analysis"),
                      ),
                      ElevatedButton(
                        onPressed: () => onButtonPressed("Financial tips"),
                        child: Text("Financial tips"),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await _pickAndSendFile();
                        },
                        child: Text("Attach Document"),
                      )
                      
                      

                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ]));
  }

  Future<void> speakResponse(String response) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(response);
  }

  Future<void> getChatResponse(ChatMessage m) async {
    setState(() {
      _messages.insert(0, m);
      _typingUsers.add(_gptChatUser);
    });
    List<Messages> _messagesHistory = _messages.reversed.map((m) {
      if (m.user == _currentuser) {
        return Messages(role: Role.user, content: m.text);
      } else {
        return Messages(role: Role.assistant, content: m.text);
      }
    }).toList();
    final request = ChatCompleteText(model: GptTurbo0631Model(), messages: _messagesHistory, maxToken: 200);
    final response = await _openAI.onChatCompletion(request: request);
    for (var element in response!.choices) {
      if (element.message != null) {
        setState(() {
          _messages.insert(0, ChatMessage(user: _gptChatUser, createdAt: DateTime.now(), text: element.message!.content));
        });
         // Speak the GPT-User's response
        speakResponse(element.message!.content);
      }
    }
    setState(() {
      _typingUsers.remove(_gptChatUser);
    });
  }

  void _sendInitialBotMessage() {
    final initialBotMessage = ChatMessage(
      user: _gptChatUser,
      text: "hi I am Intelli-FinTech, your Personalized Financial-responsible Wallet Advisor! How can I assist you today?",
      createdAt: DateTime.now(),
    );
    setState(() {
      _messages.insert(0, initialBotMessage);
    });
  }

  void _sendPromptMessage(String prompt) {
    final promptMessage = ChatMessage(
      user: _currentuser,
      text: prompt,
      createdAt: DateTime.now(),
    );
    setState(() {
      _messages.insert(0, promptMessage);
    });
  }

  void onButtonPressed(String prompt) async {
    if (prompt == "Check spending") {
      final spendingResponse = ChatMessage(
        user: _currentuser,
        text: prompt,
        createdAt: DateTime.now(),
      );
      setState(() {
        _messages.insert(0, spendingResponse);
      });

      await Future.delayed(const Duration(seconds: 1)); // Simulating delay before bot response

      final botResponse = ChatMessage(
        user: _gptChatUser,
        text: "Sure! Let's check your spending.\n\nIn Q1 2024, total spending tracked is RM3540. \n\nHere are some tips to manage your expenses and save money:\n\n1. Create a budget to track your income and expenses.\n2. Identify non-essential expenses and consider cutting back.\n3. Explore ways to increase your income, like freelancing or part-time work.\n4. Take advantage of discounts and rewards programs.\n5. Consider long-term savings and investments.\n\nHow can I assist you further?",
        createdAt: DateTime.now(),
      );
      setState(() {
        _messages.insert(0, botResponse);
      });
    } else if (prompt == "Check savings") {
      final savingsResponse = ChatMessage(
        user: _currentuser,
        text: prompt,
        createdAt: DateTime.now(),
      );
      setState(() {
        _messages.insert(0, savingsResponse);
      });

      await Future.delayed(const Duration(seconds: 1)); // Simulating delay before bot response

      final botResponse = ChatMessage(
        user: _gptChatUser,
        text: "Great choice! Checking your savings is a smart financial move.\n\n In Q1 2024, total savings tracked is RM1380. \n\nHere are some tips to maximize your savings:\n\n1. Set specific savings goals.\n2. Automate your savings by setting up regular transfers.\n3. Consider high-interest savings accounts.\n4. Review and adjust your budget regularly.\n5. Look for additional income streams.\n\nNeed more assistance?",
        createdAt: DateTime.now(),
      );
      setState(() {
        _messages.insert(0, botResponse);
      });
    } else if (prompt == "Budget analysis") {
      final budgetAnalysisResponse = ChatMessage(
        user: _currentuser,
        text: prompt,
        createdAt: DateTime.now(),
      );
      setState(() {
        _messages.insert(0, budgetAnalysisResponse);
      });

      await Future.delayed(const Duration(seconds: 1)); // Simulating delay before bot response

      final botResponse = ChatMessage(
        user: _gptChatUser,
        text: "Certainly! Performing a budget analysis is a crucial step for financial planning.\n\nHere's how you can conduct a budget analysis:\n\n1. Review your income sources.\n2. Categorize and track your expenses.\n3. Identify areas for potential savings.\n4. Compare your actual spending to your budget.\n5. Make adjustments to improve your financial health.\n\nReady to take control of your budget?",
        createdAt: DateTime.now(),
      );
      setState(() {
        _messages.insert(0, botResponse);
      });
    } else if (prompt == "Financial tips") {
      final financialTipsResponse = ChatMessage(
        user: _currentuser,
        text: prompt,
        createdAt: DateTime.now(),
      );
      setState(() {
        _messages.insert(0, financialTipsResponse);
      });

      await Future.delayed(const Duration(seconds: 1)); // Simulating delay before bot response

      final botResponse = ChatMessage(
        user: _gptChatUser,
        text: "Absolutely! Here are some valuable financial tips:\n\n1. Build an emergency fund for unexpected expenses.\n2. Diversify your investments for long-term growth.\n3. Pay off high-interest debt to save on interest payments.\n4. Review and understand your credit report.\n5. Stay informed about financial news and opportunities.\n\nReady to implement these tips for a stronger financial future?",
        createdAt: DateTime.now(),
      );
      setState(() {
        _messages.insert(0, botResponse);
      });
    } else {
      _sendPromptMessage(prompt);
    }
  }

    Future<void> _pickAndSendFile() async {
  try {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.isNotEmpty) {
      String filePath = result.files.first.path!;
      print('Selected document: $filePath');

      await _analyzeAndProvideInsights(filePath);

      setState(() {
        _attachedFilePath = filePath;
      });

      _sendPromptMessage("Attached file: ${filePath.split('/').last}");
    } else {
      print('Document picking canceled.');
      _sendPromptMessage("File attachment canceled.");
    }
  } catch (e) {
    print('Error picking document: $e');
    _sendPromptMessage("Error picking file. Please try again.");
  }
}

  Future<void> _analyzeAndProvideInsights(String filepath) async {
  try {
    final document = PdfDocument(inputBytes: await File(filepath).readAsBytes());

    // final StringBuffer extractedTextBuffer = StringBuffer();

    // document.pages.forEach((page) {
    //   extractedTextBuffer.write(page.text);
    //   extractedTextBuffer.write('\n'); // Add a newline between pages
    // });

    // final extractedText = extractedTextBuffer.toString();
    String text = PdfTextExtractor(document).extractText();
    document.dispose();

    print('Extracted Text:\n$text');

    // After extracting the text, send it to OpenAI for financial advice
    await _sendToOpenAI(text);
  } catch (e) {
    print('Error extracting text from PDF: $e');
  }
}


Future<void> _sendToOpenAI(String content) async {
  try {
    final botResponse = ChatMessage(
      user: _gptChatUser,
      text: "Processing the attached document...",
      createdAt: DateTime.now(),
    );

    setState(() {
      _messages.insert(0, botResponse);
    });

    // Define your predefined financial advice prompt
    String prompt = "Direct to the point and avoid extra words, Provide summarization and financial advice which divided into 2 main parts: financial analytics of usage and recommendation in future usage based on the attached document:\n$content";

    // Send the predefined prompt to OpenAI
    final request = ChatCompleteText(
      model: GptTurbo0631Model(),
      messages: [Messages(content: prompt, role: Role.system)],
      maxToken: 200,
    );

    final response = await _openAI.onChatCompletion(request: request);

    // Process the OpenAI response and update the chat
    if (response?.choices.isNotEmpty == true && response?.choices.first.message?.content != null) {
      final openAIResponse = ChatMessage(
        user: _gptChatUser,
        text: "Financial Advisor says: ${response?.choices.first.message?.content}",
        createdAt: DateTime.now(),
      );

      setState(() {
        _messages.insert(0, openAIResponse);
      });

      // Speak the financial advisor's response
      speakResponse(response?.choices.first.message?.content ?? "");
    }
  } catch (e) {
    print("Error processing the document: $e");
    // Handle the error, you can show a message to the user if needed
  }
}
}

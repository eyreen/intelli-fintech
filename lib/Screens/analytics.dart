import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Analytics extends StatefulWidget {
  const Analytics({Key? key});

  @override
  State<Analytics> createState() => _AnalyticsState();
}

class _AnalyticsState extends State<Analytics> {
  late Uint8List chartImageBytes;
  String? aiInsightsResult;
  @override
  void initState() {
    super.initState();
    // Call the asynchronous method to fetch chart image bytes
    _loadChartImageBytes();
  }

  Future<void> _loadChartImageBytes() async {
    // Replace this with the logic to capture the chart as an image
    // For simplicity, returning an empty list

    setState(() {}); // Trigger a rebuild after loading the image bytes
  }
  
  Future<void> generatePdf() async {

    bool _isValidChartImage(Uint8List imageData) {
      // Replace this check with the actual validation logic
      return imageData != null && imageData.isNotEmpty;
    }
    // Function to convert the chart to image bytes
    Future<Uint8List> chartToImageBytes() async {
      return Uint8List(0);
    }

    // Function to convert the doughnut chart to image bytes
    Future<Uint8List> doughnutChartToImageBytes() async {
      return Uint8List(0);
    }

    final pdf = pw.Document();
    final Uint8List chartImageBytes = await chartToImageBytes();
    final Uint8List doughnutChartImageBytes = await doughnutChartToImageBytes();

    // Add content to the PDF
    pdf.addPage(
      await pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Add the chart as an image (with validation)
              pw.Image(
                pw.MemoryImage(
                  _isValidChartImage(chartImageBytes) ? chartImageBytes : Uint8List(0)
                )
              ),
              pw.Header(
                level: 1,
                text: 'Financial Analytics Report',
              ),
              pw.Paragraph(
                text:
                    'In this report, we provide an overview of your financial analytics for Q1 2024.',
              ),
              pw.Divider(),
              pw.Header(
                level: 2,
                text: 'Financial Comparison',
              ),
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Aimed Budget', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text('\$8000', style: pw.TextStyle(fontSize: 18, color: PdfColors.green)),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Actual Spend', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text('\$6500', style: pw.TextStyle(fontSize: 18, color: PdfColors.red)),
                      ],
                    ),
                  ),
                ],
              ),
              pw.Divider(),
              pw.Header(
                level: 2,
                text: 'Financial Usage Report',
              ),
              // Add the chart as an image
              pw.Image(pw.MemoryImage(chartImageBytes)),
              pw.Divider(),
              pw.Header(
                level: 2,
                text: 'Categorized Overall Usage',
              ),
              // Add the doughnut chart as an image
              pw.Image(pw.MemoryImage(doughnutChartImageBytes)),
              pw.Divider(),
              pw.Header(
                level: 2,
                text: 'Insights',
              ),
              pw.Paragraph(
                text:
                    'You have exceeded your budget for the quarter. Consider reviewing your spending on specific categories.',
              ),
            ],
          );
        },
      ),
    );

    // Save the PDF to a file
    final Uint8List bytes = await pdf.save();
    final Directory directory = await getApplicationDocumentsDirectory();
    final String path = '${directory.path}/financial_report.pdf';
    final File file = File(path);
    await file.writeAsBytes(bytes);

    // Open the PDF file or share it with the user
    await Printing.sharePdf(bytes: bytes, filename: 'financial_report.pdf');
  }

  Future<void> getAIInsights() async {
    // TODO: Replace 'YOUR_OPENAI_API_KEY' with your actual OpenAI API key
    const String apiKey = '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';

    final String prompt = """
    Financial Overall Analysis:

    Aimed Budget: \$8000
    Actual Spend: \$6500
    Linked E-wallets: 5
    Linked Bank Cards: 3
    Monthly Spending Trend: [30, 40, 25, 50, 45] (Jan to May)
    Spending Categories: [20%, 15%, 10%, 30%, 15%, 10%] (Food/Drinks, Transportation, Services, Grocery, Utilities, Others)
    Top Spending Categories:
    1. Grocery - \$1500
    2. Utilities - \$1200
    3. Entertainment - \$800

    Provide insights and recommendations for future improvement.
    """;

    final String model = 'gpt-3.5-turbo-instruct';

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
      // Parse and use the AI-generated insights
      final Map<String, dynamic> data = jsonDecode(response.body);
      final String aiInsights = data['choices'][0]['text'];

      // Update the state to trigger a rebuild and display AI insights on screen
      setState(() {
        aiInsightsResult = aiInsights;
      });
    } else {
      // Handle errors
      print('Failed to fetch AI insights. Status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 207, 173, 216),
        title: const Text(
          'Analytical Dashboard 📊',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
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
      
      SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Comparison Section
            Row(
              children: [
                Expanded(
                  child: Card(
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
                            'Aimed Budget',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '\$8000', // Add your aimed budget value
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
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
                            'Actual Spend',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '\$6500', // Add your actual spending value
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Card(
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
                            'Linked E-wallets',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '\5', // Add your aimed budget value
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
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
                            'Linked Bank Cards',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '\3', // Add your actual spending value
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Card(
              margin: EdgeInsets.all(16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Stack(
                  children: [
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Add any additional widgets as needed
                        ],
                      ),
                    ),
                    SfCartesianChart(
                      primaryXAxis: CategoryAxis(),
                      title: ChartTitle(
                        text: 'Financial Usage Report in Q1 2024',
                        textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      tooltipBehavior: TooltipBehavior(enable: true),
                      series: <LineSeries<_ChartData, String>>[
                        LineSeries<_ChartData, String>(
                          dataSource: <_ChartData>[
                            _ChartData('Jan', 30),
                            _ChartData('Feb', 40),
                            _ChartData('Mar', 25),
                            _ChartData('Apr', 50),
                            _ChartData('May', 45),
                          ],
                          xValueMapper: (_ChartData sales, _) => sales.month,
                          yValueMapper: (_ChartData sales, _) => sales.value,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Card(
              margin: EdgeInsets.all(16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SfCircularChart(
                  title: ChartTitle(
                    text: 'Categorized Overall Usage in Q1 2024',
                    textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  series: <CircularSeries>[
                    DoughnutSeries<_ExpenseData, String>(
                      dataSource: <_ExpenseData>[
                        _ExpenseData('Food/Drinks', 20),
                        _ExpenseData('Transportation', 15),
                        _ExpenseData('Services', 10),
                        _ExpenseData('Grocery', 30),
                        _ExpenseData('Utilities', 15),
                        _ExpenseData('Others', 10),
                      ],
                      xValueMapper: (_ExpenseData data, _) => data.category,
                      yValueMapper: (_ExpenseData data, _) => data.amount,
                      dataLabelSettings: DataLabelSettings(
                        isVisible: true,
                        labelPosition: ChartDataLabelPosition.outside,
                        connectorLineSettings: ConnectorLineSettings(
                          type: ConnectorType.curve,
                          length: '10%',
                        ),
                      ),
                      dataLabelMapper: (_ExpenseData data, _) =>
                          '${data.category}\n${data.amount}%',
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 5), // Adjust the height between the comparison cards
            // Additional Content
            Card(
              margin: EdgeInsets.all(16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Top Spending Categories',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    DataTable(
                      columns: [
                        DataColumn(
                          label: Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Spending Amount', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                      rows: [
                        DataRow(cells: [
                          DataCell(Text('1. Grocery')),
                          DataCell(Text('\$1500', style: TextStyle(color: Colors.red))),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('2. Utilities')),
                          DataCell(Text('\$1200', style: TextStyle(color: Colors.red))),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('3. Entertainment')),
                          DataCell(Text('\$800', style: TextStyle(color: Colors.red))),
                        ]),
                        // Add more rows as needed
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await generatePdf();
                    },
                    child: Text('Download Report'),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () async {
                      await getAIInsights();
                      
                    },
                    child: Text('AI Insights'),
                  ),
          ]),
            ),
            Column(
            children: [
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  // Add your logic for the "Create New" button here
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 180, 143, 185), // Set the button background color
                ),
                child: Text('Create New', style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))), 
              ),
            ],
          ),

            // Display AI insights result if available
            if (aiInsightsResult != null)
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
                        'AI Insights',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(aiInsightsResult!),
                    ],
                  ),
                ),
              ),
            SizedBox(height: 3),
          ],
        ),
      ),
    ]));
  }
}

class _ChartData {
  _ChartData(this.month, this.value);

  final String month;
  final double value;
}

class _ExpenseData {
  _ExpenseData(this.category, this.amount);

  final String category;
  final double amount;
}

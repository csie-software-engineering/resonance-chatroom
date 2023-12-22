import 'dart:math';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' hide TextStyle;

class HostQuestionStatisticPage extends StatelessWidget {
  const HostQuestionStatisticPage({super.key});

  static const routeName = '/horizontal_bar_chart';

  @override
  Widget build(BuildContext context) {
    final seriesList = _createSampleData();
    return BarChart(
      seriesList,
      animate: true,
      vertical: false,
    );
  }

  static List<Series<OrdinalSales, String>> _createSampleData() {
    final random = Random();
    final data = [
      OrdinalSales('項目1', random.nextInt(101)),
      OrdinalSales('項目2', random.nextInt(101)),
      OrdinalSales('項目3', random.nextInt(101)),
      OrdinalSales('項目4', random.nextInt(101)),
    ];

    return [
      Series<OrdinalSales, String>(
        id: '銷售量',
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: data,
      )
    ];
  }
}

class OrdinalSales {
  final String year;
  final int sales;

  OrdinalSales(this.year, this.sales);
}

class CombinedBarChartsPage extends StatelessWidget {
  const CombinedBarChartsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('統計圖'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: List.generate(10, (index) {
            int chartIndex = index + 1;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    '統計圖 $chartIndex', // 從這裡開始添加標題（從1開始）
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  const SizedBox(
                    height: 200, // 根據需要調整高度
                    child: HostQuestionStatisticPage(),
                  ),
                  const Divider(
                    // 在每個統計圖之後添加一個Divider
                    color: Colors.grey,
                    thickness: 1.0,
                    height: 20,
                    indent: 20,
                    endIndent: 20,
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

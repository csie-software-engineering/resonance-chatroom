import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/providers.dart';

class HostQuestionStatisticPageArguments {
  final String activityId;

  const HostQuestionStatisticPageArguments(this.activityId);
}

class HostQuestionStatisticPage extends StatelessWidget {
  const HostQuestionStatisticPage({super.key});

  static const routeName = '/host_question_statistic';

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments
        as HostQuestionStatisticPageArguments;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '問卷統計',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Container(
        color: Theme.of(context).colorScheme.background,
        child: SingleChildScrollView(
          child: FutureBuilder<List<Question>>(
            future:
                context.read<ActivityProvider>().getAllQuestions(args.activityId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final questions = snapshot.data as List<Question>;
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final question = questions[index];
                  return Column(
                    children: [
                      Divider(
                        height: MediaQuery.of(context).size.height * 0.03,
                        color: index == 0 ? Colors.transparent : Colors.grey,
                      ),
                      Text(
                        question.questionName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      FutureBuilder<List<int>>(
                        future: context.read<QuestionProvider>().getReplyResult(
                              args.activityId,
                              question.uid,
                            ),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          final result = snapshot.data!;
                          final seriesList = [
                            charts.Series<int, String>(
                              id: question.uid,
                              domainFn: (_, index) => question.choices[index!],
                              measureFn: (int value, _) => value,
                              data: result,
                            )
                          ];
                          return SizedBox(
                            height: MediaQuery.of(context).size.height * 0.2,
                            child: charts.BarChart(
                              seriesList,
                              animate: true,
                              vertical: false,
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
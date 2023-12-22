import 'package:flutter/material.dart';
import 'package:resonance_chatroom/models/models.dart';

class QuestionDialog extends StatefulWidget {
  const QuestionDialog({super.key, required this.questionAnswers, required this.currentQuestion});

  final List<bool> questionAnswers;
  final Question currentQuestion;

  @override
  State<QuestionDialog> createState() => _QuestionDialogState();
}

class _QuestionDialogState extends State<QuestionDialog> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount:  widget.currentQuestion
          .choices.length,
      itemBuilder:
          (BuildContext context,
          int index) {
        return Padding(
          padding:
          const EdgeInsets.only(
              top: 8.0,
              bottom: 8.0,
              right: 4),
          child: Container(
            decoration: BoxDecoration(
                color: Theme.of(
                    context)
                    .colorScheme
                    .inversePrimary
                    .withAlpha(200),
                borderRadius:
                BorderRadius
                    .circular(12),
                // color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Theme.of(
                          context)
                          .colorScheme
                          .secondary
                          .withOpacity(
                          0.4),
                      blurRadius: 1,
                      spreadRadius: 0,
                      offset:
                      const Offset(
                          2, 2))
                ]),
            child: CheckboxListTile(
              title: Text(
                  widget.currentQuestion
                      .choices[index],
                  style: TextStyle(
                      color: Theme.of(
                          context)
                          .colorScheme
                          .onSurface)),
              value:
              widget.questionAnswers[
              index],
              onChanged:
                  (bool? newValue) {
                setState(() {
                  widget.questionAnswers[
                  index] =
                      newValue ??
                          false;
                });
              },
            ),
          ),
        );
      },
    );
  }
}

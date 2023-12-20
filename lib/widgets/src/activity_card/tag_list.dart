import '../../../models/src/activities.dart';
import 'package:flutter/material.dart';

class Tags extends StatefulWidget {
  const Tags({super.key, required this.tagList, required this.tagSelectedTmp});

  final List<Tag> tagList;
  final List<bool> tagSelectedTmp;

  @override
  State<Tags> createState() => _TagsState();
}

class _TagsState extends State<Tags> {

  @override
  Widget build(BuildContext context) {

    // widget.tagSelected.forEach((key, value) {
    //   print('Key: $key, Value: $value');
    // });

    return ListView.builder(
      itemCount: widget.tagList.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, right: 4),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.inversePrimary.withAlpha(200),
                borderRadius: BorderRadius.circular(12),
                // color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.4),
                    blurRadius: 1,
                    spreadRadius: 0,
                    offset: const Offset(2, 2)
                  )
                ]
              ),
              child: CheckboxListTile(
                  title: Text(widget.tagList[index].tagName,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface
                  )),
                  value: widget.tagSelectedTmp[index],
                  onChanged: (bool? newValue){
                    setState(() {
                      widget.tagSelectedTmp[index] = newValue ?? false;
                    });
                  },
              ),
            ),
          );
        },
    );
  }
}

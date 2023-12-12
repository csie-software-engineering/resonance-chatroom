import 'package:flutter/material.dart';

class Tags extends StatefulWidget {
  const Tags({super.key});

  @override
  State<Tags> createState() => _TagsState();
}

class _TagsState extends State<Tags> {

  List<bool> itemStates = List.generate(10, (index) => false);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10,
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
                    color: Theme.of(context).colorScheme.inverseSurface.withOpacity(0.4),
                    blurRadius: 1,
                    spreadRadius: 0,
                    offset: Offset(2, 2)
                  )
                ]
              ),
              child: CheckboxListTile(
                  title: Text("${index.toString()}++++++++++++++++++++++++++++++++++++",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onInverseSurface
                  )),
                  value: itemStates[index],
                  onChanged: (bool? newValue){
                    setState(() {
                      itemStates[index] = newValue ?? false;
                    });
                  },
              ),
            ),
          );
        },
    );
  }
}

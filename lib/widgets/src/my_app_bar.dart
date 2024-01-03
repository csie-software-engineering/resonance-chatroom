import 'package:flutter/material.dart';

AppBar myAppBar(BuildContext context, {Widget? title, Widget? leading}) =>
    AppBar(
      toolbarHeight: 50 + MediaQuery.of(context).size.height * 0.03,
      title: title,
      centerTitle: true,
      titleSpacing: 5,
      titleTextStyle: TextStyle(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.bold,
        fontSize: 28,
      ),
      leading: leading,
      leadingWidth: 80,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
    );

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final Widget? tail;

  CustomAppBar({super.key, required this.title, required this.leading, required this.tail});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: MediaQuery
            .of(context)
            .padding
            .top),
        Container(
          height: kToolbarHeight,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.6),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 4,
                offset: const Offset(0, 2), // 阴影位置，可以调整阴影的方向
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.centerRight,
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                  color: Theme
                      .of(context)
                      .colorScheme
                      .surface
                      .withOpacity(0.5),
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                          color: Theme
                              .of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.7),
                          borderRadius: const BorderRadius.all(
                              Radius.circular(16)),
                          boxShadow: [
                            BoxShadow(
                              color: Theme
                                  .of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.2),
                              offset: const Offset(2, 2),
                              blurRadius: 2,
                              spreadRadius: 1,
                            )
                          ]),
                      padding: const EdgeInsets.symmetric(
                          vertical: 3, horizontal: 20.0),
                      child: Text(title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Theme
                                .of(context)
                                .colorScheme
                                .onInverseSurface,
                          )),
                    ),
                  ),
                ),
              ),
              leading != null ? Align(
                alignment: Alignment.centerLeft,
                child: leading!,
              ) : const SizedBox(),
              tail != null ? Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Theme
                          .of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.7),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Theme
                              .of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.2),
                          offset: const Offset(2, 2),
                          blurRadius: 2,
                          spreadRadius: 1,
                        )
                      ],
                    ),
                    child: tail!,
                  ),
                ),
              ) : const SizedBox()
            ],
          ),
        ),
      ],
    );
  }
}



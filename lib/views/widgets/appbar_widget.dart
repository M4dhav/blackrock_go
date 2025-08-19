import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget leadingWidget;
  final Widget actionWidgets;
  final Widget? titleWidget;

  const CustomAppBar({
    super.key,
    required this.leadingWidget,
    required this.actionWidgets,
    this.titleWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20), // Only bottom-left is rounded
          bottomRight: Radius.circular(20), // Only bottom-right is rounded
        ),

        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.grey.shade300,
        //     blurRadius: 5,
        //     offset: const Offset(0, 3),
        //   ),
        // ],

        border: Border(
          bottom: BorderSide(color: Color(0xffb4914b), width: 2),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 13),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              leadingWidget,
              titleWidget ?? const SizedBox.shrink(),
              actionWidgets,
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(10.h); // Increased height
}

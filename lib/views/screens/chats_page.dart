import 'package:blackrock_go/models/const_model.dart';
import 'package:blackrock_go/views/widgets/appbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ChatsPage extends StatelessWidget {
  const ChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/bg.png'), fit: BoxFit.cover)),
      child: Scaffold(
        appBar: CustomAppBar(
          titleWidget: Text(
            'Messages',
            style: TextStyle(color: Constants.primaryGold, fontSize: 22.px),
          ),
        ),
        backgroundColor: Colors.transparent,
        body: SizedBox(
          height: 21.h,
          child: Card(
            color: Colors.black,
            borderOnForeground: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.px),
              side: BorderSide(color: Constants.primaryGold, width: 2.px),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () => context.push('/channelsPage'),
                    child: ListTile(
                      title: Text(
                        'Channels',
                        style: TextStyle(color: Colors.white, fontSize: 22.px),
                      ),
                      leading: Icon(
                        Icons.groups_outlined,
                        color: Constants.primaryGold,
                        size: 25.sp,
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.grey,
                        size: 22.sp,
                      ),
                    ),
                  ),
                  Divider(
                    color: Colors.grey,
                    thickness: 1,
                  ),
                  InkWell(
                    onTap: () => context.push('/directMessagesPage'),
                    child: ListTile(
                      title: Text(
                        'Direct Messages',
                        style: TextStyle(color: Colors.white, fontSize: 22.px),
                      ),
                      leading: Icon(
                        Icons.person_3_rounded,
                        color: Constants.primaryGold,
                        size: 25.sp,
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.grey,
                        size: 22.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

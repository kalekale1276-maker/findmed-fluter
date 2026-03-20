import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/tailwind_extensions.dart';

class EmergencyPage extends StatelessWidget {
  const EmergencyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency'),
        backgroundColor: TailwindColors.red500,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(context.responsivePaddingLg),
                decoration: BoxDecoration(
                  color: TailwindColors.red50,
                  borderRadius: BorderRadius.circular(TailwindRadius.lg),
                  border: Border.all(color: TailwindColors.red200),
                ),
                child: Icon(
                  Icons.emergency,
                  size: context.responsiveText2Xl,
                  color: TailwindColors.red500,
                ),
              ),
              SizedBox(height: context.responsiveGap),
              Text(
                'Emergency Contacts',
                style: TextStyle(
                  fontSize: context.responsiveTextLg,
                  fontWeight: FontWeight.bold,
                  color: TailwindColors.gray900,
                ),
              ),
              SizedBox(height: context.responsiveGapSm),
              Text(
                'Get immediate medical help',
                style: TextStyle(
                  fontSize: context.responsiveText,
                  color: TailwindColors.gray600,
                ),
              ),
              SizedBox(height: context.responsiveGapLg),
              Container(
                width: double.infinity,
                height: context.isMobile ? 50.h : 56.h,
                decoration: BoxDecoration(
                  color: TailwindColors.red500,
                  borderRadius: BorderRadius.circular(TailwindRadius.lg),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      // TODO: Implement emergency call
                    },
                    borderRadius: BorderRadius.circular(TailwindRadius.lg),
                    child: Center(
                      child: Text(
                        'Call Emergency',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: context.responsiveText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

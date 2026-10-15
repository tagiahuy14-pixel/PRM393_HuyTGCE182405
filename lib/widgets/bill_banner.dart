import 'package:flutter/material.dart';

class BillBanner extends StatelessWidget {
  const BillBanner({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 126,
    width: double.infinity,
    child: Image.asset(
      'assets/images/bills_banner_v2.png',
      fit: BoxFit.cover,
      alignment: Alignment.center,
    ),
  );
}

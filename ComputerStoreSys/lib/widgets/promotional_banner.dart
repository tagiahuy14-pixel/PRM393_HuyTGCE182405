import 'package:flutter/material.dart';

class PromotionalBanner extends StatelessWidget {
  final double height;

  const PromotionalBanner({super.key, this.height = 175});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          'assets/images/banner.png',
          width: double.infinity,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Documented graceful fallback if local asset is unavailable
            return Container(
              width: double.infinity,
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF0D1B2A),
                    Color(0xFF1B263B),
                    Color(0xFF415A77),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Stack(
                children: [
                  Positioned(
                    right: -20,
                    bottom: -20,
                    child: Icon(
                      Icons.computer,
                      size: 150,
                      color: Colors.white10,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.bolt, color: Colors.amber, size: 24),
                            SizedBox(width: 8),
                            Text(
                              'MEGA TECH STORE',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'High-Performance Laptops, Desktops & Components',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '⚡ Up to 40% OFF on Selected Gear',
                          style: TextStyle(
                            color: Colors.amberAccent,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

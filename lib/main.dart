/*import 'package:flutter/material.dart';
import 'package:shop_easy/home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomePage());
  }
}*/

/*import 'package:flutter/material.dart';

import 'plance.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: plancePage());
  }
}
*/

/*
import 'package:flutter/material.dart';

import 'slider.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: SliderPage());
  }
}
*/

/*
import 'package:flutter/material.dart';

import 'thehoso.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TheHoSo(),
    );
  }
}
*/
/*
import 'package:flutter/material.dart';

import 'product_card.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: const Center(
          child: ProductCard(
            name: 'Laptop Dell Inspiron 15 3520 Core i5 Ram 16GB SSD 512GB Full HD',
            imageUrl: '',
            discountPercent: 25,
            rating: 4.8,
            reviewCount: 1200,
            price: 21990000,
            originalPrice: 28990000,
          ),
        ),
      ),
    );
  }
}
*/
import 'package:flutter/material.dart';

import 'login_screen.dart';
import 'settings_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Lắng nghe công tắc chế độ tối: gạt là cả app đổi theme ngay
    return ValueListenableBuilder<bool>(
      valueListenable: darkModeNotifier,
      builder: (context, isDark, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'ShopEasy',
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.blue,
            brightness: Brightness.dark,
          ),
          home: const LoginScreen(),
        );
      },
    );
  }
}

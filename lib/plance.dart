import 'package:flutter/material.dart';

class plancePage extends StatelessWidget {
  const plancePage({super.key});

  // Cột gồm Icon (màu xanh) + Text, dùng cho CALL / ROUTE / SHARE
  Widget buildButton(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(height: 8),
        Text(text, style: const TextStyle(color: Colors.blue)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Ảnh
            Image.network(
              'https://live.staticflickr.com/7509/16343408071_cdd7e6fc12_b.jpg',
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: double.infinity,
                height: 300,
                color: Colors.grey,
                alignment: Alignment.center,
                child: const Text('Không tải được ảnh'),
              ),
            ),

            // 2. Tiêu đề + địa chỉ (bên trái), ngôi sao + 41 (bên phải)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Vancouver xinh đẹp Trần Quang Hào',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Địa chỉ: Vancouver, Canada',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.star, color: Colors.red),
                  const Text('41'),
                ],
              ),
            ),

            // 3. Hàng 3 nút, chia đều chiều ngang
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildButton(Icons.call, 'CALL'),
                buildButton(Icons.near_me, 'ROUTE'),
                buildButton(Icons.share, 'SHARE'),
              ],
            ),

            // 4. Đoạn mô tả
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Vancouver (phát âm tiếng Anh: /væŋˈkuːvər/ hay /vænˈkuːvər/), '
                'tên chính thức là Thành phố Vancouver (tiếng Anh: City of '
                'Vancouver), (tiếng Việt: Van-cu-vơ) là một đô thị hải cảng '
                'duyên hải thuộc tỉnh British Columbia, Canada và là thành phố '
                'lớn nhất tỉnh.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class SliderPage extends StatefulWidget {
  const SliderPage({super.key});

  @override
  State<SliderPage> createState() => _SliderPageState();
}

class _SliderPageState extends State<SliderPage> {
  // viewportFraction < 1 để thấy ảnh hai bên ló ra
  final PageController _controller = PageController(viewportFraction: 0.8);

  // Danh sách link ảnh
  final List<String> images = [
    'https://live.staticflickr.com/3928/15234878889_e2755dd9ed_z.jpg',
    'https://live.staticflickr.com/3930/15410852671_fda681fc5e_z.jpg',
    'https://live.staticflickr.com/7533/16104831731_880ebf6e22_z.jpg',
    'https://live.staticflickr.com/5523/11984229875_e2d8bd6dbb_z.jpg',
    'https://live.staticflickr.com/5555/14887530711_6b0f04d005_z.jpg',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget buildItem(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              images[index],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey,
                alignment: Alignment.center,
                child: const Text('Không tải được ảnh'),
              ),
            ),
            // Chữ "No. x image" ở góc dưới trái, nền mờ cho dễ đọc
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 20.0,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Color.fromARGB(200, 0, 0, 0),
                      Color.fromARGB(0, 0, 0, 0),
                    ],
                  ),
                ),
                child: Text(
                  'No. $index image',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        leading: const Icon(Icons.arrow_back_ios_new),
        title: const Text('Complicated image slider demo'),
      ),
      body: Center(
        child: SizedBox(
          height: 250,
          child: PageView.builder(
            controller: _controller,
            itemCount: images.length,
            itemBuilder: (context, index) => buildItem(index),
          ),
        ),
      ),
    );
  }
}

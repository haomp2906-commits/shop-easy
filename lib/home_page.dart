import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  BoxFit _fit = BoxFit.cover;

  void _showSnackBar(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.removeCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thực hành Widget'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Tìm kiếm',
            onPressed: () => _showSnackBar('Bạn vừa bấm Tìm kiếm'),
          ),
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              size: 30,
              color: Colors.deepOrange,
            ),
            tooltip: 'Thông báo',
            onPressed: () => _showSnackBar('Bạn vừa bấm Thông báo'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Cài đặt',
            onPressed: () => _showSnackBar('Bạn vừa bấm Cài đặt'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person_outline, size: 20),
                          SizedBox(width: 12),
                          Text('Họ tên: Trần Quang Hào (23T1020155)'),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.school_outlined, size: 20),
                          SizedBox(width: 12),
                          Text('Lớp: Lập trình Flutter N3'),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.email_outlined, size: 20),
                          SizedBox(width: 12),
                          Text('Email: Chưa cập nhật'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SegmentedButton<BoxFit>(
                  segments: const [
                    ButtonSegment(value: BoxFit.cover, label: Text('cover')),
                    ButtonSegment(
                      value: BoxFit.contain,
                      label: Text('contain'),
                    ),
                    ButtonSegment(value: BoxFit.fill, label: Text('fill')),
                  ],
                  selected: {_fit},
                  onSelectionChanged: (selection) {
                    setState(() => _fit = selection.first);
                  },
                ),
                const SizedBox(height: 16),
                Image.network(
                  'https://picsum.photos/400/300',
                  width: 300,
                  height: 200,
                  fit: _fit,
                  loadingBuilder: (context, child, progress) => progress == null
                      ? child
                      : const SizedBox(
                          width: 300,
                          height: 200,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                  errorBuilder: (context, error, stackTrace) => const SizedBox(
                    width: 300,
                    height: 200,
                    child: Center(child: Icon(Icons.broken_image, size: 64)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: 300,
                  child: Text(
                    _fit == BoxFit.cover
                        ? 'cover: lấp đầy khung, ảnh có thể bị cắt.'
                        : _fit == BoxFit.contain
                        ? 'contain: hiển thị toàn ảnh, có thể chừa khoảng trống.'
                        : 'fill: lấp đầy khung, ảnh có thể bị kéo méo.',
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

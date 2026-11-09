import 'package:flutter/material.dart';

class TheHoSo extends StatelessWidget {
  const TheHoSo({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1769D2);

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF121212)
          : const Color(0xFFF3F5F8),
      appBar: AppBar(title: const Text('Thẻ hồ sơ cá nhân'), centerTitle: true),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              clipBehavior: Clip.antiAlias,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 218,
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        SizedBox(
                          height: 164,
                          width: double.infinity,
                          child: Image.network(
                            'https://images.unsplash.com/photo-1470770841072-f978cf4d019e?w=1000',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: const Color(0xFFB8D6E8),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.landscape,
                                  size: 48,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          child: CircleAvatar(
                            radius: 58,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 52,
                              backgroundColor: Colors.blueGrey.shade100,
                              child: ClipOval(
                                child: Image.network(
                                  'https://png.pngtree.com/png-clipart/20250128/original/pngtree-monkey-picture-png-image_20308762.png',
                                  width: 104,
                                  height: 104,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const SizedBox(
                                      width: 104,
                                      height: 104,
                                      child: Icon(
                                        Icons.person,
                                        size: 56,
                                        color: Colors.white,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Trần Quang Hào',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sinh viên',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(height: 1, indent: 20, endIndent: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 12,
                    ),
                    child: Row(
                      children: [
                        _ProfileStat(value: '24', label: 'Bài viết'),
                        _ProfileStat(value: '1.2K', label: 'Người theo dõi'),
                        _ProfileStat(value: '320', label: 'Đang theo dõi'),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: FilledButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Bạn đang theo dõi hồ sơ này'),
                                ),
                              );
                            },

                            label: const Text('Theo dõi'),
                            style: FilledButton.styleFrom(
                              backgroundColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Mở cuộc trò chuyện'),
                                ),
                              );
                            },

                            label: const Text('Nhắn tin'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
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

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

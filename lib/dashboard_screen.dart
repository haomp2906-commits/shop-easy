import 'package:flutter/material.dart';

import 'cart_screen.dart'; // dùng hàm formatVnd
import 'product_card.dart'; // dùng sampleProducts

// ===================== DỮ LIỆU MẪU =====================

class _Stat {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const _Stat(this.icon, this.color, this.value, this.label);
}

enum OrderStatus { pending, shipping, done, cancelled }

class _Order {
  final String code;
  final String customer;
  final String time;
  final int total;
  final OrderStatus status;

  const _Order(this.code, this.customer, this.time, this.total, this.status);
}

const List<_Order> _orders = [
  _Order(
    'DH1024',
    'Nguyễn Văn An',
    '10 phút trước',
    21990000,
    OrderStatus.pending,
  ),
  _Order(
    'DH1023',
    'Trần Thị Bình',
    '1 giờ trước',
    4990000,
    OrderStatus.shipping,
  ),
  _Order('DH1022', 'Lê Hoàng Cường', 'Hôm qua', 26990000, OrderStatus.done),
  _Order('DH1021', 'Phạm Minh Dũng', 'Hôm qua', 490000, OrderStatus.cancelled),
  _Order('DH1020', 'Võ Thị Em', '2 ngày trước', 9490000, OrderStatus.done),
  _Order(
    'DH1019',
    'Đặng Quốc Phong',
    '2 ngày trước',
    5490000,
    OrderStatus.shipping,
  ),
];

// Mỗi trạng thái một nhãn và một màu khác nhau
String _statusLabel(OrderStatus s) {
  if (s == OrderStatus.pending) return 'Chờ xử lý';
  if (s == OrderStatus.shipping) return 'Đang giao';
  if (s == OrderStatus.done) return 'Hoàn thành';
  return 'Đã hủy';
}

Color _statusColor(OrderStatus s) {
  if (s == OrderStatus.pending) return Colors.orange.shade800;
  if (s == OrderStatus.shipping) return Colors.blue.shade700;
  if (s == OrderStatus.done) return Colors.green.shade700;
  return Colors.red.shade700;
}

// ===================== MÀN HÌNH TỔNG QUAN (GD 11) =====================

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const double _statCardHeight = 124; // chiều cao cố định mỗi ô số liệu

  void _showMessage(BuildContext context, String text) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(content: Text(text), duration: const Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final stats = <_Stat>[
      _Stat(
        Icons.receipt_long_outlined,
        Colors.blue.shade700,
        '128',
        'Đơn hàng',
      ),
      _Stat(
        Icons.payments_outlined,
        Colors.green.shade700,
        '45,2 triệu',
        'Doanh thu',
      ),
      _Stat(
        Icons.people_outline,
        Colors.orange.shade800,
        '1.240',
        'Khách hàng',
      ),
      // Số sản phẩm lấy thật từ danh sách sản phẩm của cửa hàng
      _Stat(
        Icons.inventory_2_outlined,
        Colors.purple.shade600,
        '${sampleProducts.length}',
        'Sản phẩm',
      ),
    ];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        title: const Text(
          'Tổng quan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          // (5) Toàn màn hình cuộn được bằng một CustomScrollView
          child: CustomScrollView(
            slivers: [
              // (1) + (2) Lưới 4 ô số liệu: 2 cột, màn hình rộng thì 4 cột
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: _buildStatGrid(context, stats),
                ),
              ),

              // (3) Tiêu đề mục + nút "Xem tất cả" căn phải
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                sliver: SliverToBoxAdapter(child: _buildSectionHeader(context)),
              ),

              // (4) Danh sách đơn hàng gần đây, mỗi dòng có nhãn trạng thái
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        _buildOrderTile(context, _orders[index]),
                    childCount: _orders.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatGrid(BuildContext context, List<_Stat> stats) {
    // MỘT chỗ duy nhất quyết định số cột: rộng hơn 600dp -> 4 cột, còn lại 2 cột.
    // Kéo giãn cửa sổ là lưới tự đổi, không phải sửa code ở chỗ nào khác.
    final columns = MediaQuery.of(context).size.width > 600 ? 4 : 2;
    const spacing = 12.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Tính tỉ lệ từ chiều rộng thật của mỗi ô để ô luôn cao
        // _statCardHeight, nội dung không bị tràn dù 2 hay 4 cột.
        final cellWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: cellWidth / _statCardHeight,
          children: stats.map((s) => _buildStatCard(context, s)).toList(),
        );
      },
    );
  }

  // (1) Ô số liệu: icon tròn, con số lớn, nhãn
  Widget _buildStatCard(BuildContext context, _Stat s) {
    final grey = Theme.of(context).colorScheme.onSurfaceVariant;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: s.color.withAlpha(35),
              child: Icon(s.icon, color: s.color, size: 20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // FittedBox: số dài thì tự thu nhỏ, không tràn ô
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    s.value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(s.label, style: TextStyle(color: grey, fontSize: 13)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Đơn hàng gần đây',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        TextButton(
          onPressed: () => _showMessage(context, 'Xem tất cả đơn hàng (demo)'),
          child: const Text('Xem tất cả'),
        ),
      ],
    );
  }

  Widget _buildOrderTile(BuildContext context, _Order o) {
    final grey = Theme.of(context).colorScheme.onSurfaceVariant;
    final color = _statusColor(o.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Đơn #${o.code}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${o.customer} · ${o.time}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatVnd(o.total),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                // Nhãn trạng thái, mỗi trạng thái một màu
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: color.withAlpha(35),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _statusLabel(o.status),
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

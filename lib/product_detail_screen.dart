import 'package:flutter/material.dart';

import 'product_card.dart'; // chứa class Product

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final bool isFavorite;
  final ValueChanged<bool>? onFavoriteChanged; // báo về danh sách khi bấm tim
  final VoidCallback? onAddToCart; // báo về danh sách khi thêm vào giỏ

  const ProductDetailScreen({
    super.key,
    required this.product,
    this.isFavorite = false,
    this.onFavoriteChanged,
    this.onAddToCart,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  static const double _expandedHeight = 320;
  static const int _imageCount = 3;

  final _pageController = PageController();
  final _scrollController = ScrollController();

  int _page = 0; // ảnh đang xem
  bool _collapsed = false; // ảnh đã thu lại thành thanh tiêu đề chưa
  bool _isFavorite = false;
  bool _descExpanded = false; // mô tả đang mở rộng hay thu gọn

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Khi cuộn gần hết phần ảnh thì hiện tên sản phẩm trên thanh tiêu đề
  void _onScroll() {
    final collapsed =
        _scrollController.hasClients &&
        _scrollController.offset > _expandedHeight - kToolbarHeight - 24;
    if (collapsed != _collapsed) setState(() => _collapsed = collapsed);
  }

  void _showMessage(String text) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(content: Text(text), duration: const Duration(seconds: 1)),
    );
  }

  void _toggleFavorite() {
    setState(() => _isFavorite = !_isFavorite);
    widget.onFavoriteChanged?.call(_isFavorite);
    _showMessage(
      _isFavorite ? 'Đã thêm vào yêu thích' : 'Đã bỏ khỏi yêu thích',
    );
  }

  void _addToCart() {
    widget.onAddToCart?.call();
    _showMessage('Đã thêm vào giỏ hàng');
  }

  void _buyNow() {
    _showMessage('Chuyển tới trang thanh toán (demo)');
  }

  // 21990000 -> "21.990.000 đ"
  String _formatPrice(int value) {
    final s = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buffer.write('.');
      buffer.write(s[i]);
    }
    return '$buffer đ';
  }

  // 1200 -> "1.2k"
  String _formatCount(int n) =>
      n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : '$n';

  // Mô tả mẫu (dài) để thử nút "Xem thêm"
  String get _description {
    final p = widget.product;
    return '${p.name} là sản phẩm thuộc nhóm ${p.category.toLowerCase()}, '
        'được nhiều khách hàng lựa chọn nhờ thiết kế gọn gàng, hiệu năng ổn '
        'định và độ bền cao trong quá trình sử dụng hằng ngày.\n\n'
        'Sản phẩm được bảo hành chính hãng 12 tháng, hỗ trợ đổi trả trong '
        '7 ngày nếu phát sinh lỗi từ nhà sản xuất. Hộp sản phẩm bao gồm '
        'thân máy, phụ kiện đi kèm theo tiêu chuẩn, sách hướng dẫn sử dụng '
        'và phiếu bảo hành.\n\n'
        'Khách hàng có thể thanh toán khi nhận hàng hoặc chuyển khoản trước. '
        'Đơn hàng được giao toàn quốc trong 2 đến 5 ngày làm việc, miễn phí '
        'vận chuyển cho đơn từ 500.000 đ. Nếu cần tư vấn thêm về cấu hình, '
        'màu sắc hoặc chương trình khuyến mãi, bạn có thể liên hệ bộ phận '
        'chăm sóc khách hàng.';
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // (3) Ảnh co lại thành thanh tiêu đề khi cuộn xuống
          SliverAppBar(
            pinned: true,
            expandedHeight: _expandedHeight,
            backgroundColor: const Color(0xFF1A237E),
            foregroundColor: Colors.white,
            automaticallyImplyLeading: false,
            // (2) Nút quay lại: tròn, trắng mờ, nổi trên ảnh
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: _CircleButton(
                icon: Icons.arrow_back,
                onTap: () => Navigator.pop(context),
              ),
            ),
            // Tên sản phẩm chỉ hiện khi ảnh đã thu lại
            title: AnimatedOpacity(
              opacity: _collapsed ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: Text(
                p.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            // (2) Nút yêu thích: tròn, trắng mờ, nổi trên ảnh
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _CircleButton(
                  icon: _isFavorite ? Icons.favorite : Icons.favorite_border,
                  iconColor: _isFavorite ? Colors.red : Colors.black87,
                  onTap: _toggleFavorite,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              // (1) Ảnh vuốt ngang + dấu chấm: Stack chồng dấu chấm lên PageView
              background: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: _imageCount,
                    onPageChanged: (i) => setState(() => _page = i),
                    itemBuilder: (context, i) => _buildImagePage(i),
                  ),
                  Positioned(
                    bottom: 14,
                    left: 0,
                    right: 0,
                    child: _buildDots(),
                  ),
                ],
              ),
            ),
          ),

          // Nội dung chi tiết (cao ít nhất bằng màn hình để luôn cuộn được)
          SliverToBoxAdapter(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: _buildInfo(context),
            ),
          ),
        ],
      ),

      // (5) Thanh hành động cố định ở đáy, không cuộn theo nội dung
      bottomNavigationBar: _buildActionBar(context),
    );
  }

  Widget _buildImagePage(int i) {
    final p = widget.product;
    if (i == 0 && p.imageUrl.isNotEmpty) {
      return Image.network(
        p.imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
    const colors = [Color(0xFFCFD8DC), Color(0xFFBBDEFB), Color(0xFFB2DFDB)];
    return Container(
      color: colors[i % colors.length],
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.image_outlined, size: 64, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              'Ảnh ${i + 1}/$_imageCount',
              style: const TextStyle(
                color: Colors.black45,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Hàng dấu chấm chỉ vị trí ảnh đang xem
  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_imageCount, (i) {
        final active = i == _page;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 18 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? Colors.blue.shade700 : Colors.white70,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildInfo(BuildContext context) {
    final p = widget.product;
    final grey = Theme.of(context).colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            p.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),

          // Đánh giá: 5 sao + điểm + số lượt
          Row(
            children: [
              ...List.generate(
                5,
                (_) => const Icon(Icons.star, size: 18, color: Colors.amber),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  '${p.rating}  ·  ${_formatCount(p.reviewCount)} đánh giá',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: grey, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Giá hiện tại, giá gốc gạch ngang, nhãn giảm giá
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            runSpacing: 6,
            children: [
              Text(
                _formatPrice(p.price),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange.shade700,
                ),
              ),
              Text(
                _formatPrice(p.originalPrice),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.red.shade700,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '-${p.discountPercent}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),

          // (4) Mô tả dài + nút Xem thêm / Thu gọn
          const Text(
            'Mô tả',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            alignment: Alignment.topCenter,
            child: Text(
              _description,
              maxLines: _descExpanded ? null : 4,
              overflow: _descExpanded
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
              style: TextStyle(height: 1.5, color: grey),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => setState(() => _descExpanded = !_descExpanded),
              child: Text(_descExpanded ? 'Thu gọn' : 'Xem thêm'),
            ),
          ),
          const Divider(),
          const SizedBox(height: 8),

          const Text(
            'Thông tin sản phẩm',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          _infoRow('Danh mục', p.category),
          _infoRow('Bảo hành', '12 tháng chính hãng'),
          _infoRow('Đổi trả', 'Trong 7 ngày nếu lỗi nhà sản xuất'),
          _infoRow('Giao hàng', '2 - 5 ngày làm việc'),
          _infoRow('Thanh toán', 'Khi nhận hàng hoặc chuyển khoản'),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  // (5) Thanh hành động ở đáy: Thêm vào giỏ + Mua ngay
  Widget _buildActionBar(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;

    return Container(
      decoration: BoxDecoration(
        color: surface,
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      // SafeArea: nút không bị thanh cử chỉ / thanh điều hướng của máy che
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _addToCart,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    foregroundColor: Colors.blue.shade700,
                    side: BorderSide(color: Colors.blue.shade700),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Thêm vào giỏ'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _buyNow,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.deepOrange.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Mua ngay'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Nút tròn nền trắng mờ nổi trên ảnh (dùng cho quay lại và yêu thích)
class _CircleButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _CircleButton({
    required this.icon,
    required this.onTap,
    this.iconColor = Colors.black87,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withAlpha(200), // trắng mờ
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 20, color: iconColor),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'product_card.dart'; // chứa class Product

// ===================== TRẠNG THÁI GIỎ HÀNG (dùng chung cả app) =====================

const int freeShippingThreshold =
    500000; // từ mức này trở lên: miễn phí vận chuyển
const int shippingFeeBase = 30000; // phí vận chuyển khi chưa đủ mức miễn phí

// 21990000 -> "21.990.000 đ"
String formatVnd(int value) {
  final s = value.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buffer.write('.');
    buffer.write(s[i]);
  }
  return '$buffer đ';
}

class CartItem {
  final Product product;
  int quantity;

  CartItem(this.product, this.quantity);

  int get lineTotal => product.price * quantity;
}

class CartState extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  // Tổng số lượng (hiển thị ở huy hiệu giỏ hàng)
  int get totalQuantity => _items.fold(0, (sum, i) => sum + i.quantity);

  // Bảng tính tiền: tự cập nhật mỗi khi giỏ thay đổi
  int get subtotal => _items.fold(0, (sum, i) => sum + i.lineTotal);
  int get shippingFee => (_items.isEmpty || subtotal >= freeShippingThreshold)
      ? 0
      : shippingFeeBase;
  int get total => subtotal + shippingFee;

  void add(Product p) {
    final index = _items.indexWhere((i) => i.product.id == p.id);
    if (index == -1) {
      _items.add(CartItem(p, 1));
    } else {
      _items[index].quantity++;
    }
    notifyListeners();
  }

  void changeQuantity(CartItem item, int delta) {
    item.quantity += delta;
    notifyListeners();
  }

  // Trả về vị trí vừa xóa để có thể hoàn tác
  int removeItem(CartItem item) {
    final index = _items.indexOf(item);
    if (index != -1) _items.removeAt(index);
    notifyListeners();
    return index;
  }

  // Hoàn tác: đặt sản phẩm về đúng vị trí cũ
  void insertAt(int index, CartItem item) {
    final i = index < 0 ? 0 : (index > _items.length ? _items.length : index);
    _items.insert(i, item);
    notifyListeners();
  }
}

// Giỏ hàng dùng chung: bất kỳ màn hình nào cũng gọi cart.add(...) được
final CartState cart = CartState();

// ===================== MÀN HÌNH GIỎ HÀNG (GD 8) =====================

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  // (2) + (3): xóa khỏi giỏ và cho phép hoàn tác bằng SnackBar
  void _removeWithUndo(BuildContext context, CartItem item) {
    final index = cart.removeItem(item);
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          'Đã xóa "${item.product.name}"',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        action: SnackBarAction(
          label: 'Hoàn tác',
          onPressed: () => cart.insertAt(index, item),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Giỏ thay đổi là cả màn hình tự vẽ lại (số lượng, tiền, phí vận chuyển)
    return AnimatedBuilder(
      animation: cart,
      builder: (context, _) {
        final items = cart.items;

        return Scaffold(
          backgroundColor: isDark
              ? const Color(0xFF121212)
              : Colors.grey.shade100,
          appBar: AppBar(
            backgroundColor: const Color(0xFF1A237E),
            foregroundColor: Colors.white,
            title: Text(
              items.isEmpty ? 'Giỏ hàng' : 'Giỏ hàng (${cart.totalQuantity})',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          // (5) Giỏ rỗng thì hiện màn hình trống
          body: items.isEmpty
              ? _buildEmpty(context)
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: items.length,
                      itemBuilder: (context, index) =>
                          _buildItem(context, items[index]),
                    ),
                  ),
                ),
          bottomNavigationBar: items.isEmpty ? null : _buildSummary(context),
        );
      },
    );
  }

  // (5) Màn hình giỏ rỗng + nút "Tiếp tục mua sắm"
  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 96,
              color: Colors.grey.shade500,
            ),
            const SizedBox(height: 16),
            const Text(
              'Giỏ hàng của bạn đang trống',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Hãy chọn thêm sản phẩm bạn yêu thích nhé',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
              ),
              child: const Text('Tiếp tục mua sắm'),
            ),
          ],
        ),
      ),
    );
  }

  // (1) + (3): mỗi dòng giỏ hàng, vuốt sang trái để xóa
  Widget _buildItem(BuildContext context, CartItem item) {
    final p = item.product;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Dismissible(
          key: ValueKey(p.id),
          direction: DismissDirection.endToStart, // chỉ vuốt sang trái
          // Nền đỏ + icon thùng rác lộ ra khi vuốt
          background: Container(
            color: Colors.red.shade700,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            child: const Icon(
              Icons.delete_outline,
              color: Colors.white,
              size: 28,
            ),
          ),
          onDismissed: (_) => _removeWithUndo(context, item),
          child: Container(
            color: Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                // Ảnh nhỏ
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 72,
                    height: 72,
                    child: p.imageUrl.isEmpty
                        ? Container(
                            color: Colors.blueGrey.shade100,
                            child: const Center(
                              child: Icon(
                                Icons.image_outlined,
                                color: Colors.white70,
                              ),
                            ),
                          )
                        : Image.network(p.imageUrl, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tên sản phẩm tối đa 2 dòng
                      Text(
                        p.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Đơn giá + bộ chọn số lượng
                      Row(
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  formatVnd(p.price),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepOrange.shade700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          _buildQuantity(context, item),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // (1) + (2): bộ chọn số lượng - + ; giảm về 0 thì xóa khỏi giỏ
  Widget _buildQuantity(BuildContext context, CartItem item) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 18),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: () {
              if (item.quantity <= 1) {
                _removeWithUndo(context, item); // về 0 -> xóa
              } else {
                cart.changeQuantity(item, -1);
              }
            },
          ),
          SizedBox(
            width: 26,
            child: Text(
              '${item.quantity}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 18),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: () => cart.changeQuantity(item, 1),
          ),
        ],
      ),
    );
  }

  // (4) Bảng tính tiền + nút Thanh toán, cố định ở đáy
  Widget _buildSummary(BuildContext context) {
    final remain = freeShippingThreshold - cart.subtotal;
    final free = cart.shippingFee == 0;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Center(
          heightFactor: 1, // chỉ cao vừa nội dung, không giãn hết màn hình
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _summaryRow(context, 'Tạm tính', formatVnd(cart.subtotal)),
                  const SizedBox(height: 6),
                  _summaryRow(
                    context,
                    'Phí vận chuyển',
                    free ? 'Miễn phí' : formatVnd(cart.shippingFee),
                    valueColor: free ? Colors.green.shade600 : null,
                  ),
                  // Gợi ý còn thiếu bao nhiêu để được miễn phí vận chuyển
                  if (remain > 0)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Mua thêm ${formatVnd(remain)} để được miễn phí vận chuyển',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.deepOrange.shade700,
                          ),
                        ),
                      ),
                    ),
                  const Divider(height: 20),
                  _summaryRow(
                    context,
                    'Tổng cộng',
                    formatVnd(cart.total),
                    bold: true,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        final messenger = ScaffoldMessenger.of(context);
                        messenger.hideCurrentSnackBar();
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Chuyển tới trang thanh toán (demo)'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.blue.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Thanh toán'),
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

  Widget _summaryRow(
    BuildContext context,
    String label,
    String value, {
    bool bold = false,
    Color? valueColor,
  }) {
    final grey = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: bold ? 17 : 14,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            color: bold ? null : grey,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: bold ? 17 : 14,
            fontWeight: bold ? FontWeight.bold : FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

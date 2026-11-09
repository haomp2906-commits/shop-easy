import 'package:flutter/material.dart';

// ===================== MÔ HÌNH DỮ LIỆU =====================

class Product {
  final int id;
  final String name;
  final String category;
  final String imageUrl; // để trống thì thẻ hiện khối màu thay cho ảnh
  final int price;
  final int originalPrice;
  final double rating;
  final int reviewCount;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    this.imageUrl = '',
    required this.price,
    required this.originalPrice,
    required this.rating,
    required this.reviewCount,
  });

  // Tự tính % giảm giá từ giá gốc và giá hiện tại
  int get discountPercent => ((1 - price / originalPrice) * 100).round();
}

const List<String> categories = [
  'Tất cả',
  'Điện thoại',
  'Laptop',
  'Tablet',
  'Phụ kiện',
];

const List<Product> sampleProducts = [
  Product(
    id: 1,
    name: 'iPhone 15 128GB Chính hãng VN/A',
    category: 'Điện thoại',
    price: 19990000,
    originalPrice: 22990000,
    rating: 4.9,
    reviewCount: 3200,
  ),
  Product(
    id: 2,
    name: 'Samsung Galaxy S24 Ultra 256GB',
    category: 'Điện thoại',
    price: 26990000,
    originalPrice: 33990000,
    rating: 4.8,
    reviewCount: 2100,
  ),
  Product(
    id: 3,
    name: 'Xiaomi Redmi Note 13',
    category: 'Điện thoại',
    price: 4990000,
    originalPrice: 5990000,
    rating: 4.6,
    reviewCount: 5400,
  ),
  Product(
    id: 4,
    name: 'Laptop Dell Inspiron 15 3520 Core i5 Ram 16GB SSD 512GB Full HD',
    category: 'Laptop',
    price: 21990000,
    originalPrice: 28990000,
    rating: 4.8,
    reviewCount: 1200,
  ),
  Product(
    id: 5,
    name: 'MacBook Air M2 13 inch 8GB 256GB',
    category: 'Laptop',
    price: 24990000,
    originalPrice: 28990000,
    rating: 4.9,
    reviewCount: 980,
  ),
  Product(
    id: 6,
    name: 'Laptop Asus Vivobook 14',
    category: 'Laptop',
    price: 14990000,
    originalPrice: 17990000,
    rating: 4.5,
    reviewCount: 760,
  ),
  Product(
    id: 7,
    name: 'iPad Gen 10 64GB WiFi',
    category: 'Tablet',
    price: 9490000,
    originalPrice: 11990000,
    rating: 4.7,
    reviewCount: 1500,
  ),
  Product(
    id: 8,
    name: 'Samsung Galaxy Tab S9 FE',
    category: 'Tablet',
    price: 8990000,
    originalPrice: 10990000,
    rating: 4.6,
    reviewCount: 430,
  ),
  Product(
    id: 9,
    name: 'Tai nghe Bluetooth AirPods Pro 2',
    category: 'Phụ kiện',
    price: 5490000,
    originalPrice: 6790000,
    rating: 4.8,
    reviewCount: 2700,
  ),
  Product(
    id: 10,
    name: 'Sạc dự phòng 20000mAh',
    category: 'Phụ kiện',
    price: 490000,
    originalPrice: 690000,
    rating: 4.4,
    reviewCount: 8900,
  ),
  Product(
    id: 11,
    name: 'Chuột không dây Logitech M331 Silent',
    category: 'Phụ kiện',
    price: 290000,
    originalPrice: 390000,
    rating: 4.7,
    reviewCount: 3100,
  ),
  Product(
    id: 12,
    name: 'Bàn phím cơ',
    category: 'Phụ kiện',
    price: 790000,
    originalPrice: 990000,
    rating: 4.5,
    reviewCount: 650,
  ),
];

// ===================== THẺ SẢN PHẨM =====================

/// Thẻ sản phẩm (GD 5), đã chỉnh để dùng trong GridView (GD 6):
/// - Không còn chiều rộng cố định: thẻ tự lấp đầy ô lưới của cha.
/// - Ảnh dùng Expanded: ảnh co giãn theo chiều cao ô, phần thông tin bên
///   dưới có chiều cao cố định => không bao giờ bị tràn khi xoay ngang.
/// - Trạng thái tim do màn hình cha giữ (isFavorite) nên không bị lệch
///   khi lọc/cuộn danh sách.
class ProductCard extends StatelessWidget {
  final String name;
  final String imageUrl;
  final int discountPercent;
  final double rating;
  final int reviewCount;
  final int price;
  final int originalPrice;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onAddToCart;

  const ProductCard({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.discountPercent,
    required this.rating,
    required this.reviewCount,
    required this.price,
    required this.originalPrice,
    this.isFavorite = false,
    this.onFavoriteTap,
    this.onAddToCart,
  });

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

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias, // (1) bo góc theo thẻ
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // (1) + (2): Ảnh chiếm phần trên + nhãn giảm giá + nút tim
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: imageUrl.isEmpty
                      ? Container(
                          color: Colors.blueGrey.shade100,
                          child: const Center(
                            child: Icon(
                              Icons.image_outlined,
                              size: 36,
                              color: Colors.white70,
                            ),
                          ),
                        )
                      : Image.network(imageUrl, fit: BoxFit.cover),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade700,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '-$discountPercent%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onFavoriteTap,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: isFavorite ? Colors.red : Colors.black54,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Phần thông tin: chiều cao cố định
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // (3) Tối đa 2 dòng, cắt bằng ba chấm; cao cố định 40
                SizedBox(
                  height: 40,
                  child: Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                // (4) 5 sao + điểm số + số lượt đánh giá
                Row(
                  children: [
                    ...List.generate(
                      5,
                      (_) =>
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '$rating (${_formatCount(reviewCount)})',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // (5) Giá hiện tại cam đậm, giá gốc xám gạch ngang
                // FittedBox: ô hẹp thì cả hàng giá tự thu nhỏ, không tràn
                SizedBox(
                  width: double.infinity,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatPrice(price),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange.shade700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatPrice(originalPrice),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onAddToCart,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Thêm vào giỏ'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

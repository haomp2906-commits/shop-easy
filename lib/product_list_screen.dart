/*import 'package:flutter/material.dart';

import 'product_card.dart';
import 'settings_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();

  String _query = ''; // từ khóa đang gõ ở ô tìm kiếm
  String _category = 'Tất cả'; // chip danh mục đang chọn
  int _navIndex = 0; // mục đang chọn ở thanh điều hướng dưới
  int _cartCount = 0; // số sản phẩm trong giỏ
  final Set<int> _favorites = {}; // id các sản phẩm đã tim

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  // Lọc ĐỒNG THỜI theo danh mục và từ khóa
  List<Product> get _filtered {
    final q = _query.trim().toLowerCase();
    return sampleProducts.where((p) {
      final matchCategory = _category == 'Tất cả' || p.category == _category;
      final matchName = q.isEmpty || p.name.toLowerCase().contains(q);
      return matchCategory && matchName;
    }).toList();
  }

  void _showMessage(String text) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(content: Text(text), duration: const Duration(seconds: 1)),
    );
  }

  void _toggleFavorite(Product p) {
    setState(() {
      // remove trả về true nếu id đã có (bỏ tim), false nếu chưa có (thêm tim)
      if (!_favorites.remove(p.id)) _favorites.add(p.id);
    });
    _showMessage(
      _favorites.contains(p.id)
          ? 'Đã thêm vào yêu thích'
          : 'Đã bỏ khỏi yêu thích',
    );
  }

  void _addToCart() {
    setState(() => _cartCount++);
    _showMessage('Đã thêm vào giỏ hàng');
  }

  // Bấm icon kính lúp trên AppBar: về trang chủ và đưa con trỏ vào ô tìm kiếm
  void _focusSearch() {
    setState(() => _navIndex = 0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocus.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey.shade100,
      // Bàn phím không ép co giao diện -> xoay ngang gõ chữ không bị tràn
      resizeToAvoidBottomInset: false,

      // (1) Thanh tiêu đề: nút tìm kiếm + giỏ hàng có huy hiệu số lượng
      // Tab Cài đặt (số 2) có thanh tiêu đề riêng nên ẩn thanh này đi
      appBar: _navIndex == 2
          ? null
          : AppBar(
              backgroundColor: const Color(0xFF1A237E),
              foregroundColor: Colors.white,
              title: const Text(
                'ShopEasy',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _focusSearch,
                ),
                IconButton(
                  icon: Badge(
                    label: Text('$_cartCount'),
                    isLabelVisible: _cartCount > 0,
                    child: const Icon(Icons.shopping_cart_outlined),
                  ),
                  onPressed: () =>
                      _showMessage('Giỏ hàng có $_cartCount sản phẩm'),
                ),
                const SizedBox(width: 4),
              ],
            ),

      body: _buildBody(),

      // (5) Thanh điều hướng dưới với 3 mục
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: (i) => setState(() => _navIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Yêu thích',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Cài đặt',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_navIndex) {
      case 0:
        return _buildHome();
      case 1:
        final favs = sampleProducts
            .where((p) => _favorites.contains(p.id))
            .toList();
        return _buildGrid(favs, 'Bạn chưa có sản phẩm yêu thích nào');
      default:
        // Tab Cài đặt: dùng luôn màn hình SettingsScreen
        // (trong đó đã có Profile, chế độ tối, Đăng xuất)
        return const SettingsScreen();
    }
  }

  Widget _buildHome() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fieldColor = isDark ? Colors.grey.shade800 : Colors.white;

    return Column(
      children: [
        // (2) Ô tìm kiếm bo tròn, gõ tới đâu lọc tới đó
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocus,
            onChanged: (value) => setState(() => _query = value),
            decoration: InputDecoration(
              hintText: 'Tìm sản phẩm...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    ),
              filled: true,
              fillColor: fieldColor,
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        // (3) Hàng chip danh mục cuộn ngang, chip đang chọn đổi màu nền
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: categories.map((c) {
              final selected = _category == c;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(c),
                  selected: selected,
                  showCheckmark: false,
                  backgroundColor: fieldColor,
                  selectedColor: Colors.blue.shade700,
                  labelStyle: TextStyle(
                    color: selected
                        ? Colors.white
                        : (isDark ? Colors.white70 : Colors.black87),
                  ),
                  onSelected: (_) => setState(() => _category = c),
                ),
              );
            }).toList(),
          ),
        ),

        // (4) Lưới sản phẩm
        Expanded(
          child: _buildGrid(_filtered, 'Không tìm thấy sản phẩm phù hợp'),
        ),
      ],
    );
  }

  Widget _buildGrid(List<Product> items, String emptyText) {
    if (items.isEmpty) {
      return Center(
        child: Text(emptyText, style: TextStyle(color: Colors.grey.shade600)),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Điện thoại dọc: 2 cột. Màn hình rộng (xoay ngang, máy tính bảng): 4 cột
        final columns = constraints.maxWidth >= 600 ? 4 : 2;

        return GridView.builder(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(12),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 310, // chiều cao cố định mỗi thẻ
          ),
          itemBuilder: (context, index) {
            final p = items[index];
            return ProductCard(
              key: ValueKey(p.id),
              name: p.name,
              imageUrl: p.imageUrl,
              discountPercent: p.discountPercent,
              rating: p.rating,
              reviewCount: p.reviewCount,
              price: p.price,
              originalPrice: p.originalPrice,
              isFavorite: _favorites.contains(p.id),
              onFavoriteTap: () => _toggleFavorite(p),
              onAddToCart: _addToCart,
            );
          },
        );
      },
    );
  }
}
*/

/*import 'package:flutter/material.dart';

import 'product_card.dart';
import 'product_detail_screen.dart';
import 'settings_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();

  String _query = ''; // từ khóa đang gõ ở ô tìm kiếm
  String _category = 'Tất cả'; // chip danh mục đang chọn
  int _navIndex = 0; // mục đang chọn ở thanh điều hướng dưới
  int _cartCount = 0; // số sản phẩm trong giỏ
  final Set<int> _favorites = {}; // id các sản phẩm đã tim

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  // Lọc ĐỒNG THỜI theo danh mục và từ khóa
  List<Product> get _filtered {
    final q = _query.trim().toLowerCase();
    return sampleProducts.where((p) {
      final matchCategory = _category == 'Tất cả' || p.category == _category;
      final matchName = q.isEmpty || p.name.toLowerCase().contains(q);
      return matchCategory && matchName;
    }).toList();
  }

  void _showMessage(String text) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(content: Text(text), duration: const Duration(seconds: 1)),
    );
  }

  void _toggleFavorite(Product p) {
    setState(() {
      // remove trả về true nếu id đã có (bỏ tim), false nếu chưa có (thêm tim)
      if (!_favorites.remove(p.id)) _favorites.add(p.id);
    });
    _showMessage(
      _favorites.contains(p.id)
          ? 'Đã thêm vào yêu thích'
          : 'Đã bỏ khỏi yêu thích',
    );
  }

  void _addToCart() {
    setState(() => _cartCount++);
    _showMessage('Đã thêm vào giỏ hàng');
  }

  // Bấm vào thẻ sản phẩm -> mở màn hình chi tiết (GD 7)
  void _openDetail(Product p) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(
          product: p,
          isFavorite: _favorites.contains(p.id),
          onFavoriteChanged: (fav) {
            setState(() {
              if (fav) {
                _favorites.add(p.id);
              } else {
                _favorites.remove(p.id);
              }
            });
          },
          onAddToCart: () => setState(() => _cartCount++),
        ),
      ),
    );
  }

  // Bấm icon kính lúp trên AppBar: về trang chủ và đưa con trỏ vào ô tìm kiếm
  void _focusSearch() {
    setState(() => _navIndex = 0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocus.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey.shade100,
      // Bàn phím không ép co giao diện -> xoay ngang gõ chữ không bị tràn
      resizeToAvoidBottomInset: false,

      // (1) Thanh tiêu đề: nút tìm kiếm + giỏ hàng có huy hiệu số lượng
      // Tab Cài đặt (số 2) có thanh tiêu đề riêng nên ẩn thanh này đi
      appBar: _navIndex == 2
          ? null
          : AppBar(
              backgroundColor: const Color(0xFF1A237E),
              foregroundColor: Colors.white,
              title: const Text(
                'ShopEasy',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _focusSearch,
                ),
                IconButton(
                  icon: Badge(
                    label: Text('$_cartCount'),
                    isLabelVisible: _cartCount > 0,
                    child: const Icon(Icons.shopping_cart_outlined),
                  ),
                  onPressed: () =>
                      _showMessage('Giỏ hàng có $_cartCount sản phẩm'),
                ),
                const SizedBox(width: 4),
              ],
            ),

      body: _buildBody(),

      // (5) Thanh điều hướng dưới với 3 mục
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: (i) => setState(() => _navIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Yêu thích',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Cài đặt',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_navIndex) {
      case 0:
        return _buildHome();
      case 1:
        final favs = sampleProducts
            .where((p) => _favorites.contains(p.id))
            .toList();
        return _buildGrid(favs, 'Bạn chưa có sản phẩm yêu thích nào');
      default:
        // Tab Cài đặt: dùng luôn màn hình SettingsScreen
        // (trong đó đã có Profile, chế độ tối, Đăng xuất)
        return const SettingsScreen();
    }
  }

  Widget _buildHome() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fieldColor = isDark ? Colors.grey.shade800 : Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // (2) Ô tìm kiếm bo tròn, gõ tới đâu lọc tới đó
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocus,
            onChanged: (value) => setState(() => _query = value),
            decoration: InputDecoration(
              hintText: 'Tìm sản phẩm...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    ),
              filled: true,
              fillColor: fieldColor,
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        // (3) Hàng chip danh mục cuộn ngang, chip đang chọn đổi màu nền
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: categories.map((c) {
              final selected = _category == c;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(c),
                  selected: selected,
                  showCheckmark: false,
                  backgroundColor: fieldColor,
                  selectedColor: Colors.blue.shade700,
                  labelStyle: TextStyle(
                    color: selected
                        ? Colors.white
                        : (isDark ? Colors.white70 : Colors.black87),
                  ),
                  onSelected: (_) => setState(() => _category = c),
                ),
              );
            }).toList(),
          ),
        ),

        // (4) Lưới sản phẩm
        Expanded(
          child: _buildGrid(_filtered, 'Không tìm thấy sản phẩm phù hợp'),
        ),
      ],
    );
  }

  Widget _buildGrid(List<Product> items, String emptyText) {
    if (items.isEmpty) {
      return Center(
        child: Text(emptyText, style: TextStyle(color: Colors.grey.shade600)),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Điện thoại dọc: 2 cột. Màn hình rộng (xoay ngang, máy tính bảng): 4 cột
        final columns = 2;

        return GridView.builder(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(12),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 310, // chiều cao cố định mỗi thẻ
          ),
          itemBuilder: (context, index) {
            final p = items[index];
            // Bấm vào thẻ -> mở chi tiết. Nút tim và nút "Thêm vào giỏ"
            // bên trong thẻ vẫn bấm riêng được như cũ.
            return GestureDetector(
              onTap: () => _openDetail(p),
              child: ProductCard(
                key: ValueKey(p.id),
                name: p.name,
                imageUrl: p.imageUrl,
                discountPercent: p.discountPercent,
                rating: p.rating,
                reviewCount: p.reviewCount,
                price: p.price,
                originalPrice: p.originalPrice,
                isFavorite: _favorites.contains(p.id),
                onFavoriteTap: () => _toggleFavorite(p),
                onAddToCart: _addToCart,
              ),
            );
          },
        );
      },
    );
  }
}*/
/*
import 'package:flutter/material.dart';

import 'cart_screen.dart';
import 'product_card.dart';
import 'product_detail_screen.dart';
import 'settings_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();

  String _query = ''; // từ khóa đang gõ ở ô tìm kiếm
  String _category = 'Tất cả'; // chip danh mục đang chọn
  int _navIndex = 0; // mục đang chọn ở thanh điều hướng dưới
  final Set<int> _favorites = {}; // id các sản phẩm đã tim

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  // Lọc ĐỒNG THỜI theo danh mục và từ khóa
  List<Product> get _filtered {
    final q = _query.trim().toLowerCase();
    return sampleProducts.where((p) {
      final matchCategory = _category == 'Tất cả' || p.category == _category;
      final matchName = q.isEmpty || p.name.toLowerCase().contains(q);
      return matchCategory && matchName;
    }).toList();
  }

  void _showMessage(String text) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(content: Text(text), duration: const Duration(seconds: 1)),
    );
  }

  void _toggleFavorite(Product p) {
    setState(() {
      // remove trả về true nếu id đã có (bỏ tim), false nếu chưa có (thêm tim)
      if (!_favorites.remove(p.id)) _favorites.add(p.id);
    });
    _showMessage(
      _favorites.contains(p.id)
          ? 'Đã thêm vào yêu thích'
          : 'Đã bỏ khỏi yêu thích',
    );
  }

  // Thêm sản phẩm vào giỏ dùng chung (cart_screen.dart)
  void _addToCart(Product p) {
    cart.add(p);
    _showMessage('Đã thêm vào giỏ hàng');
  }

  // Bấm icon giỏ hàng -> mở màn hình giỏ hàng (GD 8)
  void _openCart() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CartScreen()),
    );
  }

  // Bấm vào thẻ sản phẩm -> mở màn hình chi tiết (GD 7)
  void _openDetail(Product p) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(
          product: p,
          isFavorite: _favorites.contains(p.id),
          onFavoriteChanged: (fav) {
            setState(() {
              if (fav) {
                _favorites.add(p.id);
              } else {
                _favorites.remove(p.id);
              }
            });
          },
          onAddToCart: () => cart.add(p),
        ),
      ),
    );
  }

  // Bấm icon kính lúp trên AppBar: về trang chủ và đưa con trỏ vào ô tìm kiếm
  void _focusSearch() {
    setState(() => _navIndex = 0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocus.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey.shade100,
      // Bàn phím không ép co giao diện -> xoay ngang gõ chữ không bị tràn
      resizeToAvoidBottomInset: false,

      // (1) Thanh tiêu đề: nút tìm kiếm + giỏ hàng có huy hiệu số lượng
      // Tab Cài đặt (số 2) có thanh tiêu đề riêng nên ẩn thanh này đi
      appBar: _navIndex == 2
          ? null
          : AppBar(
              backgroundColor: const Color(0xFF1A237E),
              foregroundColor: Colors.white,
              title: const Text(
                'ShopEasy',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _focusSearch,
                ),
                IconButton(
                  // Huy hiệu số lượng tự cập nhật khi giỏ hàng thay đổi
                  icon: AnimatedBuilder(
                    animation: cart,
                    builder: (context, _) => Badge(
                      label: Text('${cart.totalQuantity}'),
                      isLabelVisible: cart.totalQuantity > 0,
                      child: const Icon(Icons.shopping_cart_outlined),
                    ),
                  ),
                  onPressed: _openCart,
                ),
                const SizedBox(width: 4),
              ],
            ),

      body: _buildBody(),

      // (5) Thanh điều hướng dưới với 3 mục
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: (i) => setState(() => _navIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Yêu thích',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Cài đặt',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_navIndex) {
      case 0:
        return _buildHome();
      case 1:
        final favs = sampleProducts
            .where((p) => _favorites.contains(p.id))
            .toList();
        return _buildGrid(favs, 'Bạn chưa có sản phẩm yêu thích nào');
      default:
        // Tab Cài đặt: dùng luôn màn hình SettingsScreen
        // (trong đó đã có Profile, chế độ tối, Đăng xuất)
        return const SettingsScreen();
    }
  }

  Widget _buildHome() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fieldColor = isDark ? Colors.grey.shade800 : Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // (2) Ô tìm kiếm bo tròn, gõ tới đâu lọc tới đó
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocus,
            onChanged: (value) => setState(() => _query = value),
            decoration: InputDecoration(
              hintText: 'Tìm sản phẩm...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    ),
              filled: true,
              fillColor: fieldColor,
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        // (3) Hàng chip danh mục cuộn ngang, chip đang chọn đổi màu nền
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: categories.map((c) {
              final selected = _category == c;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(c),
                  selected: selected,
                  showCheckmark: false,
                  backgroundColor: fieldColor,
                  selectedColor: Colors.blue.shade700,
                  labelStyle: TextStyle(
                    color: selected
                        ? Colors.white
                        : (isDark ? Colors.white70 : Colors.black87),
                  ),
                  onSelected: (_) => setState(() => _category = c),
                ),
              );
            }).toList(),
          ),
        ),

        // (4) Lưới sản phẩm
        Expanded(
          child: _buildGrid(_filtered, 'Không tìm thấy sản phẩm phù hợp'),
        ),
      ],
    );
  }

  Widget _buildGrid(List<Product> items, String emptyText) {
    if (items.isEmpty) {
      return Center(
        child: Text(emptyText, style: TextStyle(color: Colors.grey.shade600)),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Luôn 2 cột theo yêu cầu GD 6
        const columns = 2;

        return GridView.builder(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(12),
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 310, // chiều cao cố định mỗi thẻ
          ),
          itemBuilder: (context, index) {
            final p = items[index];
            // Bấm vào thẻ -> mở chi tiết. Nút tim và nút "Thêm vào giỏ"
            // bên trong thẻ vẫn bấm riêng được như cũ.
            return GestureDetector(
              onTap: () => _openDetail(p),
              child: ProductCard(
                key: ValueKey(p.id),
                name: p.name,
                imageUrl: p.imageUrl,
                discountPercent: p.discountPercent,
                rating: p.rating,
                reviewCount: p.reviewCount,
                price: p.price,
                originalPrice: p.originalPrice,
                isFavorite: _favorites.contains(p.id),
                onFavoriteTap: () => _toggleFavorite(p),
                onAddToCart: () => _addToCart(p),
              ),
            );
          },
        );
      },
    );
  }
}
*/
import 'package:flutter/material.dart';

import 'cart_screen.dart';
import 'dashboard_screen.dart';
import 'product_card.dart';
import 'product_detail_screen.dart';
import 'settings_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();

  String _query = ''; // từ khóa đang gõ ở ô tìm kiếm
  String _category = 'Tất cả'; // chip danh mục đang chọn
  int _navIndex = 0; // mục đang chọn ở thanh điều hướng dưới
  final Set<int> _favorites = {}; // id các sản phẩm đã tim

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  // Lọc ĐỒNG THỜI theo danh mục và từ khóa
  List<Product> get _filtered {
    final q = _query.trim().toLowerCase();
    return sampleProducts.where((p) {
      final matchCategory = _category == 'Tất cả' || p.category == _category;
      final matchName = q.isEmpty || p.name.toLowerCase().contains(q);
      return matchCategory && matchName;
    }).toList();
  }

  void _showMessage(String text) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(content: Text(text), duration: const Duration(seconds: 1)),
    );
  }

  void _toggleFavorite(Product p) {
    setState(() {
      // remove trả về true nếu id đã có (bỏ tim), false nếu chưa có (thêm tim)
      if (!_favorites.remove(p.id)) _favorites.add(p.id);
    });
    _showMessage(
      _favorites.contains(p.id)
          ? 'Đã thêm vào yêu thích'
          : 'Đã bỏ khỏi yêu thích',
    );
  }

  // Thêm sản phẩm vào giỏ dùng chung (cart_screen.dart)
  void _addToCart(Product p) {
    cart.add(p);
    _showMessage('Đã thêm vào giỏ hàng');
  }

  // Bấm icon giỏ hàng -> mở màn hình giỏ hàng (GD 8)
  void _openCart() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CartScreen()),
    );
  }

  // Bấm icon bảng điều khiển -> mở màn hình Tổng quan (GD 11)
  void _openDashboard() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  // Bấm vào thẻ sản phẩm -> mở màn hình chi tiết (GD 7)
  void _openDetail(Product p) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(
          product: p,
          isFavorite: _favorites.contains(p.id),
          onFavoriteChanged: (fav) {
            setState(() {
              if (fav) {
                _favorites.add(p.id);
              } else {
                _favorites.remove(p.id);
              }
            });
          },
          onAddToCart: () => cart.add(p),
        ),
      ),
    );
  }

  // Bấm icon kính lúp trên AppBar: về trang chủ và đưa con trỏ vào ô tìm kiếm
  void _focusSearch() {
    setState(() => _navIndex = 0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocus.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey.shade100,
      // Bàn phím không ép co giao diện -> xoay ngang gõ chữ không bị tràn
      resizeToAvoidBottomInset: false,

      // (1) Thanh tiêu đề: nút tìm kiếm + giỏ hàng có huy hiệu số lượng
      // Tab Cài đặt (số 2) có thanh tiêu đề riêng nên ẩn thanh này đi
      appBar: _navIndex == 2
          ? null
          : AppBar(
              backgroundColor: const Color(0xFF1A237E),
              foregroundColor: Colors.white,
              title: const Text(
                'ShopEasy',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.dashboard_outlined),
                  tooltip: 'Tổng quan',
                  onPressed: _openDashboard,
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _focusSearch,
                ),
                IconButton(
                  // Huy hiệu số lượng tự cập nhật khi giỏ hàng thay đổi
                  icon: AnimatedBuilder(
                    animation: cart,
                    builder: (context, _) => Badge(
                      label: Text('${cart.totalQuantity}'),
                      isLabelVisible: cart.totalQuantity > 0,
                      child: const Icon(Icons.shopping_cart_outlined),
                    ),
                  ),
                  onPressed: _openCart,
                ),
                const SizedBox(width: 4),
              ],
            ),

      body: _buildBody(),

      // (5) Thanh điều hướng dưới với 3 mục
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: (i) => setState(() => _navIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Yêu thích',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Cài đặt',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_navIndex) {
      case 0:
        return _buildHome();
      case 1:
        final favs = sampleProducts
            .where((p) => _favorites.contains(p.id))
            .toList();
        return _buildGrid(favs, 'Bạn chưa có sản phẩm yêu thích nào');
      default:
        // Tab Cài đặt: dùng luôn màn hình SettingsScreen
        // (trong đó đã có Profile, chế độ tối, Đăng xuất)
        return const SettingsScreen();
    }
  }

  Widget _buildHome() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fieldColor = isDark ? Colors.grey.shade800 : Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // (2) Ô tìm kiếm bo tròn, gõ tới đâu lọc tới đó
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocus,
            onChanged: (value) => setState(() => _query = value),
            decoration: InputDecoration(
              hintText: 'Tìm sản phẩm...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    ),
              filled: true,
              fillColor: fieldColor,
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        // (3) Hàng chip danh mục cuộn ngang, chip đang chọn đổi màu nền
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: categories.map((c) {
              final selected = _category == c;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(c),
                  selected: selected,
                  showCheckmark: false,
                  backgroundColor: fieldColor,
                  selectedColor: Colors.blue.shade700,
                  labelStyle: TextStyle(
                    color: selected
                        ? Colors.white
                        : (isDark ? Colors.white70 : Colors.black87),
                  ),
                  onSelected: (_) => setState(() => _category = c),
                ),
              );
            }).toList(),
          ),
        ),

        // (4) Lưới sản phẩm
        Expanded(
          child: _buildGrid(_filtered, 'Không tìm thấy sản phẩm phù hợp'),
        ),
      ],
    );
  }

  Widget _buildGrid(List<Product> items, String emptyText) {
    if (items.isEmpty) {
      return Center(
        child: Text(emptyText, style: TextStyle(color: Colors.grey.shade600)),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Luôn 2 cột theo yêu cầu GD 6
        const columns = 2;

        return GridView.builder(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(12),
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 310, // chiều cao cố định mỗi thẻ
          ),
          itemBuilder: (context, index) {
            final p = items[index];
            // Bấm vào thẻ -> mở chi tiết. Nút tim và nút "Thêm vào giỏ"
            // bên trong thẻ vẫn bấm riêng được như cũ.
            return GestureDetector(
              onTap: () => _openDetail(p),
              child: ProductCard(
                key: ValueKey(p.id),
                name: p.name,
                imageUrl: p.imageUrl,
                discountPercent: p.discountPercent,
                rating: p.rating,
                reviewCount: p.reviewCount,
                price: p.price,
                originalPrice: p.originalPrice,
                isFavorite: _favorites.contains(p.id),
                onFavoriteTap: () => _toggleFavorite(p),
                onAddToCart: () => _addToCart(p),
              ),
            );
          },
        );
      },
    );
  }
}

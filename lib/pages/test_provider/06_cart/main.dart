import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Provider 购物车实战示例
///
/// 综合运用 Provider 各知识点：
/// - ChangeNotifierProvider 管理状态
/// - MultiProvider 组合多个状态
/// - Selector 精准监听避免重建
/// - 跨页面状态共享
///
/// 场景：商品列表页 + 购物车页面，共享同一个 Cart 状态

// ==================== 数据模型 ====================

class Product {
  final String id;
  final String name;
  final double price;
  final String category;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
  });
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get totalPrice => product.price * quantity;
}

// ==================== 状态类 ====================

/// 商品目录状态
class CatalogState extends ChangeNotifier {
  final List<Product> _products = const [
    Product(id: '1', name: 'iPhone 15', price: 5999, category: '手机'),
    Product(id: '2', name: 'MacBook Pro', price: 14999, category: '电脑'),
    Product(id: '3', name: 'AirPods Pro', price: 1999, category: '配件'),
    Product(id: '4', name: 'iPad Air', price: 4799, category: '平板'),
    Product(id: '5', name: 'Apple Watch', price: 2999, category: '手表'),
    Product(id: '6', name: 'Magic Mouse', price: 699, category: '配件'),
  ];

  List<Product> get products => _products;

  List<Product> getByCategory(String category) {
    return _products.where((p) => p.category == category).toList();
  }

  List<String> get categories {
    return _products.map((p) => p.category).toSet().toList();
  }
}

/// 购物车状态
class CartState extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  /// 商品种类数
  int get itemCount => _items.length;

  /// 总商品数量
  int get totalQuantity => _items.fold(0, (sum, item) => sum + item.quantity);

  /// 总价
  double get totalPrice => _items.fold(
        0,
        (sum, item) => sum + item.totalPrice,
      );

  /// 是否包含某商品
  bool contains(String productId) {
    return _items.any((item) => item.product.id == productId);
  }

  void add(Product product) {
    final existing = _items.indexWhere((item) => item.product.id == product.id);
    if (existing >= 0) {
      _items[existing].quantity++;
    } else {
      _items.add(CartItem(product: product));
    }
    notifyListeners();
  }

  void remove(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      remove(productId);
      return;
    }
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _items[index].quantity = quantity;
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

// ==================== 页面入口 ====================

@RoutePage()
class ProviderCartRoute extends StatelessWidget {
  const ProviderCartRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CatalogState()),
        ChangeNotifierProvider(create: (_) => CartState()),
      ],
      child: const ProviderCartPage(),
    );
  }
}

class ProviderCartPage extends StatefulWidget {
  const ProviderCartPage({super.key});

  @override
  State<ProviderCartPage> createState() => _ProviderCartPageState();
}

class _ProviderCartPageState extends State<ProviderCartPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          ProductListPage(),
          CartPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.store),
            label: '商品',
          ),
          NavigationDestination(
            icon: Badge(
              // Selector 只监听 totalQuantity，避免整个 BottomNav 重建
              label: Selector<CartState, int>(
                selector: (_, cart) => cart.totalQuantity,
                builder: (context, count, child) {
                  return Text('$count');
                },
              ),
              isLabelVisible: context.select<CartState, bool>(
                (cart) => cart.totalQuantity > 0,
              ),
              child: const Icon(Icons.shopping_cart),
            ),
            label: '购物车',
          ),
        ],
      ),
    );
  }
}

// ==================== 商品列表页 ====================

class ProductListPage extends StatelessWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final catalog = context.read<CatalogState>();
    final categories = catalog.categories;

    return DefaultTabController(
      length: categories.length + 1, // +1 为"全部"
      child: Scaffold(
        appBar: AppBar(
          title: const Text('商品列表'),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              const Tab(text: '全部'),
              ...categories.map((c) => Tab(text: c)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // 全部商品
            _ProductGrid(products: catalog.products),
            // 按分类
            ...categories.map((c) => _ProductGrid(products: catalog.getByCategory(c))),
          ],
        ),
      ),
    );
  }
}

class _ProductGrid extends StatelessWidget {
  final List<Product> products;

  const _ProductGrid({required this.products});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _ProductCard(product: product);
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    // 只监听该商品是否在购物车中，避免整个列表重建
    final inCart = context.select<CartState, bool>(
      (cart) => cart.contains(product.id),
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 商品图片区域（用颜色块模拟）
          Expanded(
            child: Container(
              color: Colors.primaries[int.parse(product.id) % Colors.primaries.length].withAlpha(80),
              child: Center(
                child: Icon(
                  Icons.image,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '¥${product.price.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: inCart
                        ? null
                        : () => context.read<CartState>().add(product),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      backgroundColor: inCart ? Colors.grey : null,
                    ),
                    child: Text(inCart ? '已添加' : '加入购物车'),
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

// ==================== 购物车页 ====================

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('购物车'),
        actions: [
          TextButton(
            onPressed: () => context.read<CartState>().clear(),
            child: const Text('清空'),
          ),
        ],
      ),
      body: Consumer<CartState>(
        builder: (context, cart, child) {
          if (cart.items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('购物车是空的', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return _CartItemTile(item: item);
                  },
                ),
              ),
              // 底部结算栏
              _CheckoutBar(totalPrice: cart.totalPrice),
            ],
          );
        },
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItem item;

  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        color: Colors.primaries[int.parse(item.product.id) % Colors.primaries.length].withAlpha(80),
        child: const Icon(Icons.image, color: Colors.grey),
      ),
      title: Text(item.product.name),
      subtitle: Text(
        '¥${item.product.price.toStringAsFixed(0)}',
        style: TextStyle(color: Colors.red.shade700),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 减少数量
          IconButton(
            onPressed: () {
              context.read<CartState>().updateQuantity(
                item.product.id,
                item.quantity - 1,
              );
            },
            icon: const Icon(Icons.remove_circle_outline),
          ),
          // 数量 — 用 Selector 避免整行重建
          Selector<CartState, int>(
            selector: (_, cart) {
              final found = cart.items.firstWhere(
                (i) => i.product.id == item.product.id,
              );
              return found.quantity;
            },
            builder: (context, quantity, child) {
              return Text(
                '$quantity',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
          // 增加数量
          IconButton(
            onPressed: () {
              context.read<CartState>().updateQuantity(
                item.product.id,
                item.quantity + 1,
              );
            },
            icon: const Icon(Icons.add_circle_outline),
          ),
          const SizedBox(width: 8),
          // 删除
          IconButton(
            onPressed: () {
              context.read<CartState>().remove(item.product.id);
            },
            icon: const Icon(Icons.delete_outline, color: Colors.red),
          ),
        ],
      ),
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  final double totalPrice;

  const _CheckoutBar({required this.totalPrice});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('合计:', style: TextStyle(fontSize: 14)),
                  Text(
                    '¥${totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: totalPrice > 0
                  ? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('结算功能演示')),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('去结算'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// MultiProvider + ProxyProvider 示例
///
/// 核心知识点：
/// 1. MultiProvider — 同时提供多个不相关的状态
/// 2. ProxyProvider — 一个状态依赖另一个状态
/// 3. 依赖注入：上层状态改变时，下层依赖状态自动重建
///
/// 场景：用户登录后才能看到购物车，购物车价格依赖用户等级折扣

// ==================== 状态类 ====================

/// 用户状态
class UserState extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _username = '';
  int _level = 1; // 用户等级，影响折扣

  bool get isLoggedIn => _isLoggedIn;
  String get username => _username;
  int get level => _level;

  /// 折扣率：等级1=无折扣，等级2=9折，等级3=8折
  double get discount => 1.0 - (_level - 1) * 0.1;

  void login(String username, int level) {
    _isLoggedIn = true;
    _username = username;
    _level = level;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _username = '';
    _level = 1;
    notifyListeners();
  }
}

/// 购物车状态 — 依赖用户状态获取折扣
class CartState extends ChangeNotifier {
  final UserState _userState;

  CartState(this._userState);

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  /// 商品总价（未打折）
  double get totalPrice => _items.fold(
        0,
        (sum, item) => sum + item.price * item.quantity,
      );

  /// 折后价格 — 依赖 UserState 的 discount
  double get discountedPrice => totalPrice * _userState.discount;

  /// 节省金额
  double get savedAmount => totalPrice - discountedPrice;

  void addItem(String name, double price) {
    final existing = _items.indexWhere((item) => item.name == name);
    if (existing >= 0) {
      _items[existing] = _items[existing].copyWith(
        quantity: _items[existing].quantity + 1,
      );
    } else {
      _items.add(CartItem(name: name, price: price));
    }
    notifyListeners();
  }

  void removeItem(String name) {
    _items.removeWhere((item) => item.name == name);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

class CartItem {
  final String name;
  final double price;
  final int quantity;

  CartItem({required this.name, required this.price, this.quantity = 1});

  CartItem copyWith({String? name, double? price, int? quantity}) {
    return CartItem(
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
    );
  }
}

// ==================== 页面入口 ====================

@RoutePage()
class ProviderMultiRoute extends StatelessWidget {
  const ProviderMultiRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 1. 先提供 UserState
        ChangeNotifierProvider(create: (_) => UserState()),
        // 2. ProxyProvider 依赖 UserState，当 UserState 变化时自动重建 CartState
        ChangeNotifierProxyProvider<UserState, CartState>(
          create: (context) => CartState(context.read<UserState>()),
          update: (context, userState, previousCart) {
            // userState 变化时，创建新的 CartState 并保留原有商品
            final newCart = CartState(userState);
            if (previousCart != null) {
              newCart._items.addAll(previousCart._items);
            }
            return newCart;
          },
        ),
      ],
      child: const ProviderMultiPage(),
    );
  }
}

class ProviderMultiPage extends StatelessWidget {
  const ProviderMultiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MultiProvider + ProxyProvider'),
      ),
      body: Column(
        children: [
          // 用户信息栏
          const UserInfoBar(),
          const Divider(),
          // 商品列表
          const Expanded(
            child: ProductList(),
          ),
          const Divider(),
          // 购物车汇总
          const CartSummary(),
        ],
      ),
    );
  }
}

// ==================== 用户信息栏 ====================

class UserInfoBar extends StatelessWidget {
  const UserInfoBar({super.key});

  @override
  Widget build(BuildContext context) {
    // 监听用户登录状态
    final user = context.watch<UserState>();

    return Container(
      padding: const EdgeInsets.all(16),
      color: user.isLoggedIn ? Colors.green.shade50 : Colors.grey.shade100,
      child: Row(
        children: [
          Icon(
            user.isLoggedIn ? Icons.person : Icons.person_outline,
            color: user.isLoggedIn ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.isLoggedIn ? '欢迎, ${user.username}' : '未登录',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (user.isLoggedIn)
                  Text(
                    '等级${user.level} · 折扣 ${(user.discount * 10).toStringAsFixed(0)}折',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.orange.shade700,
                    ),
                  ),
              ],
            ),
          ),
          if (!user.isLoggedIn)
            Row(
              children: [
                TextButton(
                  onPressed: () => context.read<UserState>().login('普通用户', 1),
                  child: const Text('登录(等级1)'),
                ),
                TextButton(
                  onPressed: () => context.read<UserState>().login('VIP用户', 2),
                  child: const Text('登录(等级2)'),
                ),
                TextButton(
                  onPressed: () => context.read<UserState>().login('SVIP用户', 3),
                  child: const Text('登录(等级3)'),
                ),
              ],
            )
          else
            TextButton(
              onPressed: () => context.read<UserState>().logout(),
              child: const Text('退出登录'),
            ),
        ],
      ),
    );
  }
}

// ==================== 商品列表 ====================

class ProductList extends StatelessWidget {
  const ProductList({super.key});

  static const _products = [
    _Product('苹果', 5.0),
    _Product('香蕉', 3.0),
    _Product('橙子', 4.5),
    _Product('葡萄', 15.0),
  ];

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.select<UserState, bool>((u) => u.isLoggedIn);

    if (!isLoggedIn) {
      return const Center(
        child: Text('请先登录后再购买商品'),
      );
    }

    return ListView.builder(
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return ListTile(
          leading: const Icon(Icons.shopping_bag_outlined),
          title: Text(product.name),
          subtitle: Text('¥${product.price.toStringAsFixed(1)}'),
          trailing: ElevatedButton(
            onPressed: () {
              context.read<CartState>().addItem(product.name, product.price);
            },
            child: const Text('加入购物车'),
          ),
        );
      },
    );
  }
}

class _Product {
  final String name;
  final double price;
  const _Product(this.name, this.price);
}

// ==================== 购物车汇总 ====================

class CartSummary extends StatelessWidget {
  const CartSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.select<UserState, bool>((u) => u.isLoggedIn);

    if (!isLoggedIn) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue.shade50,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '购物车',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // 购物车商品列表
            Consumer<CartState>(
              builder: (context, cart, child) {
                if (cart.items.isEmpty) {
                  return const Text('购物车是空的', style: TextStyle(color: Colors.grey));
                }
                return Column(
                  children: cart.items.map((item) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${item.name} x${item.quantity}'),
                        Row(
                          children: [
                            Text('¥${(item.price * item.quantity).toStringAsFixed(1)}'),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => context.read<CartState>().removeItem(item.name),
                              child: const Icon(Icons.close, size: 16, color: Colors.red),
                            ),
                          ],
                        ),
                      ],
                    );
                  }).toList(),
                );
              },
            ),

            const Divider(),

            // 价格汇总 — 使用 Selector 避免不必要的重建
            Selector<CartState, (double, double, double)>(
              selector: (_, cart) => (
                cart.totalPrice,
                cart.discountedPrice,
                cart.savedAmount,
              ),
              builder: (context, prices, child) {
                final (total, discounted, saved) = prices;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '原价: ¥${total.toStringAsFixed(1)}',
                      style: const TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      '折后: ¥${discounted.toStringAsFixed(1)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    if (saved > 0)
                      Text(
                        '已省: ¥${saved.toStringAsFixed(1)}',
                        style: TextStyle(color: Colors.green.shade700),
                      ),
                  ],
                );
              },
            ),

            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.read<CartState>().clear(),
                child: const Text('清空购物车'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:math';

import 'package:ecommerce_app/src/features/authentication/data/fake_auth_repository.dart';
import 'package:ecommerce_app/src/features/cart/data/local/local_cart_repository.dart';
import 'package:ecommerce_app/src/features/cart/data/remote/remote_cart_repository.dart';
import 'package:ecommerce_app/src/features/cart/domain/cart.dart';
import 'package:ecommerce_app/src/features/cart/domain/item.dart';
import 'package:ecommerce_app/src/features/cart/domain/mutable_cart.dart';
import 'package:ecommerce_app/src/features/products/data/fake_products_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../authentication/domain/app_user.dart';

class CartSyncService {
  CartSyncService(this.ref) {
    _init();
  }

  final Ref ref;

  void _init() {
    ref.listen<AsyncValue<AppUser?>>(authStateChangesProvider,
        (previous, next) {
      final previousUser = previous?.value;
      final user = next.value;
      if (previousUser == null && user != null) {
        _moveItemsToRemotCart(user.uid);
      }
    });
  }

  Future<void> _moveItemsToRemotCart(String uid) async {
    try {
      // local storage
      final localCartRepository = ref.read(localCartRepositoryProvider);
      final localCart = await localCartRepository.fetchCart();
      if (localCart.items.isNotEmpty) {
        // remote data
        final remoteCartRepository = ref.read(remoteCartRepositoryProvider);
        final remoteCart = await remoteCartRepository.fetchCart(uid);
        final localItemsToAdd =
            await _getLocalItemsToAdd(localCart, remoteCart);
        // add item local to remote
        final updatedRemoteCart = remoteCart.addItems(localItemsToAdd);
        // save data to remote
        await remoteCartRepository.setCart(uid, updatedRemoteCart);
        // remove from local
        await localCartRepository.setCart(const Cart());
      }
    } catch (e) {}
  }

  Future<List<Item>> _getLocalItemsToAdd(
      Cart localCart, Cart remoteCart) async {
    // get list product
    final productsRepository = ref.read(productsRepositoryProvider);
    final products = await productsRepository.fetchProductsList();

    // Figure out item will be add
    final localItemsToAdd = <Item>[];
    for (final localItem in localCart.items.entries) {
      final productId = localItem.key;
      final localQuantity = localItem.value;
      // get quantity to macth remote
      final remoteQuantity = remoteCart.items[productId] ?? 0;
      final product = products.firstWhere((product) => product.id == productId);
      // cap quantity
      final cappedLocalQuantity = min(
        localQuantity,
        product.availableQuantity - remoteQuantity,
      );
      // if cap quantity > 0, add to list
      if (cappedLocalQuantity > 0) {
        localItemsToAdd.add(Item(
          productId: productId,
          quantity: cappedLocalQuantity,
        ));
      }
    }
    return localItemsToAdd;
  }
}

final cartSyncServiceProvider = Provider<CartSyncService>((ref) {
  return CartSyncService(ref);
});

import 'dart:async';

import 'package:ecommerce_app/src/constants/test_products.dart';
import 'package:ecommerce_app/src/features/products/domain/product.dart';
import 'package:ecommerce_app/src/utils/delay.dart';
import 'package:ecommerce_app/src/utils/in_memory_store.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FakeProductsRepository {
  FakeProductsRepository({this.addDelay = true});
  final bool addDelay;

  /// Preload with the default list of products when the app starts
  final _products = InMemoryStore<List<Product>>(List.from(kTestProducts));

  List<Product> getProductsList() {
    return _products.value;
  }

  Product? getProduct(String id) {
    return _getProduct(_products.value, id);
  }

  Future<List<Product>> fetchProductsList() async {
    return Future.value(_products.value);
  }

  Stream<List<Product>> watchProductsList() {
    return _products.stream;
  }

  Stream<Product?> watchProduct(String id) {
    return watchProductsList().map((products) => _getProduct(products, id));
  }

  /// Update product or add a new one
  Future<void> setProduct(Product product) async {
    await delay(addDelay);
    final products = _products.value;
    final index = products.indexWhere((p) => p.id == product.id);
    if (index == -1) {
      // if not found, add as a new product
      products.add(product);
    } else {
      // else, overwrite previous product
      products[index] = product;
    }
    _products.value = products;
  }

  Future<List<Product>> searchProducts(String query) async {
    assert(
      _products.value.length <= 100,
      'Client-side search should only be performed if the number of products is small. '
      'Consider doing server-side search for larger datasets.',
    );

    final productList = await fetchProductsList();

    return productList
        .where((product) =>
            product.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  static Product? _getProduct(List<Product> products, String id) {
    try {
      return products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }
}

final productsRepositoryProvider = Provider<FakeProductsRepository>((ref) {
  // * Set addDelay to false for faster loading
  return FakeProductsRepository(addDelay: false);
});

final productsListStreamProvider =
    StreamProvider.autoDispose<List<Product>>((ref) {
  final productsRepository = ref.watch(productsRepositoryProvider);
  return productsRepository.watchProductsList();
});

final productsListFutureProvider =
    FutureProvider.autoDispose<List<Product>>((ref) {
  final productsRepository = ref.watch(productsRepositoryProvider);
  return productsRepository.fetchProductsList();
});

final productProvider =
    StreamProvider.autoDispose.family<Product?, String>((ref, id) {
  final productsRepository = ref.watch(productsRepositoryProvider);
  return productsRepository.watchProduct(id);
});

final productsListSearchProvider = FutureProvider.autoDispose
    .family<List<Product>, String>((ref, query) async {
  final link = ref.keepAlive();
  final timer = Timer(const Duration(seconds: 5), () {
    link.close();
  });
  ref.onDispose(() => timer.cancel());
  final productsRepository = ref.watch(productsRepositoryProvider);
  return productsRepository.searchProducts(query);
});

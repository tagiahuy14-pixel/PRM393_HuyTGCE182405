import '../models/item.dart';

class FakeApiService {
  static Future<List<Item>> fetchItems() async {
    print('1. B\u1eaeT \u0110\u1ea6U g\u1ecdi fetchItems');
    await Future.delayed(const Duration(seconds: 2));
    print('2. SAU khi Future.delayed xong');

    return const [
      Item(name: 'T\u00e1o', price: 10000),
      Item(name: 'Cam', price: 15000),
      Item(name: 'Chu\u1ed1i', price: 8000),
    ];
  }
}

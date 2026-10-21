import 'package:intl/intl.dart';

final _vnd = NumberFormat('#,##0.##', 'vi_VN');
String formatVnd(double amount) => '${_vnd.format(amount)} ₫';

// Sum integer hundredths to avoid displaying floating-point accumulation noise.
double totalPrices(Iterable<double> prices) =>
    prices.fold<int>(0, (sum, price) => sum + (price * 100).round()) / 100;

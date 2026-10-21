class ItemValidation {
  static const maxPrice = 999999999999.99;

  static String? requiredText(String? value, String field) =>
      value == null || value.trim().isEmpty ? 'Please enter $field' : null;

  // Accept raw VND values and an optional decimal part. Never strip invalid
  // characters: "-100" or "12abc" must not silently become a valid price.
  static String? price(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Please enter price';
    if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(text)) {
      return 'Enter a numeric price (e.g. 2500000 or 2500000.50)';
    }
    final number = double.tryParse(text);
    if (number == null || !number.isFinite || number <= 0) {
      return 'Price must be greater than zero';
    }
    if (number > maxPrice) return 'Price must be at most 999999999999.99 VND';
    return null;
  }
}

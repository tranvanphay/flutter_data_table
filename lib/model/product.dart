class Product {
  String productCode;
  String productImage;
  String productName;
  String productPrices;

  Product(
      {required this.productCode,
      required this.productImage,
      required this.productName,
      required this.productPrices});

  factory Product.fromJson(Map<String, dynamic> data) {
    return Product(
        productCode: data["product_code"],
        productImage: data["product_image"],
        productName: data["product_name"],
        productPrices: data["product_prices"]);
  }
}

List<Product> productListFromJson(List data) {
  return List<Product>.from(data.map((item) => Product.fromJson(item)));
}

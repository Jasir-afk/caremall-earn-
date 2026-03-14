class ProductLinkModel {
  final String id;
  final String linkCode;
  final String linkUrl;
  final int clickCount;
  final int orderCount;
  final String status;
  final String productName;
  final List<String> productImages;
  final double landingSellPrice;
  final double mrpPrice;
  final double affiliateCommission;
  final bool isAffiliateActive;
  final int stock;

  ProductLinkModel({
    required this.id,
    required this.linkCode,
    required this.linkUrl,
    required this.clickCount,
    required this.orderCount,
    required this.status,
    required this.productName,
    required this.productImages,
    required this.landingSellPrice,
    required this.mrpPrice,
    required this.stock,
    this.affiliateCommission = 0,
    this.isAffiliateActive = false,
  });

  factory ProductLinkModel.fromJson(Map<String, dynamic> json) {
    // Check if product data is nested (the link-list structure) or flat (the product-list structure)
    final bool isNested = json.containsKey('product');
    final Map<String, dynamic> productData = isNested
        ? (json['product'] as Map<String, dynamic>)
        : json;

    List<String> images = [];
    if (productData['productImages'] is List) {
      images = (productData['productImages'] as List)
          .map((e) => e.toString())
          .toList();
    } else if (productData.containsKey('defaultVariant') &&
        productData['defaultVariant'] is Map &&
        productData['defaultVariant']['images'] is List) {
      images = (productData['defaultVariant']['images'] as List)
          .map((e) => e.toString())
          .toList();
    }

    return ProductLinkModel(
      id: (productData['_id'] ?? productData['id'] ?? '').toString(),
      linkCode: (json['linkCode'] ?? '').toString(),
      linkUrl: (json['linkUrl'] ?? '').toString(),
      clickCount: int.tryParse(json['clickCount']?.toString() ?? '0') ?? 0,
      orderCount: int.tryParse(json['orderCount']?.toString() ?? '0') ?? 0,
      status: (json['status'] ?? 'active').toString(),
      productName: (productData['productName'] ?? '').toString(),
      productImages: images,
      landingSellPrice:
          double.tryParse(
            productData['landingSellPrice']?.toString() ??
                productData['landingsellprice']?.toString() ??
                productData['landing_sell_price']?.toString() ??
                productData['defaultVariant']?['landingSellPrice']?.toString() ??
                productData['defaultVariant']?['landingsellprice']?.toString() ??
                productData['defaultVariant']?['landing_sell_price']?.toString() ??
                productData['sellingPrice']?.toString() ??
                productData['salePrice']?.toString() ??
                productData['price']?.toString() ??
                '0',
          ) ??
          0.0,
      mrpPrice:
          double.tryParse(
            productData['mrpPrice']?.toString() ??
                productData['mrp']?.toString() ??
                productData['regularPrice']?.toString() ??
                productData['defaultVariant']?['mrpPrice']?.toString() ??
                productData['defaultVariant']?['mrp']?.toString() ??
                productData['defaultVariant']?['regularPrice']?.toString() ??
                '0',
          ) ??
          0.0,
      affiliateCommission:
          double.tryParse(
            productData['affiliateCommission']?.toString() ?? '0',
          ) ??
          0.0,
      stock:
          int.tryParse(
            (productData['stock'] ?? productData['quantity'] ?? '10')
                .toString(),
          ) ??
          10,
      isAffiliateActive:
          (json['status'] == 'active' &&
          (json['linkUrl']?.toString().isNotEmpty ?? false)),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../utils/app_const.dart';
import '../../../utils/theme_manager.dart';
import '../../../utils/shared_pref.dart';
import '../../../utils/extension.dart';
import '../../../config/routes/route_manager.dart';
import '../../../models/product_model.dart';
import '../../../services/contact_seller_api_service.dart';
import '../../main/widgets/secondary_button.dart';
import '../../main/widgets/skeleton_loader.dart';
import 'product_detail_controller.dart';

class ProductDetailScreen extends StatelessWidget {
  final String productId;
  final ProductModel? productData;

  const ProductDetailScreen({
    super.key,
    required this.productId,
    this.productData,
  });

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    Get.put(ProductDetailController(
      productId: productId,
      initialProductData: productData,
    ));

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: GetBuilder<ProductDetailController>(
        builder: (ProductDetailController controller) {
          if (controller.isLoading && controller.product == null) {
            return _buildSkeletonLoader();
          }

          if (controller.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi_off_rounded, size: 80, color: colorGrey),
                    const SizedBox(height: 20),
                    Text(
                      'Connection Error',
                      style: textStyleSubHeading.copyWith(color: colorGrey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      controller.errorMessage ??
                          'Failed to load product details',
                      style: textStyleBody.copyWith(color: colorGrey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SecondaryButton(
                          text: 'Go Back',
                          onPressed: () => Get.back(),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: controller.loadProductDetail,
                          style: primaryButtonStyle,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }

          if (controller.product == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 80, color: colorGrey),
                  const SizedBox(height: 20),
                  Text('Product not found', style: textStyleSubHeading),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    style: primaryButtonStyle,
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          final product = controller.product!;

          return AnimatedOpacity(
            opacity: controller.isLoading ? 0.5 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: CustomScrollView(
              slivers: [
                // App Bar with Images
                _buildAppBar(controller, product),
                // Product Details
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and Wishlist Card with enhanced design
                      Container(
                        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: colorWhite,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: colorMainTheme.withOpacity(0.2),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colorMainTheme.withOpacity(0.15),
                              blurRadius: 25,
                              offset: const Offset(0, 8),
                              spreadRadius: 0,
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          product.title,
                                          style: textStyleHeading.copyWith(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w800,
                                            height: 1.2,
                                            color: Colors.grey.shade900,
                                          ),
                                        ),
                                      ),
                                      // Product Type Badge
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 7,
                                        ),
                                        decoration: BoxDecoration(
                                          color: product.productType == 'both'
                                              ? Colors.purple.shade500
                                              : product.type == 'rent'
                                                  ? Colors.blue.shade600
                                                  : Colors.green.shade600,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                            color: (product.productType == 'both'
                                                    ? Colors.purple
                                                    : product.type == 'rent'
                                                        ? Colors.blue
                                                        : Colors.green)
                                                .shade700
                                                .withOpacity(0.3),
                                            width: 1.5,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: (product.productType == 'both'
                                                      ? Colors.purple
                                                      : product.type == 'rent'
                                                          ? Colors.blue
                                                          : Colors.green)
                                                  .withOpacity(0.4),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                              spreadRadius: 0,
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              product.productType == 'both'
                                                  ? Icons.swap_horiz_rounded
                                                  : product.type == 'rent'
                                                      ? Icons.receipt_long_rounded
                                                      : Icons.shopping_bag_rounded,
                                              size: 14,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              product.productType == 'both'
                                                  ? 'Rent & Sell'
                                                  : product.type == 'rent'
                                                      ? 'Rental'
                                                      : 'For Sale',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: 0.3,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: colorMainTheme.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                            color: colorMainTheme.withOpacity(0.25),
                                            width: 1.5,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: colorMainTheme.withOpacity(0.1),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          Icons.location_on_rounded,
                                          size: 17,
                                          color: colorMainTheme,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          product.getCity(),
                                          style: textStyleBody.copyWith(
                                            color: Colors.grey.shade700,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      if (product.distance != null) ...[
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 7,
                                          ),
                                          decoration: BoxDecoration(
                                            color: colorMainTheme.withOpacity(0.18),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: colorMainTheme.withOpacity(0.35),
                                              width: 2,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: colorMainTheme.withOpacity(0.25),
                                                blurRadius: 10,
                                                offset: const Offset(0, 3),
                                                spreadRadius: 0,
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.navigation_rounded,
                                                size: 12,
                                                color: colorMainTheme,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${product.distance!.toStringAsFixed(1)} km',
                                                style: textStyleCaption.copyWith(
                                                  fontSize: 11,
                                                  color: colorMainTheme,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Enhanced Wishlist Icon
                            GestureDetector(
                              onTap: controller.toggleWishlist,
                              child: Container(
                                padding: const EdgeInsets.all(13),
                                decoration: BoxDecoration(
                                  color: product.isWishlisted
                                      ? Colors.red.shade500
                                      : Colors.grey.shade100,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: product.isWishlisted
                                        ? Colors.red.shade400
                                        : Colors.grey.shade300,
                                    width: 2.5,
                                  ),
                                  boxShadow: product.isWishlisted
                                      ? [
                                          BoxShadow(
                                            color: Colors.red.withOpacity(0.5),
                                            blurRadius: 15,
                                            spreadRadius: 2,
                                            offset: const Offset(0, 5),
                                          ),
                                        ]
                                      : [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.08),
                                            blurRadius: 10,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                ),
                                child: Icon(
                                  product.isWishlisted
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  color: product.isWishlisted
                                      ? Colors.white
                                      : colorGrey,
                                  size: 25,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Price Section
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: colorWhite,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: colorMainTheme.withOpacity(0.25),
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colorMainTheme.withOpacity(0.25),
                              blurRadius: 25,
                              offset: const Offset(0, 8),
                              spreadRadius: 0,
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: colorMainTheme.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.currency_rupee_rounded,
                                    color: colorMainTheme,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Pricing',
                                  style: textStyleSubHeading.copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Price display based on productType
                            if (product.productType == 'both') ...[
                              // Show both rent and sell prices with same height
                              IntrinsicHeight(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: Colors.blue.shade200,
                                            width: 1,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.receipt_long_rounded,
                                                  size: 14,
                                                  color: Colors.blue.shade700,
                                                ),
                                                const SizedBox(width: 5),
                                                Text(
                                                  'Rent',
                                                  style: textStyleCaption.copyWith(
                                                    fontSize: 11,
                                                    color: Colors.blue.shade700,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              '₹${product.getPriceForType('rent').toStringAsFixed(0)}',
                                              style: textStyleHeading.copyWith(
                                                fontSize: 22,
                                                color: Colors.blue.shade700,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'per day',
                                              style: textStyleCaption.copyWith(
                                                fontSize: 10,
                                                color: Colors.blue.shade600,
                                              ),
                                            ),
                                            const Spacer(),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: Colors.green.shade300,
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.green.withOpacity(0.2),
                                            blurRadius: 10,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.shopping_bag_rounded,
                                                  size: 14,
                                                  color: Colors.green.shade700,
                                                ),
                                                const SizedBox(width: 5),
                                                Text(
                                                  'Sell',
                                                  style: textStyleCaption.copyWith(
                                                    fontSize: 11,
                                                    color: Colors.green.shade700,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              '₹${product.getPriceForType('sell').toStringAsFixed(0)}',
                                              style: textStyleHeading.copyWith(
                                                fontSize: 22,
                                                color: Colors.green.shade700,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const Spacer(),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ] else ...[
                              // Show single price based on productType
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              product.type == 'rent'
                                                  ? Icons.receipt_long_rounded
                                                  : Icons.shopping_bag_rounded,
                                              size: 18,
                                              color: colorMainTheme,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              product.type == 'rent' ? 'Rent Price' : 'Sell Price',
                                              style: textStyleCaption.copyWith(
                                                fontSize: 13,
                                                color: colorGrey,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '₹${product.getPriceForType(product.type).toStringAsFixed(0)}',
                                          style: textStyleHeading.copyWith(
                                            fontSize: 28,
                                            color: colorMainTheme,
                                            fontWeight: FontWeight.w700,
                                            height: 1.1,
                                          ),
                                        ),
                                        if (product.type == 'rent') ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            'per day',
                                            style: textStyleCaption.copyWith(
                                              fontSize: 12,
                                              color: colorGrey,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  if (product.type == 'rent' &&
                                      product.deposit != null)
                                    Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: colorMainTheme.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: colorMainTheme.withOpacity(0.2),
                                          width: 1,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            'Deposit',
                                            style: textStyleCaption.copyWith(
                                              fontSize: 11,
                                              color: colorGrey,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            '₹${product.deposit!.toStringAsFixed(0)}',
                                            style: textStyleSubHeading.copyWith(
                                              fontSize: 20,
                                              color: colorMainTheme,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Description
                      _buildSection(
                        icon: Icons.description_rounded,
                        title: 'Description',
                        child: Text(
                          product.description,
                          style: textStyleBody.copyWith(
                            fontSize: 14,
                            height: 1.5,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Product Details
                      _buildSection(
                        icon: Icons.info_outline_rounded,
                        title: 'Product Details',
                        child: Column(
                          children: [
                            _buildDetailRow(
                              Icons.category_rounded,
                              'Type',
                              product.productType == 'both' 
                                  ? 'Rent & Sell'
                                  : (product.type == 'rent' ? 'Rental' : 'For Sale'),
                            ),
                            if (product.condition != null)
                              _buildDetailRow(
                                Icons.verified_outlined,
                                'Condition',
                                product.condition!.capitalizeFirst ??
                                    product.condition!,
                              ),
                            // Display dynamic attributes
                            if (product.attributes != null && product.attributes!.isNotEmpty)
                              ...product.attributes!.entries.map((entry) {
                                // Skip if already shown as direct property
                                if (entry.key == 'condition' && product.condition != null) {
                                  return const SizedBox.shrink();
                                }
                                return _buildDetailRow(
                                  _getAttributeIcon(entry.key),
                                  entry.key.capitalizeFirst ?? entry.key,
                                  entry.value?.toString() ?? '',
                                );
                              }).toList()
                            else ...[
                              // Fallback to direct properties if no attributes
                              _buildDetailRow(
                                Icons.person_outline_rounded,
                                'Gender',
                                product.gender.capitalizeFirst ??
                                    product.gender,
                              ),
                              if (product.size != null)
                                _buildDetailRow(Icons.straighten_rounded, 'Size', product.size!),
                              if (product.color != null)
                                _buildDetailRow(Icons.palette_outlined, 'Color', product.color!),
                              if (product.brand != null)
                                _buildDetailRow(Icons.branding_watermark_rounded, 'Brand', product.brand!),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 100), // Space for bottom button
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: GetBuilder<ProductDetailController>(
        builder: (ProductDetailController controller) {
          if (controller.product == null) return const SizedBox.shrink();
          
          // Hide Contact Seller button if it's the user's own product
          if (controller.isOwnProduct) return const SizedBox.shrink();

          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(Get.context!).padding.bottom + 16,
              top: 16,
              left: 16,
              right: 16,
            ),
            decoration: BoxDecoration(
              color: colorWhite,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => _showContactDialog(controller, Get.context!),
              style: primaryButtonStyle.copyWith(
                minimumSize: WidgetStateProperty.all(
                  const Size(double.infinity, 50),
                ),
              ),
              child: const Text(
                'Contact Seller',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(ProductDetailController controller, product) {
    return SliverAppBar(
      expandedHeight: 400,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 3),
              spreadRadius: 0,
            ),
          ],
        ),
        child: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colorMainTheme, size: 22),
          onPressed: () => Get.back(),
          padding: EdgeInsets.zero,
        ),
      ),
      actions: const [],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Main Image with gradient overlay
            if (product.imageUrls.isNotEmpty)
              Stack(
                children: [
                  PageView.builder(
                    itemCount: product.imageUrls.length,
                    onPageChanged: controller.setSelectedImageIndex,
                    itemBuilder: (context, index) {
                      return Image.network(
                        product.imageUrls[index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: colorMainTheme.withOpacity(0.08),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(18),
                                    decoration: BoxDecoration(
                                      color: colorMainTheme.withOpacity(0.12),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: colorMainTheme.withOpacity(0.2),
                                        width: 2,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.image_not_supported_rounded,
                                      size: 52,
                                      color: colorMainTheme,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: colorMainTheme.withOpacity(0.08),
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                                color: colorMainTheme,
                                strokeWidth: 4,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  // Solid overlay at bottom for better indicator visibility
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 100,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.35),
                      ),
                    ),
                  ),
                ],
              )
            else
              Container(
                height: double.infinity,
                width: double.infinity,
                color: colorMainTheme.withOpacity(0.1),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(26),
                      decoration: BoxDecoration(
                        color: colorWhite,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorMainTheme.withOpacity(0.3),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colorMainTheme.withOpacity(0.3),
                            blurRadius: 25,
                            spreadRadius: 3,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.image_outlined,
                        size: 68,
                        color: colorMainTheme,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'No Image Available',
                      style: TextStyle(
                        fontSize: 17,
                        color: colorMainTheme,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            // Enhanced Image Indicator with count
            if (product.imageUrls.length > 1)
              Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.25),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.photo_library_rounded,
                          size: 15,
                          color: Colors.white.withOpacity(0.95),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${controller.selectedImageIndex + 1} / ${product.imageUrls.length}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 12),
                        ...List.generate(
                          product.imageUrls.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            margin: const EdgeInsets.symmetric(horizontal: 2.5),
                            width: controller.selectedImageIndex == index ? 24 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: controller.selectedImageIndex == index
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(3),
                              boxShadow: controller.selectedImageIndex == index
                                  ? [
                                      BoxShadow(
                                        color: colorMainTheme.withOpacity(0.7),
                                        blurRadius: 8,
                                        spreadRadius: 1.5,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorMainTheme.withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: colorMainTheme.withOpacity(0.12),
            blurRadius: 25,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: colorMainTheme.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorMainTheme.withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorMainTheme.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: colorMainTheme,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: textStyleSubHeading.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey.shade900,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorMainTheme.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: colorMainTheme.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: colorMainTheme.withOpacity(0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 18,
              color: colorMainTheme,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: textStyleBody.copyWith(
                color: Colors.grey.shade800,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: colorMainTheme.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: colorMainTheme.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: colorMainTheme.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              value,
              style: textStyleBody.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: colorMainTheme,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getAttributeIcon(String key) {
    switch (key.toLowerCase()) {
      case 'gender':
        return Icons.person_outline_rounded;
      case 'size':
        return Icons.straighten_rounded;
      case 'color':
        return Icons.palette_outlined;
      case 'brand':
        return Icons.branding_watermark_rounded;
      case 'material':
        return Icons.texture_rounded;
      case 'condition':
        return Icons.verified_outlined;
      case 'year':
        return Icons.calendar_today_rounded;
      case 'model':
        return Icons.directions_car_rounded;
      case 'fuel':
        return Icons.local_gas_station_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  Widget _buildSkeletonLoader() {
    return CustomScrollView(
      slivers: [
        // Skeleton App Bar
        SliverAppBar(
          expandedHeight: 300,
          floating: false,
          pinned: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorWhite.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Get.back(),
            ),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: ShimmerEffect(
              child: Container(
                color: Colors.grey.shade300,
                child: const Center(
                  child: Icon(Icons.image, size: 60, color: Colors.grey),
                ),
              ),
            ),
          ),
        ),
        // Skeleton Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Skeleton
                ShimmerEffect(
                  child: SkeletonLoader(
                    width: double.infinity,
                    height: 28,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 12),
                ShimmerEffect(
                  child: SkeletonLoader(
                    width: 200,
                    height: 16,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 24),
                // Price Skeleton
                ShimmerEffect(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonLoader(width: 60, height: 14),
                            const SizedBox(height: 8),
                            SkeletonLoader(width: 120, height: 32),
                          ],
                        ),
                        SkeletonLoader(width: 80, height: 24),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Description Skeleton
                ShimmerEffect(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonLoader(width: 100, height: 18),
                        const SizedBox(height: 12),
                        SkeletonLoader(width: double.infinity, height: 14),
                        const SizedBox(height: 8),
                        SkeletonLoader(width: double.infinity, height: 14),
                        const SizedBox(height: 8),
                        SkeletonLoader(width: 200, height: 14),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Details Skeleton
                ShimmerEffect(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: List.generate(
                        5,
                        (index) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SkeletonLoader(width: 80, height: 16),
                              SkeletonLoader(width: 100, height: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showContactDialog(
    ProductDetailController controller,
    BuildContext context,
  ) async {
    final product = controller.product!;

    // Check if user is logged in first
    final jwtToken = preferences.getString(SharedPreference.jwtToken);
    if (jwtToken == null || jwtToken.isEmpty) {
      // Show login dialog
      _showLoginRequiredDialog(context);
      return;
    }

    // Check if sellerId/ownerId is available
    if (product.sellerId.isEmpty) {
      // Show error message if ownerId is not available
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.info_outline_rounded,
                    color: Colors.orange.shade700,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Contact Not Available',
                    style: textStyleSubHeading.copyWith(fontSize: 18),
                  ),
                ),
              ],
            ),
            content: Text(
              'Seller contact information is not available for this product.',
              style: textStyleBody.copyWith(fontSize: 15),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      }
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Call Contact Seller API
      final contactApiService = ContactSellerApiService();
      final contactResponse = await contactApiService.getSellerContact(
        ownerId: product.sellerId, // Use sellerId which contains the ownerId
        jwtToken: jwtToken,
      );

      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context);
      }

      if (contactResponse != null) {
        // Show contact dialog with API response data
        _showSellerContactDialog(
          context: context,
          sellerName: contactResponse.name.isNotEmpty 
              ? contactResponse.name 
              : 'Seller',
          sellerPhone: contactResponse.mobile.isNotEmpty 
              ? contactResponse.mobile 
              : 'Not available',
        );
      } else {
        // Show error message
        if (context.mounted) {
          context.showErrorToast(
            message: 'Failed to load seller contact information. Please try again.',
          );
        }
      }
    } catch (e) {
      // Close loading dialog if still open
      if (context.mounted) {
        Navigator.pop(context);
        context.showErrorToast(
          message: 'An error occurred while loading contact information.',
        );
      }
    }
  }

  void _showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorMainTheme.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.login_rounded,
                color: colorMainTheme,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Login Required',
                style: textStyleSubHeading.copyWith(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Text(
          'Please login to view seller contact information.',
          style: textStyleBody.copyWith(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Get.toNamed(AppRoutes.mobileLogin);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorMainTheme,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Login',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSellerContactDialog({
    required BuildContext context,
    required String sellerName,
    required String sellerPhone,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorMainTheme.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.contact_phone_rounded,
                color: colorMainTheme,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Seller Contact',
                style: textStyleSubHeading.copyWith(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seller Name
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.person_rounded,
                    size: 20,
                    color: colorMainTheme,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Seller Name',
                          style: textStyleCaption.copyWith(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          sellerName,
                          style: textStyleBody.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Seller Phone
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.phone_rounded,
                    size: 20,
                    color: colorMainTheme,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Phone Number',
                          style: textStyleCaption.copyWith(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          sellerPhone,
                          style: textStyleBody.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: colorMainTheme,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      // Check if phone number is valid
                      if (sellerPhone.isEmpty || 
                          sellerPhone == 'Not available' ||
                          !sellerPhone.contains(RegExp(r'[0-9]'))) {
                        context.showErrorToast(
                          message: 'Phone number is not available',
                        );
                        return;
                      }

                      // Remove any non-digit characters except + for international numbers
                      final phoneNumber = sellerPhone.replaceAll(RegExp(r'[^\d+]'), '');
                      
                      // Create tel: URI
                      final uri = Uri.parse('tel:$phoneNumber');
                      
                      try {
                        // Check if device can make phone calls
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        } else {
                          context.showErrorToast(
                            message: 'Unable to make phone call. Please check your device settings.',
                          );
                        }
                      } catch (e) {
                        context.showErrorToast(
                          message: 'Failed to open phone dialer. Please try again.',
                        );
                      }
                    },
                    icon: Icon(
                      Icons.call_rounded,
                      color: Colors.green.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

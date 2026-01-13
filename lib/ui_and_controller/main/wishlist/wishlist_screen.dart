import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/app_const.dart';
import '../../../utils/theme_manager.dart';
import '../../../config/routes/route_manager.dart';
import '../../../models/product_model.dart';
import 'wishlist_controller.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    final controller = Get.put(WishlistController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.onTabVisible();
    });

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: colorMainTheme,
        elevation: 0,
        title: Text(
          'My Wishlist',
          style: textStyleSubHeading.copyWith(
            color: colorWhite,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: GetBuilder<WishlistController>(
        builder: (WishlistController controller) {
          return RefreshIndicator(
            onRefresh: controller.refreshWishlist,
            color: colorMainTheme,
            child: CustomScrollView(
              slivers: [
                _buildFilterTabs(controller),
                if (controller.isLoading)
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.all(40),
                      child: const Center(
                        child: CircularProgressIndicator(color: colorMainTheme),
                      ),
                    ),
                  )
                // Error State
                else if (controller.hasError &&
                    controller.wishlistItems.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.wifi_off_rounded,
                              size: 80,
                              color: colorGrey,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Connection Error',
                              style: textStyleSubHeading.copyWith(
                                color: colorGrey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              controller.errorMessage ??
                                  'Failed to load wishlist',
                              style: textStyleBody.copyWith(color: colorGrey),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: controller.refreshWishlist,
                              style: primaryButtonStyle,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else if (controller.wishlistItems.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.favorite_border_rounded,
                            size: 80,
                            color: colorGrey,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Your wishlist is empty',
                            style: textStyleSubHeading.copyWith(
                              color: colorGrey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start adding items you like!',
                            style: textStyleBody.copyWith(color: colorGrey),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverToBoxAdapter(
                    child: controller.wishlistItems.isEmpty
                        ? Container(
                            padding: const EdgeInsets.symmetric(vertical: 60),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    controller.selectedFilter == 'rent'
                                        ? Icons.receipt_long_rounded
                                        : Icons.shopping_bag_rounded,
                                    size: 80,
                                    color: colorGrey,
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    'No ${controller.selectedFilter == 'rent' ? 'renting' : 'shopping'} items in wishlist',
                                    style: textStyleSubHeading.copyWith(
                                      color: colorGrey,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Start adding ${controller.selectedFilter == 'rent' ? 'renting' : 'shopping'} items you like!',
                                    style: textStyleBody.copyWith(
                                      color: colorGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.70,
                                    crossAxisSpacing: 14,
                                    mainAxisSpacing: 14,
                                  ),
                              itemCount: controller.wishlistItems.length,
                              itemBuilder: (context, index) {
                                final product = controller.wishlistItems[index];
                                return _buildWishlistItemCard(
                                  product,
                                  controller,
                                );
                              },
                            ),
                          ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterTabs(WishlistController controller) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            _buildFilterTab(
              label: 'Renting',
              isSelected: controller.selectedFilter == 'rent',
              onTap: () => controller.setFilter('rent'),
            ),
            _buildFilterTab(
              label: 'Shopping',
              isSelected: controller.selectedFilter == 'sell',
              onTap: () => controller.setFilter('sell'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    IconData icon = label == 'Renting'
        ? Icons.receipt_long_rounded
        : Icons.shopping_bag_rounded;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected ? colorMainTheme : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? colorWhite : colorGrey, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: textStyleSubHeading.copyWith(
                  fontSize: 14,
                  color: isSelected ? colorWhite : colorGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductTypeLabel(
    ProductModel product,
    WishlistController controller,
  ) {
    final productType = product.productType ?? product.type;
    final isBoth = productType == 'both';
    
    // Determine colors and label based on product type
    String label;
    List<Color> gradientColors;
    Color shadowColor;
    
    if (isBoth) {
      label = 'Rent & Sell';
      gradientColors = [Colors.purple.shade600, Colors.purple.shade700];
      shadowColor = Colors.purple;
    } else if (productType == 'rent') {
      label = 'Rent';
      gradientColors = [Colors.blue.shade600, Colors.blue.shade700];
      shadowColor = Colors.blue;
    } else {
      label = 'Sell';
      gradientColors = [Colors.green.shade600, Colors.green.shade700];
      shadowColor = Colors.green;
    }
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isBoth ? 10 : 8, // More padding for "Rent & Sell"
        vertical: 4,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildWishlistItemCard(
    ProductModel product,
    WishlistController controller,
  ) {
    final hasImage =
        product.imageUrls.isNotEmpty && product.imageUrls[0].isNotEmpty;
    return GestureDetector(
      onTap: () {
        // Pass the selected filter so product detail screen can show correct pricing tab
        Get.toNamed(
          AppRoutes.productDetail,
          arguments: {
            'productId': product.id,
            'initialType': controller.selectedFilter, // Pass selected filter (rent/sell)
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: colorWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorMainTheme.withOpacity(0.15), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: hasImage
                      ? Image.network(
                          product.imageUrls[0],
                          height: 135,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildImagePlaceholder();
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 135,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.grey.shade100,
                                    Colors.grey.shade200,
                                  ],
                                ),
                              ),
                              child: Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: colorMainTheme,
                                  strokeWidth: 2.5,
                                ),
                              ),
                            );
                          },
                        )
                      : _buildImagePlaceholder(),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () => controller.removeFromWishlist(product),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Colors.red.shade600,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 6,
                  left: 6,
                  child: _buildProductTypeLabel(product, controller),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade900,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 11,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            product.location,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Text(
                            '₹${product.price.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: colorMainTheme,
                              height: 1,
                            ),
                          ),
                        ),
                        if (product.distance != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: colorMainTheme.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.navigation_rounded,
                                  size: 10,
                                  color: colorMainTheme,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${product.distance!.toStringAsFixed(1)} km',
                                  style: TextStyle(
                                    fontSize: 9,
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 135,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade100,
            Colors.grey.shade200,
            Colors.grey.shade100,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.image_outlined,
              size: 40,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No Image',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

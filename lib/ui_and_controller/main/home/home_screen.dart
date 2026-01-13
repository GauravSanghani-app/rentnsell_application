import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rent_n_sell/config/routes/route_manager.dart';
import 'package:rent_n_sell/models/product_model.dart';
import 'package:rent_n_sell/ui_and_controller/main/notification/notification_controller.dart';
import 'package:rent_n_sell/utils/app_const.dart';
import 'package:rent_n_sell/utils/theme_manager.dart';
import 'home_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    if (Get.isRegistered<HomeController>()) {
      try {
        Get.delete<HomeController>();
      } catch (e) {
        log("Error :- $e");
      }
    }

    // Create new controller instance
    Get.put(HomeController());

    // Trigger load when screen becomes visible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<HomeController>()) {
        try {
          Get.find<HomeController>().onTabVisible();
        } catch (e) {
          // Controller disposed, ignore
        }
      }
    });

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(context),
      body: GetBuilder<HomeController>(
        builder: (HomeController controller) {
          return RefreshIndicator(
            onRefresh: controller.refreshProducts,
            color: colorMainTheme,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTabs(controller),
                  _buildItemsListSection(controller),
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(100),
      child: GetBuilder<HomeController>(
        builder: (HomeController controller) {
          return AppBar(
            backgroundColor: colorMainTheme,
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [colorMainTheme, colorMainTheme.withOpacity(0.8)],
                ),
              ),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 4,
                left: 16,
                right: 16,
                bottom: 8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        color: colorWhite,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => controller.showLocationSelection(),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  controller.currentLocation,
                                  style: textStyleBody.copyWith(
                                    color: colorWhite,
                                    fontSize: 11,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Icon(
                                Icons.expand_more_rounded,
                                color: colorWhite,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Notification Icon with Badge
                      GetBuilder<NotificationController>(
                        init: Get.isRegistered<NotificationController>()
                            ? Get.find<NotificationController>()
                            : Get.put(NotificationController()),
                        builder: (NotificationController notifController) {
                          return GestureDetector(
                            onTap: () {
                              Get.toNamed(AppRoutes.notification);
                            },
                            child: Stack(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: colorWhite.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.notifications_outlined,
                                    color: colorWhite,
                                    size: 18,
                                  ),
                                ),
                                if (notifController.unreadCount > 0)
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: colorMainTheme,
                                          width: 1.5,
                                        ),
                                      ),
                                      constraints: const BoxConstraints(
                                        minWidth: 14,
                                        minHeight: 14,
                                      ),
                                      child: Text(
                                        notifController.unreadCount > 9
                                            ? '9+'
                                            : '${notifController.unreadCount}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Search Bar - Use StatefulBuilder to maintain state during focus
                  Builder(
                    builder: (context) {
                      return StatefulBuilder(
                        builder: (context, setState) {
                          return Container(
                            key: const ValueKey('search_field'), // Stable key
                            height: 38,
                            decoration: BoxDecoration(
                              color: colorWhite,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextField(
                              key: const ValueKey('search_textfield'),
                              // Stable key for TextField
                              controller: controller.searchController,
                              onChanged: (value) {
                                controller.onSearchChanged(value);
                                setState(
                                  () {},
                                ); // Update suffix icon visibility
                              },
                              onSubmitted: (_) => controller.performSearch(),
                              style: textStyleBody.copyWith(fontSize: 13),
                              decoration: InputDecoration(
                                hintText: 'Search products...',
                                hintStyle: textStyleBody.copyWith(
                                  color: colorGrey,
                                  fontSize: 13,
                                ),
                                prefixIcon: Icon(
                                  Icons.search_rounded,
                                  color: colorGrey,
                                  size: 18,
                                ),
                                suffixIcon:
                                    controller.searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: Icon(
                                          Icons.clear_rounded,
                                          color: colorGrey,
                                          size: 18,
                                        ),
                                        onPressed: () {
                                          controller.searchController.clear();
                                          controller.onSearchChanged('');
                                          controller.performSearch();
                                          setState(() {}); // Update UI
                                        },
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      )
                                    : null,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                isDense: true,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabs(HomeController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _buildTabOption(
            label: 'Renting',
            icon: Icons.receipt_long_rounded,
            isSelected: controller.selectedTab == 'rent',
            onTap: () => controller.setTab('rent'),
          ),
          _buildTabOption(
            label: 'Shopping',
            icon: Icons.shopping_bag_rounded,
            isSelected: controller.selectedTab == 'sell',
            onTap: () => controller.setTab('sell'),
          ),
        ],
      ),
    );
  }

  Widget _buildTabOption({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
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

  Widget _buildItemsListSection(HomeController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: colorMainTheme.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.star_rounded,
                  color: colorMainTheme,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Recommended for you',
                style: textStyleSubHeading.copyWith(fontSize: 16),
              ),
            ],
          ),
        ),
        if (controller.isLoadingProducts && controller.productList.isEmpty)
          const Padding(
            padding: EdgeInsets.all(40),
            child: Center(
              child: CircularProgressIndicator(color: colorMainTheme),
            ),
          )
        else if (controller.hasError && controller.productList.isEmpty)
          Padding(
            padding: const EdgeInsets.all(40),
            child: Center(
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
                    controller.errorMessage ?? 'Failed to load products',
                    style: textStyleBody.copyWith(color: colorGrey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: controller.refreshProducts,
                    style: primaryButtonStyle,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          )
        else if (controller.productList.isEmpty)
          Padding(
            padding: const EdgeInsets.all(40),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_rounded, size: 80, color: colorGrey),
                  const SizedBox(height: 20),
                  Text(
                    'No products found',
                    style: textStyleSubHeading.copyWith(color: colorGrey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try adjusting your search or filters',
                    style: textStyleBody.copyWith(color: colorGrey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.70,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
            ),
            itemCount:
                controller.productList.length +
                (controller.hasNextPage ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == controller.productList.length) {
                // Load more indicator
                if (controller.isLoadingMore) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  // Trigger load more
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    controller.loadMoreProducts();
                  });
                  return const SizedBox.shrink();
                }
              }
              final product = controller.productList[index];
              return _buildProductCard(
                product: product,
                controller: controller,
              );
            },
          ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildProductCard({
    required ProductModel product,
    required HomeController controller,
  }) {
    final hasImage =
        product.imageUrls.isNotEmpty && product.imageUrls[0].isNotEmpty;

    return GestureDetector(
      onTap: () {
        Get.toNamed(
          AppRoutes.productDetail,
          arguments: {'productId': product.id},
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
            // Image with Wishlist Icon
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
                // Wishlist Icon
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () => controller.toggleWishlist(product),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: colorWhite,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        product.isWishlisted
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: product.isWishlisted
                            ? Colors.red.shade600
                            : Colors.grey.shade600,
                        size: 18,
                      ),
                    ),
                  ),
                ),
                // Type Badge
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: product.type == 'rent'
                            ? [Colors.blue.shade600, Colors.blue.shade700]
                            : [Colors.green.shade600, Colors.green.shade700],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color:
                              (product.type == 'rent'
                                      ? Colors.blue
                                      : Colors.green)
                                  .withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      product.type == 'rent' ? 'Rent' : 'Sell',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Product Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
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
                    // Location
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
                    // Price and Distance
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    '₹${product.price.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: colorMainTheme,
                                      height: 1,
                                    ),
                                  ),
                                  if (product.type == 'rent' &&
                                      product.deposit != null) ...[
                                    const SizedBox(width: 6),
                                    Text(
                                      '/day',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              if (product.type == 'rent' &&
                                  product.deposit != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  'Dep: ₹${product.deposit!.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
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

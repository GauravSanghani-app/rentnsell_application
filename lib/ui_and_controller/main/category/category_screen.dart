import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/app_const.dart';
import '../../../utils/theme_manager.dart';
import '../../../config/routes/route_manager.dart';
import '../../../models/category_model.dart';
import '../../../models/product_model.dart';
import 'category_controller.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    Get.put(CategoryController());

    return GetBuilder<CategoryController>(
      builder: (CategoryController controller) {
        return PopScope(
          canPop: controller.selectedCategoryId == null,
          onPopInvoked: (didPop) {
            if (!didPop && controller.selectedCategoryId != null) {
              // If we're viewing products, go back to categories instead of closing app
              controller.clearSelection();
            }
          },
          child: controller.selectedCategoryId != null
              ? _buildProductsView(controller)
              : _buildCategoriesView(controller),
        );
      },
    );
  }

  Widget _buildCategoriesView(CategoryController controller) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorMainTheme,
        elevation: 0,
        title: Text(
          'Categories',
          style: textStyleSubHeading.copyWith(color: colorWhite, fontSize: 20),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: controller.loadCategories,
        color: colorMainTheme,
        child: controller.isLoadingCategories
            ? const Center(
                child: CircularProgressIndicator(color: colorMainTheme),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Horizontal Category Cards (Featured)
                    _buildFeaturedCategories(controller),
                    const SizedBox(height: 16),
                    // Vertical Category List
                    _buildCategoryList(controller),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildFeaturedCategories(CategoryController controller) {
    // Get featured categories (first 4 with images)
    final featuredCategories = controller.categories
        .where((cat) => cat.imageUrl != null)
        .take(4)
        .toList();

    if (featuredCategories.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 200,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: featuredCategories.map((category) {
            return _buildCategoryCard(category, controller);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    CategoryModel category,
    CategoryController controller,
  ) {
    final isExpanded = controller.isCategoryExpanded(category.id);

    return GestureDetector(
      onTap: () => controller.selectCategory(category.id),
      child: Container(
        width: width * 0.7,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Category Image
              if (category.imageUrl != null)
                Image.network(
                  category.imageUrl!,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Suppress 404 errors and show fallback
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            colorMainTheme.withOpacity(0.1),
                            colorMainTheme.withOpacity(0.2),
                          ],
                        ),
                      ),
                      child: Icon(
                        Icons.category_rounded,
                        size: 60,
                        color: colorMainTheme,
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.grey.shade100, Colors.grey.shade200],
                        ),
                      ),
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
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
              else
                // Fallback when no image URL
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorMainTheme.withOpacity(0.1),
                        colorMainTheme.withOpacity(0.2),
                      ],
                    ),
                  ),
                  child: Icon(
                    Icons.category_rounded,
                    size: 60,
                    color: colorMainTheme,
                  ),
                ),
              // Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  ),
                ),
              ),
              // Category Name and Icon
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          category.name.toUpperCase(),
                          style: textStyleSubHeading.copyWith(
                            color: colorWhite,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: colorWhite,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryList(CategoryController controller) {
    final listCategories = controller.categories;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(listCategories.length, (index) {
        final category = listCategories[index];
        final isExpanded = controller.isCategoryExpanded(category.id);
        final subcategories = controller.getSubcategories(category.id);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Category Item
            InkWell(
              onTap: () => controller.toggleCategoryExpansion(category.id),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: colorWhite,
                  border: Border(
                    bottom: BorderSide(color: colorLightGrey, width: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        category.name,
                        style: textStyleBody.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: colorGrey,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
            // Subcategories (if expanded)
            if (isExpanded && subcategories.isNotEmpty)
              Container(
                color: Colors.grey.shade50,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(subcategories.length, (subIndex) {
                    final subcategory = subcategories[subIndex];
                    return InkWell(
                      onTap: () {
                        controller.selectCategory(category.id);
                        controller.selectSubcategory(subcategory.id);
                      },
                      child: Container(
                        padding: const EdgeInsets.only(
                          left: 40,
                          right: 16,
                          top: 12,
                          bottom: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: colorLightGrey,
                              width: 0.3,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                subcategory.name,
                                style: textStyleBody.copyWith(
                                  fontSize: 14,
                                  color: colorGrey,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: colorGrey,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildProductsView(CategoryController controller) {
    final selectedCategory = controller.categories.firstWhereOrNull(
      (cat) => cat.id == controller.selectedCategoryId,
    );
    final selectedSubcategory = controller
        .getSubcategories(controller.selectedCategoryId ?? '')
        .firstWhereOrNull((sub) => sub.id == controller.selectedSubcategoryId);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: colorMainTheme,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colorWhite),
          onPressed: () => controller.clearSelection(),
        ),
        title: Text(
          selectedSubcategory?.name ?? selectedCategory?.name ?? 'Products',
          style: textStyleSubHeading.copyWith(color: colorWhite, fontSize: 20),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          // Type Toggle (Rent/Sell)
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: colorWhite.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypeButton('rent', controller),
                _buildTypeButton('sell', controller),
              ],
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshProducts,
        color: colorMainTheme,
        child: _buildProductsContent(controller),
      ),
    );
  }

  Widget _buildProductsContent(CategoryController controller) {
    if (controller.isLoadingProducts && controller.products.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: colorMainTheme),
      );
    }

    if (controller.hasError && controller.products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, size: 80, color: colorGrey),
              const SizedBox(height: 20),
              Text(
                'Error',
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
      );
    }

    if (controller.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 80, color: colorGrey),
            const SizedBox(height: 20),
            Text(
              'No products found',
              style: textStyleSubHeading.copyWith(color: colorGrey),
            ),
            const SizedBox(height: 8),
            Text(
              'Try selecting a different category',
              style: textStyleBody.copyWith(color: colorGrey),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.70,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
          ),
          itemCount:
              controller.products.length + (controller.hasNextPage ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == controller.products.length) {
              // Load more indicator
              if (controller.hasNextPage) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  controller.loadMoreProducts();
                });
                return Center(
                  child: CircularProgressIndicator(color: colorMainTheme),
                );
              }
              return const SizedBox.shrink();
            }
            final product = controller.products[index];
            return _buildProductCard(product, controller);
          },
        ),
      ),
    );
  }

  Widget _buildTypeButton(String type, CategoryController controller) {
    final isSelected = controller.selectedType == type;
    return GestureDetector(
      onTap: () => controller.setType(type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colorWhite : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          type == 'rent' ? 'Rent' : 'Sell',
          style: textStyleBody.copyWith(
            color: isSelected ? colorMainTheme : colorWhite,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(
    ProductModel product,
    CategoryController controller,
  ) {
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
            // Product Image
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
                    // Price and Deposit
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
                        if (product.type == 'rent') ...[
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
                    if (product.type == 'rent' && product.deposit != null) ...[
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

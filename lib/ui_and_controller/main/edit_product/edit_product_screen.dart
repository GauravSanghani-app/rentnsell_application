import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/app_const.dart';
import '../../../utils/theme_manager.dart';
import '../../../models/attribute_template_model.dart';
import '../../../models/product_model.dart';
import 'edit_product_controller.dart';

/// Edit Product Screen
///
/// Screen for editing products with dynamic attributes
class EditProductScreen extends StatefulWidget {
  final ProductModel product;

  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => EditProductScreenState();
}

class EditProductScreenState extends State<EditProductScreen> {
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _fieldKeys = {};

  @override
  void initState() {
    super.initState();
    // Initialize field keys
    _fieldKeys['title'] = GlobalKey();
    _fieldKeys['category'] = GlobalKey();
    _fieldKeys['subcategory'] = GlobalKey();
    _fieldKeys['rentPrice'] = GlobalKey();
    _fieldKeys['sellPrice'] = GlobalKey();
    _fieldKeys['city'] = GlobalKey();
    _fieldKeys['coordinates'] = GlobalKey();
    _fieldKeys['images'] = GlobalKey();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Scroll to error field
  void scrollToErrorField(String fieldName) {
    final key = _fieldKeys[fieldName];
    if (key?.currentContext != null) {
      // Wait for next frame to ensure widget is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Scrollable.ensureVisible(
          key!.currentContext!,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          alignment: 0.1, // Scroll to show field near top
        );
      });
    }
  }

  /// Register dynamic field key
  void registerDynamicFieldKey(String fieldName, GlobalKey key) {
    _fieldKeys[fieldName] = key;
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    // Register controller with scroll callback
    Get.put(EditProductController(
      product: widget.product,
      onErrorFieldScroll: scrollToErrorField,
    ));

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Edit Product',
          style: textStyleSubHeading.copyWith(color: colorWhite),
        ),
        backgroundColor: colorMainTheme,
        foregroundColor: colorWhite,
        elevation: 0,
      ),
      body: GetBuilder<EditProductController>(
        builder: (EditProductController controller) {
          return SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 20,
              top: 20
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Product Type Info (always show for edit)
                _buildProductTypeInfo(controller),
                const SizedBox(height: 16),

                // Basic Info Section
                _buildBasicInfoSection(controller),
                const SizedBox(height: 16),

                // Category Info Section
                _buildCategoryInfoSection(controller),
                const SizedBox(height: 16),
                // Subcategory Info Section
                _buildSubcategoryInfoSection(controller),
                if (controller.selectedCategoryId != null)
                  const SizedBox(height: 16),

                // Dynamic Attributes Section
                if (controller.selectedSubcategoryId != null)
                  _buildDynamicAttributesSection(controller),
                if (controller.selectedSubcategoryId != null)
                  const SizedBox(height: 16),

                // Both Rent & Sell Checkbox
                _buildBothRentSellCheckbox(controller),
                const SizedBox(height: 16),

                // Pricing Section
                _buildPricingSection(controller),
                const SizedBox(height: 16),

                // Location Section
                _buildLocationSection(controller),
                const SizedBox(height: 16),

                // Images Section
                _buildImagesSection(controller, context),
                const SizedBox(height: 24),

                // Submit Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton(
                    onPressed: controller.isSubmitting
                        ? null
                        : () => controller.updateProduct(),
                    style: primaryButtonStyle.copyWith(
                      minimumSize: MaterialStateProperty.all(
                        const Size(double.infinity, 50),
                      ),
                    ),
                    child: controller.isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            'Update Product',
                            style: textStyleSubHeading.copyWith(
                              color: colorWhite,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Product Type Info (when pre-selected)
  Widget _buildProductTypeInfo(EditProductController controller) {
    final typeLabel = controller.productType == 'rent'
        ? 'Rent'
        : controller.productType == 'sell'
        ? 'Sell'
        : 'Both';
    final typeIcon = controller.productType == 'rent'
        ? Icons.calendar_today_rounded
        : controller.productType == 'sell'
        ? Icons.shopping_bag_rounded
        : Icons.all_inclusive_rounded;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorMainTheme.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorMainTheme, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: colorMainTheme,
              shape: BoxShape.circle,
            ),
            child: Icon(typeIcon, color: colorWhite, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            'Product Type: $typeLabel',
            style: textStyleSubHeading.copyWith(fontSize: 16),
          ),
        ],
      ),
    );
  }

  /// Product Type Section (Rent/Sell/Both)
  Widget _buildProductTypeSection(EditProductController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Product Type',
            style: textStyleSubHeading.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildProductTypeOption(
                  controller,
                  'rent',
                  'Rent',
                  Icons.calendar_today_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildProductTypeOption(
                  controller,
                  'sell',
                  'Sell',
                  Icons.shopping_bag_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildProductTypeOption(
                  controller,
                  'both',
                  'Both',
                  Icons.all_inclusive_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductTypeOption(
    EditProductController controller,
    String type,
    String label,
    IconData icon,
  ) {
    final isSelected = controller.productType == type;
    return GestureDetector(
      onTap: () => controller.setProductType(type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? colorMainTheme.withOpacity(0.1)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? colorMainTheme : Colors.grey.shade300,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? colorMainTheme : Colors.grey.shade600,
              size: 24.0,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? colorMainTheme : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Basic Info Section
  Widget _buildBasicInfoSection(EditProductController controller) {
    return Container(
      key: _fieldKeys['title'],
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Basic Information',
            style: textStyleSubHeading.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 16),
          // Title
          TextField(
            controller: controller.titleController,
            onChanged: (_) => controller.clearFieldError('title'),
            decoration: inputDecoration.copyWith(
              labelText: 'Title *',
              hintText: 'Enter product title',
              errorText: controller.getFieldError('title'),
            ),
            style: textStyleBody,
          ),
          const SizedBox(height: 16),
          // Description
          TextField(
            controller: controller.descriptionController,
            decoration: inputDecoration.copyWith(
              labelText: 'Description',
              hintText: 'Enter product description (optional)',
            ),
            style: textStyleBody,
            maxLines: 4,
            textInputAction: TextInputAction.newline,
          ),
        ],
      ),
    );
  }

  /// Category Info Section
  Widget _buildCategoryInfoSection(EditProductController controller) {
    final hasError = controller.getFieldError('category') != null;
    return Container(
      key: _fieldKeys['category'],
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorMainTheme.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.category_rounded,
                  color: colorMainTheme,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text('Select Category', style: textStyleSubHeading),
            ],
          ),
          const SizedBox(height: 16),
          if (controller.isLoadingCategories)
            const Center(child: CircularProgressIndicator())
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: controller.categories.map((category) {
                final isSelected = controller.selectedCategoryId == category.id;
                return FilterChip(
                  label: Text(category.name),
                  selected: isSelected,
                  onSelected: (_) {
                    controller.selectCategory(category.id);
                    controller.clearFieldError('category');
                  },
                  selectedColor: colorMainTheme.withOpacity(0.15),
                  checkmarkColor: colorMainTheme,
                  labelStyle: TextStyle(
                    color: isSelected ? colorMainTheme : Colors.grey.shade700,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    fontSize: 13,
                  ),
                  side: BorderSide(
                    color: isSelected ? colorMainTheme : Colors.grey.shade300,
                    width: isSelected ? 1.5 : 1,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                );
              }).toList(),
            ),
          if (hasError)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                controller.getFieldError('category') ?? '',
                style: textStyleCaption.copyWith(
                  color: colorRedCalendar,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Subcategory Info Section
  Widget _buildSubcategoryInfoSection(EditProductController controller) {
    if (controller.selectedCategoryId == null) {
      return const SizedBox.shrink();
    }

    final hasError = controller.getFieldError('subcategory') != null;
    return Container(
      key: _fieldKeys['subcategory'],
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorMainTheme.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.subdirectory_arrow_right_rounded,
                  color: colorMainTheme,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text('Select Subcategory', style: textStyleSubHeading),
            ],
          ),
          const SizedBox(height: 16),
          if (controller.isLoadingSubcategories)
            const Center(child: CircularProgressIndicator())
          else if (controller.subcategories.isEmpty)
            Text(
              'No subcategories available',
              style: textStyleBody.copyWith(color: colorGrey),
            )
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: controller.subcategories.map((subcategory) {
                final isSelected =
                    controller.selectedSubcategoryId == subcategory.id;
                return FilterChip(
                  label: Text(subcategory.name),
                  selected: isSelected,
                  onSelected: (_) {
                    controller.selectSubcategory(subcategory.id);
                    controller.clearFieldError('subcategory');
                  },
                  selectedColor: colorMainTheme.withOpacity(0.15),
                  checkmarkColor: colorMainTheme,
                  labelStyle: TextStyle(
                    color: isSelected ? colorMainTheme : Colors.grey.shade700,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    fontSize: 13,
                  ),
                  side: BorderSide(
                    color: isSelected ? colorMainTheme : Colors.grey.shade300,
                    width: isSelected ? 1.5 : 1,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                );
              }).toList(),
            ),
          if (controller.isLoadingAttributeTemplate)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (hasError)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                controller.getFieldError('subcategory') ?? '',
                style: textStyleCaption.copyWith(
                  color: colorRedCalendar,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Dynamic Attributes Section
  Widget _buildDynamicAttributesSection(EditProductController controller) {
    if (controller.isLoadingAttributeTemplate) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorWhite,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (controller.dynamicFields.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Product Attributes',
            style: textStyleSubHeading.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ...controller.dynamicFields.map((field) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildDynamicField(controller, field),
            );
          }),
        ],
      ),
    );
  }

  /// Build Dynamic Field Widget
  Widget _buildDynamicField(
    EditProductController controller,
    AttributeField field,
  ) {
    final controllerField = controller.dynamicFieldControllers[field.fieldName];
    if (controllerField == null) {
      return const SizedBox.shrink();
    }

    final label =
        field.fieldName[0].toUpperCase() +
        field.fieldName.substring(1).replaceAll('_', ' ');
    final isRequired = field.required;
    final isNumber = field.fieldType == 'number';
    final hasError = controller.getFieldError(field.fieldName) != null;
    
    // Register key for dynamic field if it has error
    if (hasError && !_fieldKeys.containsKey(field.fieldName)) {
      _fieldKeys[field.fieldName] = GlobalKey();
    }

    return TextField(
      key: hasError ? _fieldKeys[field.fieldName] : null,
      controller: controllerField,
      decoration: inputDecoration.copyWith(
        labelText: '$label${isRequired ? ' *' : ''}',
        hintText: 'Enter $label',
        errorText: controller.getFieldError(field.fieldName),
      ),
      style: textStyleBody,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      onChanged: (value) {
        controller.updateDynamicFieldValue(field.fieldName, value);
        controller.clearFieldError(field.fieldName);
      },
    );
  }

  /// Both Rent & Sell Checkbox
  Widget _buildBothRentSellCheckbox(EditProductController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Checkbox(
            value: controller.isBothRentSell,
            onChanged: (value) => controller.setBothRentSell(value ?? false),
            activeColor: colorMainTheme,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Also available for both Rent & Sell',
              style: textStyleBody.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Pricing Section
  Widget _buildPricingSection(EditProductController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pricing', style: textStyleSubHeading.copyWith(fontSize: 16)),
          const SizedBox(height: 16),
          // Rent Price
          if (controller.productType == 'rent' ||
              controller.productType == 'both')
            Padding(
              key: _fieldKeys['rentPrice'],
              padding: const EdgeInsets.only(bottom: 16),
              child: TextField(
                controller: controller.rentPriceController,
                onChanged: (_) => controller.clearFieldError('rentPrice'),
                decoration: inputDecoration.copyWith(
                  labelText: 'Rent Price *',
                  hintText: 'Enter rent price',
                  prefixText: '₹ ',
                  errorText: controller.getFieldError('rentPrice'),
                ),
                style: textStyleBody,
                keyboardType: TextInputType.number,
              ),
            ),
          // Sell Price
          if (controller.productType == 'sell' ||
              controller.productType == 'both')
            TextField(
              key: _fieldKeys['sellPrice'],
              controller: controller.sellPriceController,
              onChanged: (_) => controller.clearFieldError('sellPrice'),
              decoration: inputDecoration.copyWith(
                labelText: 'Sell Price *',
                hintText: 'Enter sell price',
                prefixText: '₹ ',
                errorText: controller.getFieldError('sellPrice'),
              ),
              style: textStyleBody,
              keyboardType: TextInputType.number,
            ),
        ],
      ),
    );
  }

  /// Location Section
  Widget _buildLocationSection(EditProductController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Location',
                style: textStyleSubHeading.copyWith(fontSize: 16),
              ),
              const Spacer(),
              if (controller.isGettingLocation)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                IconButton(
                  icon: Icon(Icons.my_location_rounded, color: colorMainTheme),
                  onPressed: () => controller.getCurrentLocation(),
                  tooltip: 'Get current location',
                ),
            ],
          ),
          const SizedBox(height: 16),
          // City
          TextField(
            key: _fieldKeys['city'],
            controller: controller.cityController,
            onChanged: (_) => controller.clearFieldError('city'),
            decoration: inputDecoration.copyWith(
              labelText: 'City *',
              hintText: 'Enter city name',
              errorText: controller.getFieldError('city'),
            ),
            style: textStyleBody,
          ),
          const SizedBox(height: 16),
          // Latitude & Longitude
          Row(
            key: _fieldKeys['coordinates'],
            children: [
              Expanded(
                child: TextField(
                  controller: controller.latitudeController,
                  onChanged: (_) => controller.clearFieldError('coordinates'),
                  decoration: inputDecoration.copyWith(
                    labelText: 'Latitude *',
                    hintText: '0.000000',
                    errorText: controller.getFieldError('coordinates') != null
                        ? 'Invalid coordinates'
                        : null,
                  ),
                  style: textStyleBody,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller.longitudeController,
                  onChanged: (_) => controller.clearFieldError('coordinates'),
                  decoration: inputDecoration.copyWith(
                    labelText: 'Longitude *',
                    hintText: '0.000000',
                  ),
                  style: textStyleBody,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Images Section - Handles both existing (URL) and new (File) images
  Widget _buildImagesSection(
    EditProductController controller,
    BuildContext context,
  ) {
    final hasError = controller.getFieldError('images') != null;
    final totalImages = controller.existingImageUrls.length + controller.newImages.length;
    
    return Container(
      key: _fieldKeys['images'],
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Product Images',
            style: textStyleSubHeading.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 16),
          // Image Grid - Show both existing and new images
          if (totalImages > 0)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1,
              ),
              itemCount: totalImages,
              itemBuilder: (context, index) {
                // Determine if this is an existing image or new image
                final isExisting = index < controller.existingImageUrls.length;
                
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: isExisting
                          ? Image.network(
                              controller.existingImageUrls[index],
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey.shade200,
                                  child: Icon(Icons.broken_image, color: Colors.grey.shade400),
                                );
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: Colors.grey.shade100,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                                loadingProgress.expectedTotalBytes!
                                          : null,
                                      color: colorMainTheme,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                );
                              },
                            )
                          : Image.file(
                              controller.newImages[index - controller.existingImageUrls.length],
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                    ),
                    // Delete/Remove button
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: controller.isDeletingImage
                            ? null
                            : () {
                                if (isExisting) {
                                  // Delete existing image from server
                                  controller.deleteExistingImage(index);
                                } else {
                                  // Remove new image from list
                                  controller.removeNewImage(
                                    index - controller.existingImageUrls.length,
                                  );
                                }
                              },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: controller.isDeletingImage
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          if (totalImages > 0) const SizedBox(height: 12),
          // Upload Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: controller.pickImages,
                  icon: Icon(
                    Icons.photo_library_rounded,
                    color: colorMainTheme,
                  ),
                  label: Text(
                    'Gallery',
                    style: TextStyle(color: colorMainTheme),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: colorMainTheme, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: controller.takeImage,
                  icon: Icon(Icons.camera_alt_rounded, color: colorMainTheme),
                  label: Text(
                    'Camera',
                    style: TextStyle(color: colorMainTheme),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: colorMainTheme, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (hasError)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                controller.getFieldError('images') ?? '',
                style: textStyleCaption.copyWith(
                  color: colorRedCalendar,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

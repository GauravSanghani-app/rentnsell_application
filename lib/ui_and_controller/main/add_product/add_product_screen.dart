import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/app_const.dart';
import '../../../utils/theme_manager.dart';
import '../../../models/attribute_template_model.dart';
import 'add_product_controller.dart';

class AddProductScreen extends StatefulWidget {
  final String productType;

  const AddProductScreen({super.key, this.productType = 'rent'});

  @override
  State<AddProductScreen> createState() => AddProductScreenState();
}

class AddProductScreenState extends State<AddProductScreen> {
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _fieldKeys = {};

  @override
  void initState() {
    super.initState();
    _fieldKeys['title'] = GlobalKey();
    _fieldKeys['category'] = GlobalKey();
    _fieldKeys['subcategory'] = GlobalKey();
    _fieldKeys['rentPrice'] = GlobalKey();
    _fieldKeys['sellPrice'] = GlobalKey();
    _fieldKeys['location'] = GlobalKey();
    _fieldKeys['images'] = GlobalKey();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void scrollToErrorField(String fieldName) {
    final key = _fieldKeys[fieldName];
    if (key?.currentContext != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Scrollable.ensureVisible(
          key!.currentContext!,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          alignment: 0.1,
        );
      });
    }
  }

  void registerDynamicFieldKey(String fieldName, GlobalKey key) {
    _fieldKeys[fieldName] = key;
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    Get.put(
      AddProductController(
        initialProductType: widget.productType,
        onErrorFieldScroll: scrollToErrorField,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          widget.productType == 'sell'
              ? 'Sell Product'
              : widget.productType == 'rent'
              ? 'Rent Product'
              : 'Add Product',
          style: textStyleSubHeading.copyWith(color: colorWhite),
        ),
        backgroundColor: colorMainTheme,
        foregroundColor: colorWhite,
        elevation: 0,
      ),
      body: GetBuilder<AddProductController>(
        builder: (AddProductController controller) {
          return SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 20,
              top: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.productType == 'both' || widget.productType.isEmpty)
                  _buildProductTypeSection(controller),
                if (widget.productType == 'both' || widget.productType.isEmpty)
                  const SizedBox(height: 16),
                if (widget.productType != 'both' &&
                    widget.productType.isNotEmpty)
                  _buildProductTypeInfo(controller),
                if (widget.productType != 'both' &&
                    widget.productType.isNotEmpty)
                  const SizedBox(height: 16),
                _buildBasicInfoSection(controller),
                const SizedBox(height: 16),
                _buildCategoryInfoSection(controller),
                const SizedBox(height: 16),
                _buildSubcategoryInfoSection(controller),
                if (controller.selectedCategoryId != null)
                  const SizedBox(height: 16),
                if (controller.selectedSubcategoryId != null)
                  _buildDynamicAttributesSection(controller),
                if (controller.selectedSubcategoryId != null)
                  const SizedBox(height: 16),
                if (widget.productType != 'both')
                  _buildBothRentSellCheckbox(controller),
                if (widget.productType != 'both') const SizedBox(height: 16),
                _buildPricingSection(controller),
                const SizedBox(height: 16),
                _buildLocationSection(controller),
                const SizedBox(height: 16),
                _buildImagesSection(controller, context),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton(
                    onPressed: controller.isSubmitting
                        ? null
                        : () => controller.submitProduct(),
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
                            'Submit Product',
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

  Widget _buildProductTypeInfo(AddProductController controller) {
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
  Widget _buildProductTypeSection(AddProductController controller) {
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
    AddProductController controller,
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
  Widget _buildBasicInfoSection(AddProductController controller) {
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
  Widget _buildCategoryInfoSection(AddProductController controller) {
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
  Widget _buildSubcategoryInfoSection(AddProductController controller) {
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
  Widget _buildDynamicAttributesSection(AddProductController controller) {
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
    AddProductController controller,
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
  Widget _buildBothRentSellCheckbox(AddProductController controller) {
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
  Widget _buildPricingSection(AddProductController controller) {
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
  Widget _buildLocationSection(AddProductController controller) {
    final hasError = controller.getFieldError('location') != null;
    return Container(
      key: _fieldKeys['location'],
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
              if (controller.isLoadingLocation)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                IconButton(
                  icon: Icon(Icons.search_rounded, color: colorMainTheme),
                  onPressed: () => controller.showLocationSelection(),
                  tooltip: 'Search location',
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Location Selection Field
          InkWell(
            onTap: () => controller.showLocationSelection(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: hasError
                      ? colorRedCalendar
                      : (controller.selectedLocationName != null
                            ? colorMainTheme.withOpacity(0.3)
                            : Colors.grey.shade300),
                  width: hasError ? 1.5 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
                color: controller.selectedLocationName != null
                    ? colorMainTheme.withOpacity(0.05)
                    : Colors.transparent,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    color: controller.selectedLocationName != null
                        ? colorMainTheme
                        : colorGrey,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.selectedLocationName ??
                              'Select Location *',
                          style: textStyleBody.copyWith(
                            color: controller.selectedLocationName != null
                                ? Colors.grey.shade900
                                : colorGrey,
                            fontWeight: controller.selectedLocationName != null
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                        ),
                        if (controller.selectedLocationName == null)
                          Text(
                            'Tap to search and select',
                            style: textStyleCaption.copyWith(
                              color: colorGrey,
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: colorGrey, size: 20),
                ],
              ),
            ),
          ),
          if (hasError)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                controller.getFieldError('location') ?? '',
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

  /// Images Section
  Widget _buildImagesSection(
    AddProductController controller,
    BuildContext context,
  ) {
    final hasError = controller.getFieldError('images') != null;
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
          // Image Grid
          if (controller.selectedImages.isNotEmpty)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1,
              ),
              itemCount: controller.selectedImages.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        controller.selectedImages[index],
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => controller.removeImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
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
          const SizedBox(height: 12),
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

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'services/product_service.dart';
import 'widgets/top_header.dart';

class AddProductPage extends StatefulWidget {
  final Product? product; // Optional product for edit mode
  const AddProductPage({super.key, this.product});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _productService = ProductService();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _locationController;
  
  String _selectedCategory = 'Vegetable';
  final List<String> _categories = ['Vegetable', 'Fruit', 'Grain', 'Seeds', 'Fertilizer', 'Tools'];
  
  File? _imageFile;
  String? _existingImageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _priceController = TextEditingController(text: widget.product?.price.toString() ?? '');
    _locationController = TextEditingController(text: widget.product?.location ?? 'Savar, Dhaka');
    
    if (widget.product != null) {
      _selectedCategory = widget.product!.category;
      _existingImageUrl = widget.product!.imageUrl;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _submit() async {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty || (_imageFile == null && _existingImageUrl == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and select an image'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String imageUrl = _existingImageUrl ?? '';

      // 1. Upload new image if selected
      if (_imageFile != null) {
        imageUrl = await _productService.uploadProductImage(_imageFile!);
      }
      
      // 2. Add or Update Product
      if (widget.product == null) {
        await _productService.addProduct(
          name: _nameController.text.trim(),
          price: double.parse(_priceController.text.trim()),
          imageUrl: imageUrl,
          category: _selectedCategory,
          location: _locationController.text.trim(),
        );
      } else {
        await _productService.updateProduct(
          id: widget.product!.id,
          name: _nameController.text.trim(),
          price: double.parse(_priceController.text.trim()),
          imageUrl: imageUrl,
          category: _selectedCategory,
          location: _locationController.text.trim(),
        );
      }

      if (mounted) {
        Navigator.pop(context, true); // Return true to signal refresh
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE3F2FD), Color(0xFFF5F5F5)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              TopHeader(title: widget.product == null ? 'Add New Crop' : 'Edit Crop'),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Picker Container
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.black.withOpacity(0.05)),
                            image: _imageFile != null
                                ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                                : _existingImageUrl != null
                                    ? DecorationImage(image: NetworkImage(_existingImageUrl!), fit: BoxFit.cover)
                                    : null,
                          ),
                          child: _imageFile == null && _existingImageUrl == null
                              ? const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo_outlined, size: 48, color: Colors.orangeAccent),
                                    SizedBox(height: 8),
                                    Text('Tap to Add Photo', style: TextStyle(color: Colors.black26)),
                                  ],
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildLabel('Product Name'),
                      _buildTextField(_nameController, 'e.g. Organic Tomato'),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Price (৳)'),
                                _buildTextField(_priceController, '0.00', keyboardType: TextInputType.number),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Category'),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.black.withOpacity(0.1)),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedCategory,
                                      isExpanded: true,
                                      items: _categories.map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value, style: const TextStyle(fontSize: 14)),
                                        );
                                      }).toList(),
                                      onChanged: (newValue) {
                                        setState(() => _selectedCategory = newValue!);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('Location'),
                      _buildTextField(_locationController, 'e.g. Savar, Dhaka'),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orangeAccent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  widget.product == null ? 'List Product' : 'Save Changes',
                                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                        ),
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF455A64))),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black12),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.black.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.orangeAccent, width: 2),
        ),
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'services/post_service.dart';
import 'widgets/top_header.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final _contentController = TextEditingController();
  final _postService = PostService();
  final _imagePicker = ImagePicker();
  
  File? _selectedImage;
  bool _isSubmitting = false;

  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _submitPost() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter some content for your post')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await _postService.uploadPostImage(_selectedImage!);
      }

      await _postService.addPost(
        content: _contentController.text.trim(),
        imageUrl: imageUrl,
      );

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating post: $e')),
        );
      }
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            TopHeader(
              title: 'Add Update',
              showBackButton: true,
              trailing: _isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.green),
                    )
                  : TextButton(
                      onPressed: _submitPost,
                      child: const Text('Post', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Content Input
                    TextField(
                      controller: _contentController,
                      maxLines: 10,
                      decoration: const InputDecoration(
                        hintText: "What's happening on your farm?",
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                    const SizedBox(height: 24),
                    
                    // Image Preview/Selector
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey[300]!, width: 1),
                        ),
                        child: _selectedImage != null
                            ? Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.file(
                                      _selectedImage!,
                                      width: double.infinity,
                                      height: 200,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: GestureDetector(
                                      onTap: () => setState(() => _selectedImage = null),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                        child: const Icon(Icons.close, color: Colors.white, size: 20),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.grey[400]),
                                  const SizedBox(height: 8),
                                  Text('Add Photo', style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w500)),
                                ],
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
    );
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }
}

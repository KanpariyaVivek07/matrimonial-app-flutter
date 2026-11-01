import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _educationController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _hobbiesController = TextEditingController();

  bool _isEditMode = false;
  File? _profileImage;
  Uint8List? _webImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _nameController.text = prefs.getString('name') ?? 'Your Name';
      _ageController.text = prefs.getString('age') ?? 'Age';
      _cityController.text = prefs.getString('city') ?? 'City';
      _educationController.text = prefs.getString('education') ?? 'Education';
      _bioController.text = prefs.getString('bio') ?? 'Tell us about yourself';
      _hobbiesController.text = prefs.getString('hobbies') ?? 'Your hobbies and interests';

      final imagePath = prefs.getString('image_path');
      final imageBase64 = prefs.getString('image_base64');

      if (!kIsWeb && imagePath != null) {
        _profileImage = File(imagePath);
      } else if (kIsWeb && imageBase64 != null) {
        _webImage = base64Decode(imageBase64);
      }
      _isLoading = false;
    });
  }

  Future<void> _pickImage() async {
    if (!_isEditMode) return;

    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (picked != null) {
        setState(() => _isLoading = true);
        final prefs = await SharedPreferences.getInstance();

        if (kIsWeb) {
          final bytes = await picked.readAsBytes();
          setState(() => _webImage = bytes);
          await prefs.setString('image_base64', base64Encode(bytes));
        } else {
          setState(() => _profileImage = File(picked.path));
          await prefs.setString('image_path', picked.path);
        }
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackbar("Failed to pick image: ${e.toString()}");
    }
  }

  void _toggleEditMode() {
    setState(() => _isEditMode = !_isEditMode);
  }

  Future<void> _saveProfile() async {
    if (!_validateFields()) return;

    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.setString('name', _nameController.text),
        prefs.setString('age', _ageController.text),
        prefs.setString('city', _cityController.text),
        prefs.setString('education', _educationController.text),
        prefs.setString('bio', _bioController.text),
        prefs.setString('hobbies', _hobbiesController.text),
      ]);

      setState(() => _isEditMode = false);
      _showSuccessSnackbar("Profile updated successfully!");
    } catch (e) {
      _showErrorSnackbar("Failed to save profile: ${e.toString()}");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  bool _validateFields() {
    if (_nameController.text.isEmpty) {
      _showErrorSnackbar("Please enter your name");
      return false;
    }
    if (_ageController.text.isEmpty || int.tryParse(_ageController.text) == null) {
      _showErrorSnackbar("Please enter a valid age");
      return false;
    }
    return true;
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 10),
            Text(message),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    int? maxLines,
    TextInputType? keyboardType,
  }) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: Colors.deepPurple),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
    );
    }

  Widget _buildProfileRow({required String label, required String value, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.deepPurple),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                child: Text(value, style: const TextStyle(fontSize: 15)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final photo = _webImage != null
        ? MemoryImage(_webImage!)
        : _profileImage != null
        ? FileImage(_profileImage!)
        : const AssetImage("assets/image/default_profile.png") as ImageProvider;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: Icon(_isEditMode ? Icons.save : Icons.edit, color: Colors.white),
            onPressed: _isEditMode ? _saveProfile : _toggleEditMode,
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: photo,
                  ),
                  if (_isEditMode)
                    const Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.deepPurple,
                        child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _isEditMode
                ? Column(
              children: [
                _buildEditableField(
                  label: "Name",
                  controller: _nameController,
                  icon: Icons.person,
                ),
                _buildEditableField(
                  label: "Age",
                  controller: _ageController,
                  icon: Icons.cake,
                  keyboardType: TextInputType.number,
                ),
                _buildEditableField(
                  label: "City",
                  controller: _cityController,
                  icon: Icons.location_city,
                ),
                _buildEditableField(
                  label: "Education",
                  controller: _educationController,
                  icon: Icons.school,
                ),
                _buildEditableField(
                  label: "Bio",
                  controller: _bioController,
                  icon: Icons.info_outline,
                  maxLines: 3,
                ),
                _buildEditableField(
                  label: "Hobbies & Interests",
                  controller: _hobbiesController,
                  icon: Icons.favorite,
                  maxLines: 3,
                ),
              ],
            )
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileRow(label: "Name", value: _nameController.text, icon: Icons.person),
                _buildProfileRow(label: "Age", value: _ageController.text, icon: Icons.cake),
                _buildProfileRow(label: "City", value: _cityController.text, icon: Icons.location_city),
                _buildProfileRow(label: "Education", value: _educationController.text, icon: Icons.school),
                const Divider(height: 30),
                _buildProfileRow(label: "About Me", value: _bioController.text, icon: Icons.info_outline),
                const SizedBox(height: 16),
                _buildProfileRow(label: "Hobbies & Interests", value: _hobbiesController.text, icon: Icons.favorite),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
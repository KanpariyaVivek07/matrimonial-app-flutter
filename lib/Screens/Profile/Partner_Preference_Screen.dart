import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PartnerPreferenceScreen extends StatefulWidget {
  const PartnerPreferenceScreen({super.key});

  @override
  State<PartnerPreferenceScreen> createState() => _PartnerPreferenceScreenState();
}

class _PartnerPreferenceScreenState extends State<PartnerPreferenceScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _minAgeCtrl = TextEditingController();
  final _maxAgeCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _educationCtrl = TextEditingController();
  final _hobbiesCtrl = TextEditingController();
  String? _selectedGender;
  String? _selectedReligion;
  bool _genderError = false;
  bool _religionError = false;

  late AnimationController _controller;
  late Animation<double> _fadeInAnim;
  bool _isLoading = false;

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _religions = ['Christian', 'Muslim', 'Hindu', 'Buddhist', 'Other'];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeInAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _minAgeCtrl.text = prefs.getString('pref_min_age') ?? '';
      _maxAgeCtrl.text = prefs.getString('pref_max_age') ?? '';
      _locationCtrl.text = prefs.getString('pref_location') ?? '';
      _educationCtrl.text = prefs.getString('pref_education') ?? '';
      _hobbiesCtrl.text = prefs.getString('pref_hobbies') ?? '';
      _selectedGender = prefs.getString('pref_gender');
      _selectedReligion = prefs.getString('pref_religion');
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _minAgeCtrl.dispose();
    _maxAgeCtrl.dispose();
    _locationCtrl.dispose();
    _educationCtrl.dispose();
    _hobbiesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitPreference() async {
    // Reset errors
    setState(() {
      _genderError = _selectedGender == null;
      _religionError = _selectedReligion == null;
    });

    if (!_formKey.currentState!.validate() || _genderError || _religionError) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.setString('pref_min_age', _minAgeCtrl.text),
        prefs.setString('pref_max_age', _maxAgeCtrl.text),
        prefs.setString('pref_location', _locationCtrl.text),
        prefs.setString('pref_education', _educationCtrl.text),
        prefs.setString('pref_hobbies', _hobbiesCtrl.text),
        prefs.setString('pref_gender', _selectedGender!),
        prefs.setString('pref_religion', _selectedReligion!),
      ]);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Preferences saved successfully"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Future.delayed(const Duration(milliseconds: 800), () {
        Navigator.pushReplacementNamed(context, '/home');
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error saving preferences: ${e.toString()}"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildGenderRadioButtons() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Preferred Gender",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          if (_genderError)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                "Please select a gender",
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          const SizedBox(height: 8),
          Row(
            children: _genders.map((gender) {
              return Expanded(
                child: RadioListTile<String>(
                  title: Text(gender),
                  value: gender,
                  groupValue: _selectedGender,
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                      _genderError = false;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildReligionDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Preferred Religion",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          if (_religionError)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                "Please select a religion",
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          DropdownButtonFormField<String>(
            value: _selectedReligion,
            hint: const Text("Select religion"),
            items: _religions.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedReligion = value;
                _religionError = false;
              });
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              errorText: _religionError ? ' ' : null, // Space for error message
            ),
            validator: (value) => value == null ? '' : null, // Empty string to prevent default error
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FadeTransition(
        opacity: _fadeInAnim,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFEC4899), Color(0xFF8B5CF6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 24),
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.deepPurple, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.deepPurple.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              "assets/image/prefrence.png",
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const Text(
                        "Your Partner Preferences",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A148C),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildGenderRadioButtons(),
                            _buildReligionDropdown(),
                            TextFormField(
                              controller: _minAgeCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: "Minimum Age",
                                prefixIcon: Icon(Icons.exposure_minus_1),
                                border: OutlineInputBorder(),
                              ),
                              validator: (val) {
                                if (val == null || val.isEmpty) return "Required";
                                final age = int.tryParse(val);
                                if (age == null || age < 18 || age > 100) return "Enter valid age (18-100)";
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _maxAgeCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: "Maximum Age",
                                prefixIcon: Icon(Icons.exposure_plus_1),
                                border: OutlineInputBorder(),
                              ),
                              validator: (val) {
                                if (val == null || val.isEmpty) return "Required";
                                final age = int.tryParse(val);
                                if (age == null || age < 18 || age > 100) return "Enter valid age (18-100)";
                                if (_minAgeCtrl.text.isNotEmpty && age < int.parse(_minAgeCtrl.text)) {
                                  return "Max age must be ≥ min age";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _locationCtrl,
                              decoration: const InputDecoration(
                                labelText: "Preferred Location",
                                prefixIcon: Icon(Icons.location_on),
                                border: OutlineInputBorder(),
                              ),
                              validator: (val) => val == null || val.isEmpty ? "Required" : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _educationCtrl,
                              decoration: const InputDecoration(
                                labelText: "Preferred Education",
                                prefixIcon: Icon(Icons.school),
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _hobbiesCtrl,
                              decoration: const InputDecoration(
                                labelText: "Preferred Hobbies/Interests",
                                prefixIcon: Icon(Icons.favorite),
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 2,
                            ),
                            const SizedBox(height: 30),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.check, color: Colors.white),
                              label: const Text("Save Preferences", style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(50),
                                backgroundColor: Colors.deepPurple,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              ),
                              onPressed: _submitPreference,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
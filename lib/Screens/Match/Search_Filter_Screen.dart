import 'package:flutter/material.dart';

class SearchFilterScreen extends StatefulWidget {
  const SearchFilterScreen({super.key});

  @override
  State<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _controller;
  late Animation<double> _fadeInAnim;

  RangeValues _ageRange = const RangeValues(20, 35);
  String? selectedCity;
  String? selectedEducation;
  String? selectedGender;
  double _distance = 50;
  bool _hasPhotosOnly = true;
  bool _isOnline = false;
  List<String> _selectedHobbies = [];

  final List<String> hobbies = [
    'Reading', 'Traveling', 'Cooking', 'Photography',
    'Music', 'Sports', 'Dancing', 'Painting', 'Gardening'
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeInAnim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _resetFilters() {
    setState(() {
      _ageRange = const RangeValues(20, 35);
      selectedCity = null;
      selectedEducation = null;
      selectedGender = null;
      _distance = 50;
      _hasPhotosOnly = true;
      _isOnline = false;
      _selectedHobbies.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Filters reset to default"),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }

  void _toggleHobby(String hobby) {
    setState(() {
      if (_selectedHobbies.contains(hobby)) {
        _selectedHobbies.remove(hobby);
      } else {
        _selectedHobbies.add(hobby);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cities = ['Ahmedabad', 'Surat', 'Rajkot', 'Vadodara', 'Bhavnagar', 'Jamnagar'];
    final educations = ['BCA', 'MBA', 'Engineer', 'Doctor', 'CA', 'Pharmacist', 'Any'];
    final genders = ['Male', 'Female', 'Any'];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Filter", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt, color: Colors.white),
            onPressed: _resetFilters,
            tooltip: 'Reset filters',
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeInAnim,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Preferred Age Range",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        RangeSlider(
                          values: _ageRange,
                          min: 18,
                          max: 50,
                          divisions: 32,
                          activeColor: Colors.deepPurple,
                          labels: RangeLabels(
                            _ageRange.start.round().toString(),
                            _ageRange.end.round().toString(),
                          ),
                          onChanged: (values) => setState(() => _ageRange = values),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("${_ageRange.start.round()} years"),
                            Text("${_ageRange.end.round()} years"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Maximum Distance (km)",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Slider(
                          value: _distance,
                          min: 10,
                          max: 100,
                          divisions: 9,
                          activeColor: Colors.deepPurple,
                          label: _distance.round().toString(),
                          onChanged: (value) => setState(() => _distance = value),
                        ),
                        Text("${_distance.round()} km", textAlign: TextAlign.end),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Basic Filters",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: selectedGender,
                          items: genders.map((gender) => DropdownMenuItem(
                            value: gender,
                            child: Text(gender),
                          )).toList(),
                          decoration: const InputDecoration(
                            labelText: "Preferred Gender",
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          onChanged: (value) => setState(() => selectedGender = value),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: selectedCity,
                          items: cities.map((city) => DropdownMenuItem(
                            value: city,
                            child: Text(city),
                          )).toList(),
                          decoration: const InputDecoration(
                            labelText: "Preferred City",
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          onChanged: (value) => setState(() => selectedCity = value),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: selectedEducation,
                          items: educations.map((edu) => DropdownMenuItem(
                            value: edu,
                            child: Text(edu),
                          )).toList(),
                          decoration: const InputDecoration(
                            labelText: "Preferred Education",
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          onChanged: (value) => setState(() => selectedEducation = value),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Hobbies & Interests",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: hobbies.map((hobby) => FilterChip(
                            label: Text(hobby),
                            selected: _selectedHobbies.contains(hobby),
                            selectedColor: Colors.deepPurple.shade300,
                            checkmarkColor: Colors.white,
                            onSelected: (_) => _toggleHobby(hobby),
                          )).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: const Text("Only show profiles with photos"),
                          activeColor: Colors.deepPurple,
                          value: _hasPhotosOnly,
                          onChanged: (value) => setState(() => _hasPhotosOnly = value),
                        ),
                        SwitchListTile(
                          title: const Text("Show online users only"),
                          activeColor: Colors.deepPurple,
                          value: _isOnline,
                          onChanged: (value) => setState(() => _isOnline = value),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _resetFilters,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.deepPurple,
                          side: const BorderSide(color: Colors.deepPurple),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text("Reset"),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // Apply filters logic here
                            final filters = {
                              'minAge': _ageRange.start.round(),
                              'maxAge': _ageRange.end.round(),
                              'city': selectedCity,
                              'education': selectedEducation,
                              'gender': selectedGender,
                              'distance': _distance.round(),
                              'hasPhotos': _hasPhotosOnly,
                              'isOnline': _isOnline,
                              'hobbies': _selectedHobbies,
                            };

                            Navigator.pop(context, filters);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Filters applied successfully"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text("Apply Filters"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
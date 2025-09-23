import 'package:flutter/material.dart';
import 'dashboard.dart';

class ItineraryEntry {
  TextEditingController placeController = TextEditingController();
  DateTime? arrivalDate;
  DateTime? departureDate;
  TextEditingController hotelController = TextEditingController();
}

class EmergencyContact {
  TextEditingController nameController = TextEditingController();
  TextEditingController relationController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
}

// Simple model for passing contact info
class SimpleEmergencyContact {
  final String name;
  final String phone;
  final String relation;
  SimpleEmergencyContact({required this.name, required this.phone, required this.relation});
}

class SinglePageRegistration extends StatefulWidget {
  final void Function(String userName, List<String> itinerary) onRegistered;

  const SinglePageRegistration({super.key, required this.onRegistered});

  @override
  State<SinglePageRegistration> createState() => _SinglePageRegistrationState();
}

class _SinglePageRegistrationState extends State<SinglePageRegistration> {
  final ScrollController _scrollController = ScrollController();

  int _currentStep = 0;
  final int totalSteps = 5;

  final List<GlobalKey> _sectionKeys = List.generate(5, (_) => GlobalKey());
  final List<GlobalKey<FormState>> _formKeys = List.generate(5, (_) => GlobalKey<FormState>());

  final TextEditingController aadhaarController = TextEditingController();
  final TextEditingController passportController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController nationalityController = TextEditingController();
  String? gender;
  final TextEditingController ageController = TextEditingController();

  List<ItineraryEntry> itineraries = [ItineraryEntry()];
  List<EmergencyContact> emergencyContacts = [EmergencyContact()];

  final TextEditingController allergiesController = TextEditingController();
  final TextEditingController medicalConditionController = TextEditingController();

  String? selectedLanguage;
  bool privacyConsent = false;
  bool locationConsent = false;
  final List<String> languages = ['English', 'Hindi', 'Bengali', 'Tamil', 'Telugu', 'Kannada'];

  @override
  void dispose() {
    _scrollController.dispose();

    aadhaarController.dispose();
    passportController.dispose();
    nameController.dispose();
    nationalityController.dispose();
    ageController.dispose();

    for (var itinerary in itineraries) {
      itinerary.placeController.dispose();
      itinerary.hotelController.dispose();
    }
    for (var contact in emergencyContacts) {
      contact.nameController.dispose();
      contact.relationController.dispose();
      contact.phoneController.dispose();
    }

    allergiesController.dispose();
    medicalConditionController.dispose();
    super.dispose();
  }

  Future<void> pickDate(BuildContext context, bool isArrival, ItineraryEntry entry) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isArrival) {
          entry.arrivalDate = picked;
        } else {
          entry.departureDate = picked;
        }
      });
    }
  }

  void scrollToSection(int index) {
    final context = _sectionKeys[index].currentContext;
    if (context != null) {
      Scrollable.ensureVisible(context, duration: const Duration(milliseconds: 500), alignment: 0.1);
    }
  }

  void onNext() {
    if (_formKeys[_currentStep].currentState?.validate() ?? false) {
      if (_currentStep < totalSteps - 1) {
        setState(() {
          _currentStep++;
        });
        scrollToSection(_currentStep);
      }
    }
  }

  void onBack() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      scrollToSection(_currentStep);
    }
  }

  void onRegister() {
    if (!_formKeys[_currentStep].currentState!.validate()) return;
    if (!privacyConsent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the privacy policy')),
      );
      return;
    }

    // Convert emergencyContacts to list of simple objects for passing
    final simpleContacts = emergencyContacts.map((ec) => SimpleEmergencyContact(
      name: ec.nameController.text.trim(),
      phone: ec.phoneController.text.trim(),
      relation: ec.relationController.text.trim(),
    )).toList();

    Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => DashboardPage(
            userName: nameController.text.trim(),
            emergencyContacts: simpleContacts, userItinerary: [],
          ),
        ));
        // Call the onRegistered callback with name and itinerary list

  }

  Widget buildStepIndicator(int step) {
    bool completed = step < _currentStep;
    bool active = step == _currentStep;

    Color color = completed ? Colors.green : (active ? Colors.blue : Colors.grey);

    return Column(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: color,
          child: Text(
            '${step + 1}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        if (step != totalSteps - 1)
          Container(
            height: 40,
            width: 4,
            color: completed ? Colors.green : Colors.grey.shade400,
          ),
      ],
    );
  }

  Widget buildItinerarySection() {
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: itineraries.length,
          itemBuilder: (context, index) {
            final itinerary = itineraries[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Itinerary ${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold)),
                    TextFormField(
                      controller: itinerary.placeController,
                      decoration: const InputDecoration(labelText: 'Place to Visit'),
                      validator: (v) => v == null || v.isEmpty ? 'Enter place' : null,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(itinerary.arrivalDate == null ? 'Arrival Date' : itinerary.arrivalDate!.toLocal().toString().split(' ')[0]),
                            trailing: const Icon(Icons.calendar_today),
                            onTap: () => pickDate(context, true, itinerary),
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(itinerary.departureDate == null ? 'Departure Date' : itinerary.departureDate!.toLocal().toString().split(' ')[0]),
                            trailing: const Icon(Icons.calendar_today),
                            onTap: () => pickDate(context, false, itinerary),
                          ),
                        ),
                      ],
                    ),
                    TextFormField(
                      controller: itinerary.hotelController,
                      decoration: const InputDecoration(labelText: 'Hotel/Hostel Address'),
                      validator: (v) => v == null || v.isEmpty ? 'Enter hotel address' : null,
                    ),
                    if (index != 0)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              itineraries.removeAt(index);
                            });
                          },
                          child: const Text(
                            'Remove Itinerary',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              itineraries.add(ItineraryEntry());
            });
          },
          child: const Text('Add More Itineraries'),
        )
      ],
    );
  }

  Widget buildEmergencyContactsSection() {
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: emergencyContacts.length,
          itemBuilder: (context, index) {
            final contact = emergencyContacts[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Contact ${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold)),
                    TextFormField(
                      controller: contact.nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: (v) => v == null || v.isEmpty ? 'Enter name' : null,
                    ),
                    TextFormField(
                      controller: contact.relationController,
                      decoration: const InputDecoration(labelText: 'Relation'),
                      validator: (v) => v == null || v.isEmpty ? 'Enter relation' : null,
                    ),
                    TextFormField(
                      controller: contact.phoneController,
                      decoration: const InputDecoration(labelText: 'Phone Number'),
                      keyboardType: TextInputType.phone,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter phone number';
                        if (v.length < 10) return 'Phone number must be at least 10 digits';
                        return null;
                      },
                    ),
                    if (index != 0)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              emergencyContacts.removeAt(index);
                            });
                          },
                          child: const Text(
                            'Remove Contact',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              emergencyContacts.add(EmergencyContact());
            });
          },
          child: const Text('Add More Contacts'),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/image.jpeg', fit: BoxFit.cover),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(totalSteps, buildStepIndicator),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // KYC Section
                          Container(
                            key: _sectionKeys[0],
                            padding: const EdgeInsets.only(bottom: 30),
                            child: Form(
                              key: _formKeys[0],
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('KYC Details',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                  const SizedBox(height: 10),
                                  TextFormField(
                                    controller: aadhaarController,
                                    maxLength: 12,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(labelText: 'Aadhaar Number'),
                                    validator: (v) {
                                      if (v == null || v.length != 12) return 'Enter valid 12 digit Aadhaar';
                                      return null;
                                    },
                                  ),
                                  TextFormField(
                                    controller: passportController,
                                    decoration: const InputDecoration(labelText: 'Passport Number (Optional)'),
                                  ),
                                  TextFormField(
                                    controller: nameController,
                                    decoration: const InputDecoration(labelText: 'Full Name'),
                                    validator: (v) => v == null || v.isEmpty ? 'Enter your name' : null,
                                  ),
                                  TextFormField(
                                    controller: nationalityController,
                                    decoration: const InputDecoration(labelText: 'Nationality'),
                                    validator: (v) => v == null || v.isEmpty ? 'Enter your nationality' : null,
                                  ),
                                  DropdownButtonFormField<String>(
                                    decoration: const InputDecoration(labelText: 'Gender'),
                                    value: gender,
                                    items: const [
                                      DropdownMenuItem(child: Text('Male'), value: 'Male'),
                                      DropdownMenuItem(child: Text('Female'), value: 'Female'),
                                      DropdownMenuItem(child: Text('Other'), value: 'Other'),
                                    ],
                                    onChanged: (v) => setState(() => gender = v),
                                    validator: (v) => v == null ? 'Select gender' : null,
                                  ),
                                  TextFormField(
                                    controller: ageController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(labelText: 'Age'),
                                    validator: (v) {
                                      final ageInt = int.tryParse(v ?? "");
                                      if (v == null || v.isEmpty) return 'Enter your age';
                                      if (ageInt == null || ageInt < 1 || ageInt > 120) return 'Age must be 1-120';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      if (_currentStep > 0)
                                        ElevatedButton(
                                          onPressed: onBack,
                                          child: const Text('Back'),
                                        ),
                                      const Spacer(),
                                      if (_currentStep < totalSteps - 1)
                                        ElevatedButton(
                                          onPressed: onNext,
                                          child: const Text('Next'),
                                        ),
                                      if (_currentStep == totalSteps - 1)
                                        ElevatedButton(
                                          onPressed: onRegister,
                                          child: const Text('Register'),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Itinerary Section
                          Container(
                            key: _sectionKeys[1],
                            padding: const EdgeInsets.only(bottom: 30),
                            child: Form(
                              key: _formKeys[1],
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Trip Itinerary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                  const SizedBox(height: 10),
                                  buildItinerarySection(),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      if (_currentStep > 0)
                                        ElevatedButton(
                                          onPressed: onBack,
                                          child: const Text('Back'),
                                        ),
                                      const Spacer(),
                                      if (_currentStep < totalSteps - 1)
                                        ElevatedButton(
                                          onPressed: onNext,
                                          child: const Text('Next'),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Emergency Contact Section
                          Container(
                            key: _sectionKeys[2],
                            padding: const EdgeInsets.only(bottom: 30),
                            child: Form(
                              key: _formKeys[2],
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Emergency Contact', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                  const SizedBox(height: 10),
                                  buildEmergencyContactsSection(),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      if (_currentStep > 0)
                                        ElevatedButton(
                                          onPressed: onBack,
                                          child: const Text('Back'),
                                        ),
                                      const Spacer(),
                                      if (_currentStep < totalSteps - 1)
                                        ElevatedButton(
                                          onPressed: onNext,
                                          child: const Text('Next'),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Health Info Section
                          Container(
                            key: _sectionKeys[3],
                            padding: const EdgeInsets.only(bottom: 30),
                            child: Form(
                              key: _formKeys[3],
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Health Info (Optional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                  const SizedBox(height: 10),
                                  TextFormField(
                                    controller: allergiesController,
                                    decoration: const InputDecoration(labelText: 'Allergies'),
                                  ),
                                  TextFormField(
                                    controller: medicalConditionController,
                                    decoration: const InputDecoration(labelText: 'Medical Conditions'),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      if (_currentStep > 0)
                                        ElevatedButton(
                                          onPressed: onBack,
                                          child: const Text('Back'),
                                        ),
                                      const Spacer(),
                                      if (_currentStep < totalSteps - 1)
                                        ElevatedButton(
                                          onPressed: onNext,
                                          child: const Text('Next'),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Language and Consent Section
                          Container(
                            key: _sectionKeys[4],
                            padding: const EdgeInsets.only(bottom: 30),
                            child: Form(
                              key: _formKeys[4],
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Language & Consent', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                  const SizedBox(height: 10),
                                  DropdownButtonFormField<String>(
                                    decoration: const InputDecoration(labelText: 'Preferred Language'),
                                    value: selectedLanguage,
                                    items: languages.map((lang) => DropdownMenuItem(child: Text(lang), value: lang)).toList(),
                                    onChanged: (val) => setState(() => selectedLanguage = val),
                                    validator: (val) => val == null ? 'Select a language' : null,
                                  ),
                                  CheckboxListTile(
                                    title: const Text('I agree to the Privacy Policy'),
                                    value: privacyConsent,
                                    onChanged: (val) => setState(() => privacyConsent = val ?? false),
                                  ),
                                  CheckboxListTile(
                                    title: const Text('I consent to Location Tracking for safety alerts (optional)'),
                                    value: locationConsent,
                                    onChanged: (val) => setState(() => locationConsent = val ?? false),
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      if (_currentStep > 0)
                                        ElevatedButton(
                                          onPressed: onBack,
                                          child: const Text('Back'),
                                        ),
                                      const Spacer(),
                                      ElevatedButton(
                                        onPressed: onRegister,
                                        child: const Text('Register'),
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
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
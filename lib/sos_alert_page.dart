import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'registration_page.dart'; // For SimpleEmergencyContact model

class SosEmergencyPage extends StatefulWidget {
  final List<SimpleEmergencyContact> emergencyContacts;

  const SosEmergencyPage({super.key, required this.emergencyContacts});

  @override
  _SosEmergencyPageState createState() => _SosEmergencyPageState();
}

class _SosEmergencyPageState extends State<SosEmergencyPage> {
  late List<SimpleEmergencyContact> contacts;

  @override
  void initState() {
    super.initState();
    contacts = List.from(widget.emergencyContacts);
  }

  Future<bool> _checkLocationPermission() async {
    var status = await Permission.location.status;
    if (!status.isGranted) {
      status = await Permission.location.request();
    }
    return status.isGranted;
  }

  Future<void> showShareLocationDialog(String locationMessage) async {
    List<bool> selected = List<bool>.filled(contacts.length, true);
    bool sendSms = true;
    bool sendWhatsapp = true;

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Send Location To', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: contacts.length,
                        itemBuilder: (_, i) {
                          return CheckboxListTile(
                            title: Text(contacts[i].name, style: TextStyle(color: Colors.teal[700], fontWeight: FontWeight.w500)),
                            value: selected[i],
                            activeColor: Colors.orange,
                            onChanged: (val) {
                              setState(() {
                                selected[i] = val ?? false;
                              });
                            },
                          );
                        },
                      ),
                    ),
                    CheckboxListTile(
                      title: const Text('Send SMS', style: TextStyle(color: Colors.deepOrange)),
                      value: sendSms,
                      activeColor: Colors.deepOrange,
                      onChanged: (val) {
                        setState(() => sendSms = val ?? false);
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Send WhatsApp', style: TextStyle(color: Colors.green)),
                      value: sendWhatsapp,
                      activeColor: Colors.green,
                      onChanged: (val) {
                        setState(() => sendWhatsapp = val ?? false);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.teal)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                for (int i = 0; i < contacts.length; i++) {
                  if (selected[i]) {
                    final phone = contacts[i].phone;
                    if (sendSms) {
                      final smsUri = Uri(scheme: 'sms', path: phone, queryParameters: {'body': locationMessage});
                      if (await canLaunchUrl(smsUri)) {
                        await launchUrl(smsUri);
                      }
                    }
                    if (sendWhatsapp) {
                      final whatsappUrl = Uri.parse(
                          'https://wa.me/$phone?text=${Uri.encodeComponent(locationMessage)}');
                      if (await canLaunchUrl(whatsappUrl)) {
                        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
                      }
                    }
                  }
                }
              },
              child: const Text('Send', style: TextStyle(color: Colors.orange)),
            ),
          ],
        );
      },
    );
  }

  Future<void> shareLocation() async {
    bool hasPermission = await _checkLocationPermission();
    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied')));
      return;
    }
    Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    final locationUrl = 'https://maps.google.com/?q=${pos.latitude},${pos.longitude}';
    final message = 'My current location: $locationUrl';

    await showShareLocationDialog(message);
  }

  Future<void> callPhone(String phone) async {
    final callUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot launch dialer')));
    }
  }

  Future<void> sendLocationMessage(String phone, String message) async {
    final smsUri = Uri(scheme: 'sms', path: phone, queryParameters: {'body': message});
    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    }
    final whatsappUrl = Uri.parse(
        'https://wa.me/$phone?text=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    }
  }

  void activateSOSAlert() async {
    bool hasPermission = await _checkLocationPermission();
    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied')));
      return;
    }
    Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    final locationUrl = 'https://maps.google.com/?q=${pos.latitude},${pos.longitude}';
    final message = 'SOS! Need immediate help. My location: $locationUrl';
    for (var contact in contacts) {
      await sendLocationMessage(contact.phone, message);
    }
    // TODO: Implement police dashboard API Call here
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('SOS Alert Sent to all contacts!')));
  }

  void editContact(int index) {
    final nameController = TextEditingController(text: contacts[index].name);
    final relationController = TextEditingController(text: contacts[index].relation);
    final phoneController = TextEditingController(text: contacts[index].phone);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Edit Contact', style: TextStyle(color: Colors.orange)),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: nameController,
                decoration: const InputDecoration(labelText: 'Name', filled: true, fillColor: Color(0xFFEFF7EE)),),
              TextField(controller: relationController,
                decoration: const InputDecoration(labelText: 'Relation', filled: true, fillColor: Color(0xFFEFF7EE)),),
              TextField(controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone', filled: true, fillColor: Color(0xFFEFF7EE)),),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                contacts[index] = SimpleEmergencyContact(
                  name: nameController.text,
                  relation: relationController.text,
                  phone: phoneController.text,);
              });
              Navigator.pop(context);
            },
            child: const Text('Save', style: TextStyle(color: Colors.orange)),
          ),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.teal))),
        ],
      ),
    );
  }

  void deleteContact(int index) {
    setState(() {
      contacts.removeAt(index);
    });
  }

  void addNewContact() {
    final nameController = TextEditingController();
    final relationController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Add New Contact', style: TextStyle(color: Colors.teal)),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: nameController,
                decoration: const InputDecoration(labelText: 'Name', filled: true, fillColor: Color(0xFFEFF7EE)),),
              TextField(controller: relationController,
                decoration: const InputDecoration(labelText: 'Relation', filled: true, fillColor: Color(0xFFEFF7EE)),),
              TextField(controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone', filled: true, fillColor: Color(0xFFEFF7EE)),),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              final relation = relationController.text.trim();
              final phone = phoneController.text.trim();
              if (name.isNotEmpty && phone.isNotEmpty) {
                setState(() {
                  contacts.add(SimpleEmergencyContact(name: name, relation: relation, phone: phone));
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add', style: TextStyle(color: Colors.orange)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.teal)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F7EF), // subtle mint
      appBar: AppBar(
        title: const Text('SOS Emergency Mode', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF4CAF50), // Android/Material Green
        elevation: 0,
        leading: BackButton(color: Colors.white),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    color: const Color(0xFF4CAF50).withOpacity(0.85), // strong green with slight transparency
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Immediate Police Contact', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 28),
                              elevation: 1,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: () => callPhone('100'),
                            child: const Text('CALL 100 EMERGENCY', style: TextStyle(color: Colors.white)),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              TextButton(
                                onPressed: () => callPhone('100'),
                                child: const Text('Police: 100', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                              ),
                              const SizedBox(width: 16),
                              TextButton(
                                onPressed: () => callPhone('1091'),
                                child: const Text('Domestic Violence Hotline', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                              )
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'When to call: Immediate physical danger, active surveillance, perpetrator present, or when you feel unsafe.',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text('Emergency Contacts', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 18)),
                  Expanded(
                    child: ListView.builder(
                      itemCount: contacts.length,
                      itemBuilder: (context, index) {
                        final c = contacts[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          color: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 2,
                          child: ListTile(
                            leading: const Icon(Icons.phone, color: Colors.orange, size: 26),
                            title: Text(c.name, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                            subtitle: Text('${c.relation} - ${c.phone}', style: const TextStyle(color: Colors.black54)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(icon: const Icon(Icons.edit, color: Colors.amber, size: 20), onPressed: () => editContact(index)),
                                IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 20), onPressed: () => deleteContact(index)),
                                IconButton(icon: const Icon(Icons.call, color: Colors.green, size: 20), onPressed: () => callPhone(c.phone)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Center(
                    child: IconButton(
                      onPressed: addNewContact,
                      icon: const Icon(Icons.add_circle, color: Color(0xFF4CAF50), size: 38),
                      tooltip: 'Add Emergency Contact',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: shareLocation,
                      icon: const Icon(Icons.share_location),
                      label: const Text('Share Location', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                        elevation: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: ElevatedButton(
                      onPressed: activateSOSAlert,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(36)),
                        elevation: 3,
                      ),
                      child: const Text('ACTIVATE SOS ALERT', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1)),
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

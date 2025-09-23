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
          title: const Text('Send Location To'),
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
                            title: Text(contacts[i].name),
                            value: selected[i],
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
                      title: const Text('Send SMS'),
                      value: sendSms,
                      onChanged: (val) {
                        setState(() => sendSms = val ?? false);
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Send WhatsApp'),
                      value: sendWhatsapp,
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
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                for (int i = 0; i < contacts.length; i++) {
                  if (selected[i]) {
                    final phone = contacts[i].phone;
                    if (sendSms) {
                      final smsUri = Uri(
                          scheme: 'sms', path: phone, queryParameters: {'body': locationMessage});
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
              child: const Text('Send'),
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
        title: const Text('Edit Contact'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: relationController, decoration: const InputDecoration(labelText: 'Relation')),
              TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone')),
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
                  phone: phoneController.text,
                );
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
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
        title: const Text('Add New Contact'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: relationController, decoration: const InputDecoration(labelText: 'Relation')),
              TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone')),
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
            child: const Text('Add'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SOS Emergency Mode'),
        backgroundColor: Colors.redAccent,
        leading: BackButton(),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/image.jpeg', fit: BoxFit.cover),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    color: Colors.red[600],
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Immediate Police Contact',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                            onPressed: () => callPhone('102'),
                            child: const Text('CALL 102 EMERGENCY'),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              TextButton(
                                onPressed: () => callPhone('102'),
                                child: const Text('Police: 102', style: TextStyle(color: Colors.white)),
                              ),
                              const SizedBox(width: 16),
                              TextButton(
                                onPressed: () => callPhone('1091'),
                                child: const Text('Domestic Violence Hotline', style: TextStyle(color: Colors.white)),
                              )
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'When to call: Immediate physical danger, active surveillance, perpetrator present, or when you feel unsafe.',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Emergency Contacts',
                      style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 18)),
                  Expanded(
                    child: ListView.builder(
                      itemCount: contacts.length,
                      itemBuilder: (context, index) {
                        final c = contacts[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: const Icon(Icons.phone),
                            title: Text(c.name,
                                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                            subtitle: Text('${c.relation} - ${c.phone}', style: const TextStyle(color: Colors.black)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.amber),
                                    onPressed: () => editContact(index)),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => deleteContact(index),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.call, color: Colors.green),
                                  onPressed: () => callPhone(c.phone),
                                ),
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
                      icon: const Icon(Icons.add_circle, color: Colors.teal, size: 42),
                      tooltip: 'Add Emergency Contact',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: shareLocation,
                      icon: const Icon(Icons.share_location),
                      label: const Text('Share Location'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: ElevatedButton(
                      onPressed: activateSOSAlert,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 18),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(36))),
                      child: const Text('ACTIVATE SOS ALERT',
                          style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:advayx/service/contact_service.dart';
import 'package:permission_handler/permission_handler.dart';

class AddContactPage extends StatefulWidget {
  // 1. Define the optional parameter
  final String? initialPhone;

  // 2. Add it to the constructor
  const AddContactPage({Key? key, this.initialPhone}) : super(key: key);

  @override
  State<AddContactPage> createState() => _AddContactPageState();
}

class _AddContactPageState extends State<AddContactPage> {
  final TextEditingController _nameController = TextEditingController();
  // 3. Remove the immediate assignment here
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    // 4. Initialize the controller with the passed value
    _phoneController = TextEditingController(text: widget.initialPhone ?? "");
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveContact() async {
    final String name = _nameController.text.trim();
    final String phone = _phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      _showSnackBar("Name and phone are required", isError: true);
      return;
    }

    // Duplicate Check
    String cleanNewPhone = phone.replaceAll(RegExp(r'\D'), '');
    bool exists = globalMemoryCache.any(
      (contact) => contact.phones.any(
        (p) => p.number.replaceAll(RegExp(r'\D'), '') == cleanNewPhone,
      ),
    );

    if (exists) {
      HapticFeedback.vibrate();
      _showSnackBar(
        "A contact with this number already exists!",
        isError: true,
      );
      return;
    }

    // Permission Check
    PermissionStatus status = await Permission.contacts.request();

    if (status.isPermanentlyDenied) {
      _showSnackBar(
        "Permission permanently denied. Please enable in settings.",
        isError: true,
      );
      openAppSettings();
      return;
    }

    if (!status.isGranted) {
      _showSnackBar("Contact permission denied", isError: true);
      return;
    }

    final newContact = Contact()
      ..name.first = name
      ..phones = [Phone(phone)];

    try {
      final insertedContact = await FlutterContacts.insertContact(newContact);

      globalMemoryCache.add(insertedContact);
      globalMemoryCache.sort(
        (a, b) =>
            a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()),
      );
      await ContactService.updateDiskCache();

      HapticFeedback.mediumImpact();
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      _showSnackBar("System Error: Could not save to phone.", isError: true);
      debugPrint("Save error: $e");
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text("Add Contact", style: TextStyle(color: Colors.black)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: "Full Name",
                prefixIcon: const Icon(
                  Icons.person_outline,
                  color: Colors.blueAccent,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: "Phone Number",
                prefixIcon: const Icon(
                  Icons.phone_android,
                  color: Colors.blueAccent,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: _saveContact,
              child: Container(
                height: 55,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF007AFF),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Text(
                  "Save Contact",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

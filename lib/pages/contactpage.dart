import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:advayx/service/contact_service.dart';
import 'addcontact.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({Key? key}) : super(key: key);

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  List<Contact> filteredContacts = globalMemoryCache;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _filterContacts(String query) {
    setState(() {
      filteredContacts = globalMemoryCache
          .where(
            (c) => c.displayName.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    });
  }

  void _addContact() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddContactPage()),
    );

    if (result == true) {
      setState(() {
        filteredContacts = globalMemoryCache;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Contact added successfully")),
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // 🔹 Simple White AppBar (no title)
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 10, // just top spacing
      ),

      body: Column(
        children: [
          // 🔹 SEARCH + ADD ROW
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                // 🔍 Search Bar
                Expanded(
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _filterContacts,
                      decoration: const InputDecoration(
                        hintText: "Search contacts",
                        prefixIcon: Icon(Icons.search),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // ➕ Add Contact Button
                // GestureDetector(
                //   onTap: _addContact,
                //   child: Container(
                //     height: 44,
                //     width: 44,
                //     decoration: BoxDecoration(
                //       color: const Color(0xFF007AFF),
                //       borderRadius: BorderRadius.circular(12),
                //     ),
                //     child: const Icon(Icons.add, color: Colors.white, size: 24),
                //   ),
                // ),
              ],
            ),
          ),

          // 🔹 CONTACT LIST
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: filteredContacts.length,
              itemBuilder: (context, index) {
                final contact = filteredContacts[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blueAccent.withOpacity(0.1),
                    child: Text(
                      contact.displayName.isNotEmpty
                          ? contact.displayName[0].toUpperCase()
                          : '?',
                    ),
                  ),
                  title: Text(contact.displayName),
                  subtitle: Text(
                    contact.phones.isNotEmpty
                        ? contact.phones.first.number
                        : 'No number',
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

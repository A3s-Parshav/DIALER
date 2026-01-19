import 'package:flutter/material.dart';
import 'package:call_log/call_log.dart';
import 'package:intl/intl.dart';

class RecentPage extends StatefulWidget {
  const RecentPage({super.key});

  @override
  State<RecentPage> createState() => _RecentPageState();
}

class _RecentPageState extends State<RecentPage> {
  late Future<Iterable<CallLogEntry>> _callLogs;

  @override
  void initState() {
    super.initState();
    // Fetch call logs when the page loads
    _callLogs = CallLog.get();
  }

  // Function to get the correct icon based on call type
  Widget _getCallIcon(CallType? type) {
    switch (type) {
      case CallType.outgoing:
        return const Icon(Icons.call_made, color: Colors.green, size: 18);
      case CallType.incoming:
        return const Icon(Icons.call_received, color: Colors.blue, size: 18);
      case CallType.missed:
        return const Icon(Icons.call_missed, color: Colors.red, size: 18);
      default:
        return const Icon(Icons.call, color: Colors.grey, size: 18);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<Iterable<CallLogEntry>>(
        future: _callLogs,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No call logs found.'));
          }

          final logs = snapshot.data!.toList();

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: logs.length,
            separatorBuilder: (context, index) => const Divider(height: 20),
            itemBuilder: (context, index) {
              final log = logs[index];
              final date = DateTime.fromMillisecondsSinceEpoch(log.timestamp!);
              final formattedDate = DateFormat('MMM d, h:mm a').format(date);

              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  child: const Icon(Icons.person, color: Colors.grey),
                ),
                title: Text(
                  log.name != null && log.name!.isNotEmpty
                      ? log.name!
                      : log.number!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Row(
                  children: [
                    _getCallIcon(log.callType),
                    const SizedBox(width: 5),
                    Text(
                      log.name != null && log.name!.isNotEmpty
                          ? log.number!
                          : formattedDate,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                trailing: Text(
                  formattedDate,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:advayx/widgets/bottom_nav.dart';
import 'package:permission_handler/permission_handler.dart';
import 'contactpage.dart';
import 'recordpage1.dart';
import 'package:flutter/services.dart';
import 'addcontact.dart';
import 'recentpage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

// ... existing imports ...

class _HomePageState extends State<HomePage> {
  int _index = 1; 

  final List<Widget> _pages = const [
    ContactPage(),   
    HomeContent(),   
    RecentPage(), 
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blueAccent,
        title: const Text(
          "AdvayX",
          style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_index == 0)
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white, size: 33),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddContactPage()),
              ),
            ),
        
          
    if (_index == 1)
            PopupMenuButton<String>(
               color: Colors.white,
              icon: const Icon(Icons.more_vert_rounded, color: Colors.white, size: 33),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onSelected: (String value) {
                switch (value) {
                  case 'recording':
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const Recordpage1()),
                    );
                    break;
                  case 'others':
                    
                    print("Others clicked");
                    break;
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem<String>(
                 
                  value: 'recording',
                  child: Row(
                    children: [
                      Icon(Icons.mic, color: Colors.blueAccent, size: 20),
                      SizedBox(width: 12),
                      Text("Call Record"),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'others',
                  child: Row(
                    children: [
                      Icon(Icons.more_horiz, color: Colors.grey, size: 20),
                      SizedBox(width: 12),
                      Text("Others"),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: _pages,
      ),
      bottomNavigationBar: AdvancedBottomNav(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
     

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});
  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final TextEditingController _controller = TextEditingController();
  static const platform = MethodChannel('dealer_call_channel');

  void _addNumber(String number) {
    HapticFeedback.lightImpact();
    setState(() => _controller.text += number);
  }

  void _removeNumber() {
    HapticFeedback.mediumImpact();
    if (_controller.text.isNotEmpty) {
      setState(() {
        _controller.text = _controller.text.substring(0, _controller.text.length - 1);
      });
    }
  }

  Future<void> _makeCall() async {
    final status = await Permission.phone.request();
    if (status.isGranted && _controller.text.isNotEmpty) {
      try {
        await platform.invokeMethod('startCall', {"number": _controller.text});
      } catch (e) {
        debugPrint("Call error: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        SizedBox(
          height: 120,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _controller.text,
                            style: const TextStyle(fontSize: 45, color: Colors.blue, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    if (_controller.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.backspace_rounded, color: Colors.grey, size: 28),
                        onPressed: _removeNumber,
                        onLongPress: () => setState(() => _controller.clear()),
                      )
                    else
                      const SizedBox(width: 48),
                  ],
                ),
              ),
              

              if (_controller.text.length >= 10)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddContactPage(initialPhone: _controller.text),
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      "Add to contacts",
                      style: TextStyle(color: Colors.blueAccent, fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ),
                )
              else 
                const SizedBox(height: 35), 
            ],
          ),
        ),

        const SizedBox(height: 10),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 45),
            child: GridView.count(
              crossAxisCount: 3,
              mainAxisSpacing: 15,
              crossAxisSpacing: 25,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _dialButton("1", "⚯"), _dialButton("2", "ABC"), _dialButton("3", "DEF"),
                _dialButton("4", "GHI"), _dialButton("5", "JKL"), _dialButton("6", "MNO"),
                _dialButton("7", "PQRS"), _dialButton("8", "TUV"), _dialButton("9", "WXYZ"),
                _dialButton("*", ","), _dialButton("0", "+"), _dialButton("#", ""),
              ],
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(bottom: 110), 
          child: Center(
            child: GestureDetector(
              onTap: _makeCall,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 75, width: 75,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.green),
                child: const Icon(Icons.call, color: Colors.white, size: 38),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dialButton(String number, String subText) {
    return InkWell(
      onTap: () => _addNumber(number),
      borderRadius: BorderRadius.circular(100),
      child: Container(
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withOpacity(0.04)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(number, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w400)),
            if (subText.isNotEmpty)
              Text(subText, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          ],
        ),
      ),
    );
  }
}
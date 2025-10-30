// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'browse_screen.dart';
import 'item_details_screen.dart';
import 'messages_screen.dart';
import 'post_item_screen.dart';
import 'profile_screen.dart';
import '../services/auth_services.dart'; // Import AuthService

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const BrowseScreen()));
    } else if (index == 2) {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const PostItemScreen()));
    } else if (index == 3) {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const MessagesScreen()));
    } else if (index == 4) {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ProfileScreen()));
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService(); // Create an instance

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 0,
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', height: 35),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {},
          ),
          // Updated Sign Out Button
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () async {
              print("Sign Out button pressed");
              await authService.signOut();
              // AuthWrapper will automatically navigate back to LoginScreen
            },
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage('assets/images/ramon_profile.jpg'),
            ),
          ),
        ],
      ),
      // ... (rest of the body and bottomNavigationBar remain the same)
      body: SingleChildScrollView(
         child: Padding(
           padding: const EdgeInsets.symmetric(horizontal: 16.0),
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               const SizedBox(height: 16),
               _buildSearchBar(),
               const SizedBox(height: 24),
               _buildSectionTitle('Categories'),
               const SizedBox(height: 16),
               _buildCategoriesRow(),
               const SizedBox(height: 24),
               _buildActionButtons(),
               const SizedBox(height: 24),
               _buildSectionTitle('Featured Items'),
               const SizedBox(height: 16),
               _buildFeaturedItemCard(
                 imageUrl: 'assets/images/gadget1.jpg',
                 title: 'iPhone 12 - Cracked Screen',
                 description: 'Screen broken, otherwise works fine',
                 price: '\$85',
                 status: 'Broken',
                 statusColor: Colors.orange,
                 time: '2h ago',
               ),
               const SizedBox(height: 16),
               _buildFeaturedItemCard(
                 imageUrl: 'assets/images/gadget2.jpg',
                 title: 'MacBook Pro 2018',
                 description: 'Water damage, good for parts',
                 price: '\$150',
                 status: 'For Parts',
                 statusColor: Colors.blue,
                 time: '5h ago',
               ),
               const SizedBox(height: 16),
               _buildFeaturedItemCard(
                 imageUrl: 'assets/images/gadget3.jpg',
                 title: 'Xbox Controller',
                 description: 'Slightly worn but fully functional',
                 price: '\$25',
                 status: 'Working',
                 statusColor: Colors.green,
                 time: '1d ago',
               ),
               const SizedBox(height: 24),
             ],
           ),
         ),
       ),
       bottomNavigationBar: BottomNavigationBar(
         items: const <BottomNavigationBarItem>[
           BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
           BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Browse'),
           BottomNavigationBarItem(icon: Icon(Icons.add_circle, size: 40), label: 'Sell'),
           BottomNavigationBarItem(icon: Icon(Icons.message_outlined), label: 'Message'),
           BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
         ],
         currentIndex: _selectedIndex,
         selectedItemColor: Colors.green,
         unselectedItemColor: Colors.grey,
         onTap: _onItemTapped,
         type: BottomNavigationBarType.fixed,
         showUnselectedLabels: true,
         backgroundColor: Colors.white,
         elevation: 2,
       ),
    );
  }

  // --- Helper Methods ---
  // ... (_buildSearchBar, _buildSectionTitle, _buildCategoriesRow,
  //      _buildCategoryItem, _buildActionButtons, _buildFeaturedItemCard remain the same)

   Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey),
          const SizedBox(width: 8),
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search electronics...',
                border: InputBorder.none,
              ),
            ),
          ),
          Container(
            height: 35,
            width: 35,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.filter_list, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildCategoriesRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildCategoryItem(Icons.phone_iphone, 'Phones', Colors.blue.withOpacity(0.1), Colors.blue),
        _buildCategoryItem(Icons.laptop, 'Laptops', Colors.green.withOpacity(0.1), Colors.green),
        _buildCategoryItem(Icons.blender, 'Appliances', Colors.purple.withOpacity(0.1), Colors.purple),
        _buildCategoryItem(Icons.headphones, 'Accessories', Colors.orange.withOpacity(0.1), Colors.orange),
      ],
    );
  }

  Widget _buildCategoryItem(IconData icon, String label, Color backgroundColor, Color iconColor) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, size: 30, color: iconColor),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.black54)),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
               Navigator.of(context).push(MaterialPageRoute(builder: (context) => const PostItemScreen()));
            },
            icon: const Icon(Icons.add_circle),
            label: const Text('Sell Item'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedItemCard({
    required String imageUrl,
    required String title,
    required String description,
    required String price,
    required String status,
    required Color statusColor,
    required String time,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ItemDetailsScreen(
              imageUrls: [imageUrl],
              title: title,
              price: price,
              status: status,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  child: Image.asset(
                    imageUrl,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 150,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 50),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      status,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.favorite_border, color: Colors.black, size: 20),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        price,
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.access_time, color: Colors.grey, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            time,
                            style: const TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
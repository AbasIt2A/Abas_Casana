import 'package:flutter/material.dart';

class MyPurchasesScreen extends StatefulWidget {
  const MyPurchasesScreen({super.key});

  @override
  State<MyPurchasesScreen> createState() => _MyPurchasesScreenState();
}

class _MyPurchasesScreenState extends State<MyPurchasesScreen> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'My Purchases',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildHeaderCard(),
          const SizedBox(height: 24),
          _buildFilterChips(),
          const SizedBox(height: 24),
          _buildPurchaseCard(
            imageUrl: 'assets/images/gadget1.jpg',
            title: 'iPhone 12 (Cracked Screen)',
            categoryDate: 'Electronics • 2 days ago',
            price: '\$85',
            sellerName: 'Mike Johnson',
            sellerImageUrl: 'https://i.pravatar.cc/150?img=3',
          ),
          _buildPurchaseCard(
            imageUrl: 'assets/images/gadget3.jpg',
            title: 'PS4 Controller (Stick Drift)',
            categoryDate: 'Gaming • 1 week ago',
            price: '\$120',
            sellerName: 'Alex Rivera',
            sellerImageUrl: 'https://i.pravatar.cc/150?img=7',
          ),
          _buildPurchaseCard(
            imageUrl: 'assets/images/gadget4.jpg',
            title: 'iPad Air (Broken Screen)',
            categoryDate: 'Tablets • 2 weeks ago',
            price: '\$120',
            sellerName: 'Emma Wilson',
            sellerImageUrl: 'https://i.pravatar.cc/150?img=4',
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Load More Items'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Purchases', style: TextStyle(color: Colors.grey)),
                SizedBox(height: 4),
                Text(
                  '12 Items',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_bag,
                color: Colors.green,
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'This Month', 'Last 3 Months'];
    return Row(
      children: filters.map((filter) {
        bool isSelected = _selectedFilter == filter;
        return Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: ChoiceChip(
            label: Text(filter),
            selected: isSelected,
            onSelected: (bool selected) {
              setState(() {
                _selectedFilter = filter;
              });
            },
            backgroundColor: Colors.white,
            selectedColor: isSelected ? Colors.green : Colors.white,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            showCheckmark: false,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPurchaseCard({
    required String imageUrl,
    required String title,
    required String categoryDate,
    required String price,
    required String sellerName,
    required String sellerImageUrl,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset(
                    imageUrl,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        categoryDate,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Purchased',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundImage: NetworkImage(sellerImageUrl),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      sellerName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Acquired'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

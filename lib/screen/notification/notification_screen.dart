import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notification',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Lufga',
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        children: [
          _buildSectionHeader('Today'),
          _buildNotificationItem(
            icon: Icons.person,
            iconBgColor: const Color(0xff4E8AE2),
            title: 'Agent Arrived',
            subtitle: 'Mohammed arrived',
            time: '04:25',
          ),
          _buildDivider(),
          _buildNotificationItem(
            icon: Icons.inventory_2,
            iconBgColor: const Color(0xffF7941D),
            title: 'Issue solved',
            subtitle: 'Your issue has solved',
            time: '04:25',
          ),
          _buildDivider(),
          const SizedBox(height: 32),
          _buildSectionHeader('Yesterday'),
          _buildNotificationItem(
            icon: Icons.person,
            iconBgColor: const Color(0xff4E8AE2),
            title: 'Agent Arrived',
            subtitle: 'Mohammed arrived',
            time: '04:25',
          ),
          _buildDivider(),
          _buildNotificationItem(
            icon: Icons.inventory_2,
            iconBgColor: const Color(0xffF7941D),
            title: 'Issue solved',
            subtitle: 'Your issue has solved',
            time: '04:25',
          ),
          _buildDivider(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xff8E8E93),
          fontSize: 15,
          fontFamily: 'Lufga',
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Lufga',
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xff8E8E93),
                    fontFamily: 'Lufga',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xff8E8E93),
              fontFamily: 'Lufga',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.only(left: 0),
      child: Divider(
        color: Colors.grey.withOpacity(0.2),
        thickness: 0.8,
        height: 1,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../../theme/app_colors.dart';
import '../../../../../theme/app_text_styles.dart';

class DriverNotificationsPage extends StatefulWidget {
  const DriverNotificationsPage({super.key});

  @override
  State<DriverNotificationsPage> createState() =>
      _DriverNotificationsPageState();
}

class _DriverNotificationsPageState extends State<DriverNotificationsPage> {
  bool _newRideRequests    = true;
  bool _rideReminders      = true;
  bool _pushNotifications  = true;
  bool _emailNotifications = false;
  bool _smsNotifications   = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        backgroundColor: AppColors.bg(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.text(context), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Notifications', style: AppTextStyles.pageTitle(context)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── RIDE ALERTS ──────────────────────────────────────────
          _SectionHeader(label: 'RIDE ALERTS'),
          const SizedBox(height: 10),
          _NotificationCard(
            children: [
              _ToggleRow(
                icon: Icons.local_taxi_rounded,
                label: 'New Ride Requests',
                subtitle: 'Get notified when a ride is available near you',
                value: _newRideRequests,
                onChanged: (v) => setState(() => _newRideRequests = v),
              ),
              _Divider(),
              _ToggleRow(
                icon: Icons.schedule_rounded,
                label: 'Ride Reminders',
                subtitle: 'Reminders for upcoming scheduled rides',
                value: _rideReminders,
                onChanged: (v) => setState(() => _rideReminders = v),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── CHANNELS ─────────────────────────────────────────────
          _SectionHeader(label: 'NOTIFICATION CHANNELS'),
          const SizedBox(height: 10),
          _NotificationCard(
            children: [
              _ToggleRow(
                icon: Icons.notifications_active_outlined,
                label: 'Push Notifications',
                subtitle: 'On-screen alerts on your device',
                value: _pushNotifications,
                onChanged: (v) => setState(() => _pushNotifications = v),
              ),
              _Divider(),
              _ToggleRow(
                icon: Icons.email_outlined,
                label: 'Email Notifications',
                subtitle: 'Receive updates to your email',
                value: _emailNotifications,
                onChanged: (v) => setState(() => _emailNotifications = v),
              ),
              _Divider(),
              _ToggleRow(
                icon: Icons.sms_outlined,
                label: 'SMS Notifications',
                subtitle: 'Receive text messages on your phone',
                value: _smsNotifications,
                onChanged: (v) => setState(() => _smsNotifications = v),
              ),
            ],
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label, style: AppTextStyles.sectionLabel(context));
  }
}

class _NotificationCard extends StatelessWidget {
  final List<Widget> children;
  const _NotificationCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(children: children),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.iconBg(context),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primaryPurple, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.settingsItem(context)),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyles.settingsItemValue(context)),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryPurple,
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 66,
      color: AppColors.border(context),
    );
  }
}
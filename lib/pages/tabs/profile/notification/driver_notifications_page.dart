import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../services/driver_service.dart';
import '../../../../../theme/app_colors.dart';
import '../../../../../theme/app_text_styles.dart';

class DriverNotificationsPage extends StatefulWidget {
  const DriverNotificationsPage({super.key});

  @override
  State<DriverNotificationsPage> createState() =>
      _DriverNotificationsPageState();
}

class _DriverNotificationsPageState extends State<DriverNotificationsPage> {
  // Default both ON until backend responds
  bool _pushEnabled  = true;
  bool _emailEnabled = true;
  bool _loading = true;

  final _driverService = DriverService();

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    try {
      final prefs = await _driverService.getNotificationPrefs();
      if (mounted) {
        setState(() {
          _pushEnabled  = prefs['pushEnabled']  ?? true;
          _emailEnabled = prefs['emailEnabled'] ?? true;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _onPushChanged(bool value) async {
    setState(() => _pushEnabled = value);
    try {
      await _driverService.updateNotificationPrefs(pushEnabled: value);
    } catch (_) {
      // revert on failure
      if (mounted) setState(() => _pushEnabled = !value);
    }
  }

  Future<void> _onEmailChanged(bool value) async {
    setState(() => _emailEnabled = value);
    try {
      await _driverService.updateNotificationPrefs(emailEnabled: value);
    } catch (_) {
      if (mounted) setState(() => _emailEnabled = !value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).translate;
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        backgroundColor: AppColors.bg(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.text(context),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          t('notification_settings'),
          style: AppTextStyles.pageTitle(context),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryPurple))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _NotificationCard(
                  title: t('booking_updates'),
                  description: t('booking_updates_description'),
                  children: [
                    _SimpleToggleRow(
                      label: t('push_notifications'),
                      value: _pushEnabled,
                      onChanged: _onPushChanged,
                    ),
                    _CardDivider(),
                    _SimpleToggleRow(
                      label: t('email'),
                      value: _emailEnabled,
                      onChanged: _onEmailChanged,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _NotificationCard extends StatelessWidget {
  final String title;
  final String? description;
  final List<Widget> children;

  const _NotificationCard({
    required this.title,
    this.description,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.sectionLabel(context),
                ),
                if (description != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    description!,
                    style: AppTextStyles.settingsItemValue(context),
                  ),
                ],
              ],
            ),
          ),
          _CardDivider(),
          ...children,
        ],
      ),
    );
  }
}

class _SimpleToggleRow extends StatelessWidget {
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SimpleToggleRow({
    required this.label,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.settingsItem(context)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: AppTextStyles.settingsItemValue(context),
                  ),
                ],
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.primaryPurple,
          ),
        ],
      ),
    );
  }
}

class _CardDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 0,
      color: AppColors.border(context),
    );
  }
}
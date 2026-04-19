import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/ticket_model.dart';
import '../../core/widgets/app_toast.dart';
import '../../providers/online_provider.dart';
import '../../services/support_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class WorkAreaPage extends StatefulWidget {
  const WorkAreaPage({super.key});

  @override
  State<WorkAreaPage> createState() => _WorkAreaPageState();
}

class _WorkAreaPageState extends State<WorkAreaPage> {
  final _reasonCtrl = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _requestChange() async {
    final reason = _reasonCtrl.text.trim();
    if (reason.isEmpty) {
      AppToast.info(context, 'Please describe the desired area change');
      return;
    }

    setState(() => _sending = true);
    try {
      await SupportService().createTicket(
        subject: 'Work Area Change Request',
        description: reason,
        category: TicketCategory.account,
      );
      if (!mounted) return;
      _reasonCtrl.clear();
      AppToast.success(context, 'Request submitted successfully');
    } catch (e) {
      if (!mounted) return;
      AppToast.error(context, 'Failed to submit request');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final driver = context.watch<OnlineProvider>().driverProfile;
    final area = driver?.workArea;

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        backgroundColor: AppColors.bg(context),
        elevation: 0,
        leading: _backButton(context),
        title: Text('Work Area', style: AppTextStyles.pageTitle(context)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Current Area Card ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border(context)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryPurple.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.location_on_rounded, color: AppColors.primaryPurple, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Area',
                              style: TextStyle(color: AppColors.subtext(context), fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              area?.displayName ?? 'Not assigned',
                              style: TextStyle(
                                color: AppColors.text(context),
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (area != null) ...[
                    const SizedBox(height: 16),
                    Divider(color: AppColors.border(context)),
                    const SizedBox(height: 12),
                    _areaDetail(context, Icons.flag_outlined, 'Country', area.country),
                    const SizedBox(height: 8),
                    _areaDetail(context, Icons.location_city_outlined, 'City', area.ville),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Request Change Section ──
            Text(
              'Request Area Change',
              style: AppTextStyles.settingsItem(context).copyWith(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Submit a request to change your assigned work area. An admin will review and process your request.',
              style: TextStyle(color: AppColors.subtext(context), fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _reasonCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Describe the area you want and the reason for change...',
                hintStyle: TextStyle(color: AppColors.subtext(context), fontSize: 14),
                filled: true,
                fillColor: AppColors.surface(context),
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.border(context)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.border(context)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.primaryPurple, width: 1.5),
                ),
              ),
              style: TextStyle(color: AppColors.text(context), fontSize: 14),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _sending ? null : _requestChange,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.primaryPurple.withValues(alpha: 0.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _sending
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Submit Request',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                      ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _areaDetail(BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.subtext(context), size: 18),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(color: AppColors.subtext(context), fontSize: 13)),
        const Spacer(),
        Text(value, style: TextStyle(color: AppColors.text(context), fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _backButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 2)),
            ],
          ),
          child: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.text(context), size: 18),
        ),
      ),
    );
  }
}

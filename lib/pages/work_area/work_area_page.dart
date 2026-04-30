import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/online_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class WorkAreaPage extends StatefulWidget {
  const WorkAreaPage({super.key});

  @override
  State<WorkAreaPage> createState() => _WorkAreaPageState();
}

class _WorkAreaPageState extends State<WorkAreaPage> {
  @override
  void dispose() {
    super.dispose();
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
                          color: AppColors.primaryPurple.withValues(
                            alpha: 0.12,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.location_on_rounded,
                          color: AppColors.primaryPurple,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Area',
                              style: TextStyle(
                                color: AppColors.subtext(context),
                                fontSize: 13,
                              ),
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
                    _areaDetail(
                      context,
                      Icons.flag_outlined,
                      'Country',
                      area.country,
                    ),
                    const SizedBox(height: 8),
                    _areaDetail(
                      context,
                      Icons.location_city_outlined,
                      'City',
                      area.ville,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _areaDetail(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, color: AppColors.subtext(context), size: 18),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(color: AppColors.subtext(context), fontSize: 13),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: AppColors.text(context),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
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
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.text(context),
            size: 18,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:moviroo_driver_app/routing/router.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '_IssueTypeSelector.dart';
import '_DescriptionField.dart';
import '_DocumentUpload.dart';

class ContactSupportPage extends StatefulWidget {
  const ContactSupportPage({super.key});

  @override
  State<ContactSupportPage> createState() => _ContactSupportPageState();
}

class _ContactSupportPageState extends State<ContactSupportPage> {
  int _selectedIssue = 0;
  final _descController = TextEditingController();

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: Column(
          children: [
            // ── TopBar ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: AppColors.text(context),
                    ),
                    onPressed: () => Navigator.canPop(context)
                        ? Navigator.pop(context)
                        : null,
                  ),
                  Expanded(
                    child: Text(
                      'Contact Support',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyLarge(
                        context,
                      ).copyWith(fontWeight: FontWeight.w800, fontSize: 18),
                    ),
                  ),
                  const SizedBox(width: 48), // balance back button
                ],
              ),
            ),

            // ── Scrollable body ────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Issue type ───────────────────────
                    _SectionLabel(label: 'SELECT ISSUE TYPE'),
                    const SizedBox(height: 10),
                    IssueTypeSelector(
                      selectedIndex: _selectedIssue,
                      onSelect: (i) => setState(() => _selectedIssue = i),
                    ),

                    const SizedBox(height: 24),

                    // ── Description ──────────────────────
                    _SectionLabel(label: 'DETAILED DESCRIPTION'),
                    const SizedBox(height: 10),
                    DescriptionField(controller: _descController),

                    const SizedBox(height: 24),

                    // ── Documents ────────────────────────
                    _SectionLabel(label: 'SUPPORTING DOCUMENTS'),
                    const SizedBox(height: 10),
                    const DocumentUpload(),

                    const SizedBox(height: 28),

                    // ── Submit button ─────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                      onPressed: () {
  if (Navigator.canPop(context)) {
    Navigator.pop(context);
  }
},
                        icon: const Icon(
                          Icons.send_outlined,
                          color: Colors.white,
                          size: 18,
                        ),
                        label: const Text(
                          'Submit Support Request',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryPurple,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.bodySmall(context).copyWith(
        color: AppColors.subtext(context),
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        fontSize: 11,
      ),
    );
  }
}

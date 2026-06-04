import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../core/models/ticket_model.dart';
import '../../routing/router.dart';
import '../../services/support/support_service.dart';
import '../../core/widgets/app_toast.dart';
import 'widgets/labeled_dropdown_field.dart';
import 'widgets/labeled_input_field.dart';
import 'widgets/section_header.dart';

class ContactSupportPage extends StatefulWidget {
  const ContactSupportPage({super.key});

  @override
  State<ContactSupportPage> createState() => _ContactSupportPageState();
}

class _ContactSupportPageState extends State<ContactSupportPage> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  String? _selectedCategory;
  bool _submitting = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // ── Submit ─────────────────────────────────────────────────────────────────

  Future<void> _submitForm() async {
    final t = AppLocalizations.of(context).translate;
    if (!_formKey.currentState!.validate() || _submitting) return;

    // Map localized category string to backend enum
    final categories = _localizedCategories(context);
    final catIndex = categories.indexOf(_selectedCategory ?? '');
    final backendCategory =
        (catIndex >= 0 && catIndex < kCategoryMapping.length)
        ? kCategoryMapping[catIndex]
        : TicketCategory.other;

    setState(() => _submitting = true);
    try {
      await SupportService().createTicket(
        subject: _subjectController.text.trim(),
        description: _messageController.text.trim(),
        category: backendCategory,
      );
      if (!mounted) return;
      AppToast.success(context, t('support_message_sent'));
      Navigator.pop(context);
      AppRouter.push(context, AppRouter.myTickets);
    } catch (e) {
      if (!mounted) return;
      AppToast.error(context, 'Failed to submit ticket. Please try again.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  List<String> _localizedCategories(BuildContext context) {
    final t = AppLocalizations.of(context).translate;
    return [
      t('support_cat_account'),
      t('support_cat_payment'),
      t('support_cat_trip'),
      t('support_cat_bug'),
      t('support_cat_safety'),
      t('support_cat_other'),
    ];
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).translate;
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        backgroundColor: AppColors.bg(context),
        elevation: 0,
        leading: Padding(
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
        ),
        title: Text(
          t('contact_support_title'),
          style: AppTextStyles.pageTitle(context),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // ── SEND A MESSAGE ─────────────────────────────────────────────
              SectionHeader(label: t('support_section_send')),
              const SizedBox(height: 16),

              // Category
              LabeledDropdownField(
                label: t('support_label_category'),
                hint: t('support_hint_category'),
                value: _selectedCategory,
                items: _localizedCategories(context),
                onChanged: (v) => setState(() => _selectedCategory = v),
                validator: (v) =>
                    v == null ? t('support_validate_category') : null,
              ),

              const SizedBox(height: 32),

              // Subject
              LabeledInputField(
                controller: _subjectController,
                label: t('support_label_subject'),
                hint: t('support_hint_subject'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? t('validation_required')
                    : null,
              ),

              const SizedBox(height: 32),

              // Message
              LabeledInputField(
                controller: _messageController,
                label: t('support_label_message'),
                hint: t('support_hint_message'),
                maxLines: 5,
                validator: (v) => (v == null || v.trim().length < 10)
                    ? t('support_validate_message')
                    : null,
              ),

              const SizedBox(height: 24),

              // Submit
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.primaryPurple.withValues(
                      alpha: 0.5,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _submitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          t('support_send'),
                          style: AppTextStyles.settingsItem(context).copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

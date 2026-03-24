import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import 'constants/support_categories.dart';
import 'widgets/labeled_dropdown_field.dart';
import 'widgets/labeled_input_field.dart';
import 'widgets/photo_grid.dart';
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
  final List<File> _attachments = [];

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // ── Photo picking ──────────────────────────────────────────────────────────

  Future<void> _pickPhoto(ImageSource source) async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1200,
    );
    if (xFile != null) {
      setState(() => _attachments.add(File(xFile.path)));
    }
  }

  void _showPhotoSourceSheet() {
    final t = AppLocalizations.of(context).translate;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(
                Icons.camera_alt_outlined,
                color: AppColors.primaryPurple,
              ),
              title: Text(
                t('photo_take'),
                style: TextStyle(color: AppColors.text(context)),
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickPhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: AppColors.primaryPurple,
              ),
              title: Text(
                t('photo_gallery'),
                style: TextStyle(color: AppColors.text(context)),
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickPhoto(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _removeAttachment(int index) =>
      setState(() => _attachments.removeAt(index));

  // ── Submit ─────────────────────────────────────────────────────────────────

  void _submitForm() {
    final t = AppLocalizations.of(context).translate;
    if (_formKey.currentState!.validate()) {
      // TODO: wire up to backend
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t('support_message_sent')),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
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
                    color: Colors.black.withOpacity(0.06),
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

              const SizedBox(height: 20),

              // Subject
              LabeledInputField(
                controller: _subjectController,
                label: t('support_label_subject'),
                hint: t('support_hint_subject'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? t('validation_required')
                    : null,
              ),

              const SizedBox(height: 20),

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

              // ── ATTACHMENTS ────────────────────────────────────────────────
              const SizedBox(height: 28),
              SectionHeader(label: t('support_section_attachments')),
              const SizedBox(height: 16),

              PhotoGrid(
                photos: _attachments,
                onAdd: _showPhotoSourceSheet,
                onRemove: _removeAttachment,
              ),

              const SizedBox(height: 32),

              // Submit
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
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

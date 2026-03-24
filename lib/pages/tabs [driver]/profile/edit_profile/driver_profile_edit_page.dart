import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../theme/app_colors.dart';
import '../../../../../theme/app_text_styles.dart';

class DriverProfileEditPage extends StatefulWidget {
  const DriverProfileEditPage({super.key});

  @override
  State<DriverProfileEditPage> createState() => _DriverProfileEditPageState();
}

class _DriverProfileEditPageState extends State<DriverProfileEditPage> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController(text: 'Aymen');
  final _lastNameController = TextEditingController(text: 'Naser');
  final _emailController = TextEditingController(text: 'aymen.naser@email.com');
  final _phoneController = TextEditingController(text: '94338510');

  File? _avatarFile;
  bool _isSaving = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null) setState(() => _avatarFile = File(picked.path));
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 900));
    setState(() => _isSaving = false);
    if (!mounted) return;
    final msg = AppLocalizations.of(context).translate('profile_updated');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
    Navigator.pop(context);
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
          t('personal_information'),
          style: AppTextStyles.pageTitle(context),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          children: [
            // ── Avatar ──────────────────────────────────────────
            Center(
              child: GestureDetector(
                onTap: _pickPhoto,
                child: Stack(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: _avatarFile == null
                            ? AppColors.purpleGradient
                            : null,
                        image: _avatarFile != null
                            ? DecorationImage(
                                image: FileImage(_avatarFile!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _avatarFile == null
                          ? const Center(
                              child: Icon(
                                Icons.person_rounded,
                                color: Colors.white,
                                size: 46,
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.primaryPurple,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.bg(context),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: GestureDetector(
                onTap: _pickPhoto,
                child: Text(
                  t('update_photo'),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryPurple,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ── Editable Tiles ───────────────────────────────────
            _EditableTile(
              icon: Icons.person_outline_rounded,
              label: t('field_first_name'),
              controller: _firstNameController,
              keyboardType: TextInputType.name,
              validator: (v) => v == null || v.trim().isEmpty
                  ? t('validation_required')
                  : null,
            ),
            const SizedBox(height: 10),
            _EditableTile(
              icon: Icons.person_outline_rounded,
              label: t('field_last_name'),
              controller: _lastNameController,
              keyboardType: TextInputType.name,
              validator: (v) => v == null || v.trim().isEmpty
                  ? t('validation_required')
                  : null,
            ),
            const SizedBox(height: 10),
            _EditableTile(
              icon: Icons.email_outlined,
              label: t('field_email_address'),
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty)
                  return t('validation_required');
                if (!v.contains('@')) return t('validation_invalid_email');
                return null;
              },
            ),
            const SizedBox(height: 10),
            _PhoneTile(controller: _phoneController),

            const SizedBox(height: 32),

            // ── Save Button ──────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  disabledBackgroundColor: AppColors.primaryPurple.withOpacity(
                    0.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        t('save_changes'),
                        style: AppTextStyles.buttonPrimary,
                      ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/// Card-style tile that wraps an editable TextFormField —
/// looks identical to the read-only tiles in the screenshot.
class _EditableTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _EditableTile({
    required this.icon,
    required this.label,
    required this.controller,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(context), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.subtext(context), size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              validator: validator,
              style: AppTextStyles.settingsItem(context),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: AppTextStyles.settingsItemValue(context),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Phone tile — same card style, with a static "+216 " prefix
/// rendered before the editable number.
class _PhoneTile extends StatelessWidget {
  final TextEditingController controller;

  const _PhoneTile({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(context), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.phone_outlined,
            color: AppColors.subtext(context),
            size: 22,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.phone,
              style: AppTextStyles.settingsItem(context),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(
                  context,
                ).translate('field_phone_number'),
                labelStyle: AppTextStyles.settingsItemValue(context),
                prefix: Text(
                  '+216 ',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.text(context),
                  ),
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:moviroo_driver_app/pages/tabs%20%5Bdriver%5D/widgets/_TopBar.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../routing/router.dart';

class PasswordResetPage extends StatefulWidget {
  const PasswordResetPage({super.key});

  @override
  State<PasswordResetPage> createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  final _currentCtrl  = TextEditingController();
  final _newCtrl      = TextEditingController();
  final _confirmCtrl  = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew     = false;
  bool _obscureConfirm = false;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(
    BuildContext context, {
    required String hint,
    required IconData prefixIcon,
    Widget? suffix,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.bodyMedium(context)
          .copyWith(color: AppColors.subtext(context)),
      prefixIcon: Icon(prefixIcon,
          color: AppColors.subtext(context), size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: AppColors.surface(context),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: isDark
            ? BorderSide.none
            : BorderSide(color: AppColors.border(context)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: isDark
            ? BorderSide.none
            : BorderSide(color: AppColors.border(context)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            BorderSide(color: AppColors.primaryPurple, width: 2),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: Column(
          children: [

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  TopBar(title: 'Change Password'),
                  const SizedBox(height: 12),

                    _SectionLabel(label: 'PASSWORD DETAILS'),
                    const SizedBox(height: 12),

                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface(context),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border(context)),
                      ),
                      child: Column(
                        children: [

                          _FieldTile(
                            label: 'Current password',
                            child: TextField(
                              controller: _currentCtrl,
                              obscureText: _obscureCurrent,
                              cursorColor: AppColors.primaryPurple,
                              style: AppTextStyles.bodyMedium(context),
                              decoration: _fieldDecoration(
                                context,
                                hint: '••••••••',
                                prefixIcon: Icons.lock_outline_rounded,
                                suffix: IconButton(
                                  icon: Icon(
                                    _obscureCurrent
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: AppColors.subtext(context),
                                    size: 20,
                                  ),
                                  onPressed: () => setState(
                                      () => _obscureCurrent = !_obscureCurrent),
                                ),
                              ),
                            ),
                          ),

                          Divider(height: 1, color: AppColors.border(context)),

                          _FieldTile(
                            label: 'New password',
                            child: TextField(
                              controller: _newCtrl,
                              obscureText: _obscureNew,
                              cursorColor: AppColors.primaryPurple,
                              style: AppTextStyles.bodyMedium(context),
                              decoration: _fieldDecoration(
                                context,
                                hint: 'Enter new password',
                                prefixIcon: Icons.lock_outline_rounded,
                                suffix: IconButton(
                                  icon: Icon(
                                    Icons.lock_rounded,
                                    color: AppColors.primaryPurple,
                                    size: 20,
                                  ),
                                  onPressed: () => setState(
                                      () => _obscureNew = !_obscureNew),
                                ),
                              ),
                            ),
                          ),

                          Divider(height: 1, color: AppColors.border(context)),

                          _FieldTile(
                            label: 'Confirm new password',
                            child: TextField(
                              controller: _confirmCtrl,
                              obscureText: _obscureConfirm,
                              cursorColor: AppColors.primaryPurple,
                              style: AppTextStyles.bodyMedium(context),
                              decoration: _fieldDecoration(
                                context,
                                hint: 'Re-enter new password',
                                prefixIcon: Icons.lock_outline_rounded,
                                suffix: Icon(
                                  Icons.check_rounded,
                                  color: AppColors.subtext(context),
                                  size: 20,
                                ),
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(14),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primaryPurple.withOpacity(0.07),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: AppColors.primaryPurple
                                        .withOpacity(0.20)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.info_outline_rounded,
                                      color: AppColors.primaryPurple,
                                      size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Password tips',
                                            style: AppTextStyles.bodySmall(
                                                    context)
                                                .copyWith(
                                              color: AppColors.primaryPurple,
                                              fontWeight: FontWeight.w700,
                                            )),
                                        const SizedBox(height: 3),
                                        Text(
                                          'Use at least 8 characters with a mix of letters and numbers for better protection.',
                                          style: AppTextStyles.bodySmall(
                                                  context)
                                              .copyWith(
                                            color: AppColors.subtext(context),
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    _SectionLabel(label: 'SECURITY'),
                    const SizedBox(height: 12),

                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface(context),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border(context)),
                      ),
                      child: Column(
                        children: [

                          ListTile(
                            title: Text('Last password update',
                                style: AppTextStyles.bodyMedium(context)
                                    .copyWith(fontWeight: FontWeight.w700)),
                            subtitle: Text('Changed 42 days ago',
                                style: AppTextStyles.bodySmall(context)
                                    .copyWith(
                                        color: AppColors.subtext(context))),
                            trailing: Icon(Icons.chevron_right_rounded,
                                color: AppColors.subtext(context)),
                            onTap: () {},
                          ),

                          Divider(height: 1, color: AppColors.border(context)),

                          ListTile(
                            title: Text('Account protection',
                                style: AppTextStyles.bodyMedium(context)
                                    .copyWith(fontWeight: FontWeight.w700)),
                            subtitle: Text('Your account is currently secured',
                                style: AppTextStyles.bodySmall(context)
                                    .copyWith(
                                        color: AppColors.subtext(context))),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: Colors.green.withOpacity(0.30)),
                              ),
                              child: const Text('Active',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  )),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(
                  16, 0, 16, MediaQuery.of(context).padding.bottom + 16),
              child: Column(
                children: [

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.save_outlined,
                          color: Colors.white, size: 18),
                      label: const Text('Save new password',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          )),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPurple,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel',
                          style: AppTextStyles.bodyLarge(context).copyWith(
                            fontWeight: FontWeight.w700,
                          )),
                    ),
                  ),
                ],
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
    return Text(label,
        style: AppTextStyles.bodySmall(context).copyWith(
          color: AppColors.subtext(context),
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          fontSize: 11,
        ));
  }
}

class _FieldTile extends StatelessWidget {
  final String label;
  final Widget child;
  const _FieldTile({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTextStyles.bodySmall(context).copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 12,
              )),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
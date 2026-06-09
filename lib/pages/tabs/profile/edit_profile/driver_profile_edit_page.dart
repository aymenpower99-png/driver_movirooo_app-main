import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cross_file/cross_file.dart';
import 'dart:io';
import '../../../../../services/driver/driver_service.dart';
import '../../../../../providers/online_provider.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../theme/app_colors.dart';
import '../../../../../theme/app_text_styles.dart';
import '../../../../../providers/auth_provider.dart';
import '../../../../../core/widgets/app_toast.dart';

class DriverProfileEditPage extends StatefulWidget {
  const DriverProfileEditPage({super.key});

  @override
  State<DriverProfileEditPage> createState() => _DriverProfileEditPageState();
}

class _DriverProfileEditPageState extends State<DriverProfileEditPage> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _uploading = false;

  Future<void> _pickAndUploadPhoto(ImageSource source) async {
    if (_uploading) return;
    setState(() => _uploading = true);
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source, imageQuality: 100);
      if (picked == null) {
        setState(() => _uploading = false);
        return;
      }

      final pathLower = picked.path.toLowerCase();
      final allowed =
          pathLower.endsWith('.jpg') ||
          pathLower.endsWith('.jpeg') ||
          pathLower.endsWith('.png') ||
          pathLower.endsWith('.webp');
      if (!allowed) {
        AppToast.error(
          context,
          'Unsupported image format. Allowed: jpg, jpeg, png, webp.',
        );
        setState(() => _uploading = false);
        return;
      }

      // Crop to 1:1
      CroppedFile? cropped;
      if (Platform.isAndroid) {
        // Temporarily skip native cropper on Android to avoid plugin crash.
        // Use original selection and keep square aspect via avatar mask.
        cropped = CroppedFile(picked.path);
      } else {
        try {
          cropped = await ImageCropper().cropImage(
            sourcePath: picked.path,
            aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
            uiSettings: [
              AndroidUiSettings(
                toolbarTitle: 'Crop photo',
                toolbarColor: AppColors.primaryPurple,
                toolbarWidgetColor: Colors.white,
                activeControlsWidgetColor: AppColors.primaryPurple,
                lockAspectRatio: true,
              ),
              IOSUiSettings(title: 'Crop photo', aspectRatioLockEnabled: true),
            ],
          );
        } catch (e) {
          debugPrint('Crop failed (iOS): $e');
          // If crop fails, use original image
          cropped = CroppedFile(picked.path);
        }
      }
      if (cropped == null) {
        setState(() => _uploading = false);
        return;
      }

      // Compress to JPEG < 1MB
      final tmpDir = await getTemporaryDirectory();
      final outPath =
          '${tmpDir.path}/driver_logo_${DateTime.now().millisecondsSinceEpoch}.jpg';

      XFile? compressed = await FlutterImageCompress.compressAndGetFile(
        cropped.path,
        outPath,
        quality: 85,
        format: CompressFormat.jpeg,
      );
      if (compressed == null) {
        throw Exception('Compression failed');
      }
      int size = await compressed.length();
      if (size > 1024 * 1024) {
        compressed = await FlutterImageCompress.compressAndGetFile(
          cropped.path,
          outPath,
          quality: 75,
          format: CompressFormat.jpeg,
        );
        if (compressed == null) {
          throw Exception('Compression failed');
        }
        size = await compressed.length();
      }
      if (size > 1024 * 1024) {
        compressed = await FlutterImageCompress.compressAndGetFile(
          cropped.path,
          outPath,
          quality: 65,
          format: CompressFormat.jpeg,
        );
        if (compressed == null) {
          throw Exception('Compression failed');
        }
        size = await compressed.length();
      }
      if (size > 1024 * 1024) {
        AppToast.error(
          context,
          'Photo is too large after compression. Please choose a different image.',
        );
        setState(() => _uploading = false);
        return;
      }

      // Signature
      debugPrint('POST /drivers/me/logo/signature (no body)');
      final sig = await DriverService().getLogoUploadSignature();
      debugPrint('Signature response: ' + sig.toString());

      // Cloudinary payload log
      final form = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          compressed.path,
          filename: 'driver_logo.jpg',
        ),
        'api_key': sig['apiKey'],
        'timestamp': sig['timestamp'],
        'signature': sig['signature'],
        'folder': sig['folder'],
        'public_id': sig['publicId'],
        'overwrite': 'true',
        'invalidate': 'true',
      });
      debugPrint(
        'Cloudinary upload payload (pre-send): cloud=${sig['cloudName']} folder=${sig['folder']} public_id=${sig['publicId']} ts=${sig['timestamp']} file=${compressed.path} size=${size}',
      );

      final dio = Dio();
      final url =
          'https://api.cloudinary.com/v1_1/${sig['cloudName']}/image/upload';
      final res = await dio.post(url, data: form);
      debugPrint(
        'Cloudinary upload response: status=${res.statusCode} public_id=${res.data['public_id']} secure_url=${res.data['secure_url']}',
      );

      final secureUrl = (res.data)['secure_url'] as String;
      final publicId = (res.data)['public_id'] as String;

      // Persist
      await DriverService().saveLogo(url: secureUrl, publicId: publicId);
      if (!mounted) return;
      await context.read<OnlineProvider>().refreshDriverProfile();
      AppToast.success(context, 'Profile photo updated');
    } on DioException catch (e) {
      debugPrint(
        'Upload error DioException: ${e.response?.statusCode} ${e.response?.data}',
      );
      if (!mounted) return;
      AppToast.error(context, 'Upload failed. Please try again.');
    } catch (e) {
      debugPrint('Upload error: $e');
      if (!mounted) return;
      AppToast.error(context, 'Upload failed. Please try again.');
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    // Pre-fill from cached user
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        _firstNameController.text = user.firstName;
        _lastNameController.text = user.lastName;
        _emailController.text = user.email;
        final rawPhone = user.phone ?? '';
        _phoneController.text = rawPhone.startsWith('+216')
            ? rawPhone.substring(4)
            : rawPhone;
      }
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final phoneDigits = _phoneController.text.trim();
    final fullPhone = phoneDigits.startsWith('+216')
        ? phoneDigits
        : '+216$phoneDigits';
    final ok = await auth.updateProfile(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: fullPhone,
    );
    if (!mounted) return;
    if (ok) {
      AppToast.success(
        context,
        AppLocalizations.of(context).translate('profile_updated'),
      );
      Navigator.pop(context);
    } else if (auth.error != null) {
      AppToast.error(context, auth.error!);
      auth.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).translate;
    final auth = context.watch<AuthProvider>();
    final loading = auth.loading;
    final initials = auth.user?.initials ?? '?';
    final online = context.watch<OnlineProvider>();
    final logoUrl = online.driverProfile?.logoUrl;

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
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFFA855F7), Color(0xFF7C3AED)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: logoUrl != null && logoUrl.isNotEmpty
                        ? Image.network(logoUrl, fit: BoxFit.cover)
                        : Center(
                            child: Text(
                              initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                  ),
                  if (_uploading)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black26,
                        child: const Center(
                          child: SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (!_uploading)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: _uploading
                            ? null
                            : () async {
                                await showModalBottomSheet<void>(
                                  context: context,
                                  builder: (ctx) => SafeArea(
                                    child: Wrap(
                                      children: [
                                        ListTile(
                                          leading: const Icon(
                                            Icons.photo_library_outlined,
                                            color: AppColors.primaryPurple,
                                          ),
                                          title: const Text(
                                            'Choose from gallery',
                                            style: TextStyle(
                                              color: AppColors.primaryPurple,
                                            ),
                                          ),
                                          onTap: () {
                                            Navigator.pop(ctx);
                                            _pickAndUploadPhoto(
                                              ImageSource.gallery,
                                            );
                                          },
                                        ),
                                        ListTile(
                                          leading: const Icon(
                                            Icons.photo_camera_outlined,
                                            color: AppColors.primaryPurple,
                                          ),
                                          title: const Text(
                                            'Take a photo',
                                            style: TextStyle(
                                              color: AppColors.primaryPurple,
                                            ),
                                          ),
                                          onTap: () {
                                            Navigator.pop(ctx);
                                            _pickAndUploadPhoto(
                                              ImageSource.camera,
                                            );
                                          },
                                        ),
                                        if (logoUrl != null &&
                                            logoUrl.isNotEmpty)
                                          const Divider(height: 1),
                                        if (logoUrl != null &&
                                            logoUrl.isNotEmpty)
                                          ListTile(
                                            leading: const Icon(
                                              Icons.delete_outline,
                                              color: Colors.redAccent,
                                            ),
                                            title: const Text(
                                              'Remove photo',
                                              style: TextStyle(
                                                color: Colors.redAccent,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            onTap: () async {
                                              Navigator.pop(ctx);
                                              if (_uploading) return;
                                              setState(() => _uploading = true);
                                              try {
                                                await DriverService()
                                                    .deleteLogo();
                                                if (!mounted) return;
                                                await context
                                                    .read<OnlineProvider>()
                                                    .refreshDriverProfile();
                                                AppToast.success(
                                                  context,
                                                  'Profile photo removed',
                                                );
                                              } catch (e) {
                                                if (!mounted) return;
                                                AppToast.error(
                                                  context,
                                                  'Failed to remove photo. Please try again.',
                                                );
                                              } finally {
                                                if (mounted)
                                                  setState(
                                                    () => _uploading = false,
                                                  );
                                              }
                                            },
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryPurple,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const SizedBox(height: 20),

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
            _ReadOnlyEmailTile(
              icon: Icons.email_outlined,
              label: t('field_email_address'),
              controller: _emailController,
              subtitle: t('contact_support_to_change'),
            ),
            const SizedBox(height: 10),
            _PhoneTile(controller: _phoneController),

            const SizedBox(height: 32),

            // ── Save Button ──────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: loading ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  disabledBackgroundColor: AppColors.primaryPurple.withValues(
                    alpha: 0.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: loading
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
                prefix: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Tunisia flag emoji
                    Text('🇹🇳', style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 6),
                    Text(
                      '+216 ',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.text(context),
                      ),
                    ),
                  ],
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

/// Read-only tile for fields that cannot be edited by the user.
class _ReadOnlyTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;

  const _ReadOnlyTile({
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(context), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.subtext(context), size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.settingsItemValue(context)),
                const SizedBox(height: 4),
                Text(value, style: AppTextStyles.settingsItem(context)),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.subtext(context),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Read-only email tile that displays email from controller but cannot be edited.
class _ReadOnlyEmailTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final TextEditingController controller;
  final String subtitle;

  const _ReadOnlyEmailTile({
    required this.icon,
    required this.label,
    required this.controller,
    required this.subtitle,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: controller,
                  keyboardType: TextInputType.emailAddress,
                  enabled: false, // Read-only
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
                Padding(
                  padding: const EdgeInsets.only(left: 12, bottom: 4),
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.subtext(context),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

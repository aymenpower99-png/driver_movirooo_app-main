// lib/pages/tracking/widgets/report/report_issue_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moviroo_driver_app/l10n/app_localizations.dart';
import 'package:moviroo_driver_app/theme/app_colors.dart';
import 'package:moviroo_driver_app/services/support_service.dart';
import 'package:moviroo_driver_app/core/models/ticket_model.dart';
import 'package:moviroo_driver_app/core/widgets/app_toast.dart';
import 'package:moviroo_driver_app/pages/tracking/widgets/photo/photo_grid.dart';
import 'ride_issue.dart';
import 'section_label.dart';
import 'issue_tile.dart';
import 'trip_context_card.dart';

// ── Page ──────────────────────────────────────────────────────────────────────

class ReportIssuePage extends StatefulWidget {
  final String passengerName;
  final String rideId;
  final String pickupAddress;
  final String dropOffAddress;
  final void Function(RideIssue issue, String note, List<File> photos) onSubmit;

  const ReportIssuePage({
    super.key,
    required this.passengerName,
    required this.rideId,
    required this.pickupAddress,
    required this.dropOffAddress,
    required this.onSubmit,
  });

  @override
  State<ReportIssuePage> createState() => _ReportIssuePageState();
}

class _ReportIssuePageState extends State<ReportIssuePage> {
  RideIssue? _selected;
  final _noteController = TextEditingController();
  final _noteFocus = FocusNode();
  final List<File> _photos = [];
  bool _submitting = false;

  @override
  void dispose() {
    _noteController.dispose();
    _noteFocus.dispose();
    super.dispose();
  }

  // ── Photo picking ───────────────────────────────────────────────────────────

  Future<void> _pickPhoto(ImageSource source) async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1200,
    );
    if (xFile != null) {
      setState(() => _photos.add(File(xFile.path)));
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

  void _removePhoto(int index) => setState(() => _photos.removeAt(index));

  // ── Submit ──────────────────────────────────────────────────────────────────

  /// Maps RideIssue enum to a TicketCategory for the backend.
  TicketCategory _issueToCategory(RideIssue issue) {
    switch (issue) {
      case RideIssue.appIssue:
        return TicketCategory.technical;
      case RideIssue.noShow:
      case RideIssue.wrongLocation:
      case RideIssue.badBehavior:
      case RideIssue.safetyConcern:
        return TicketCategory.ride;
      case RideIssue.other:
        return TicketCategory.other;
    }
  }

  Future<void> _submit() async {
    if (_selected == null || _submitting) return;
    setState(() => _submitting = true);
    bool success = false;
    try {
      await SupportService().createTicket(
        subject: _selected!.label,
        description: _noteController.text.trim().isEmpty
            ? _selected!.label
            : _noteController.text.trim(),
        category: _issueToCategory(_selected!),
        rideId: widget.rideId,
        metadata: {
          'pickupAddress': widget.pickupAddress,
          'dropOffAddress': widget.dropOffAddress,
          'passengerName': widget.passengerName,
        },
      );
      success = true;
    } catch (_) {
      // submit best-effort
    }
    widget.onSubmit(_selected!, _noteController.text.trim(), List.of(_photos));
    if (mounted) {
      setState(() => _submitting = false);
      if (success) {
        AppToast.success(context, 'Report submitted successfully');
      } else {
        AppToast.error(context, 'Failed to submit report');
      }
      Navigator.of(context).pop();
    }
  }

  // ── Issue translation ───────────────────────────────────────────────────────
  String _issueLabel(RideIssue issue, String Function(String) t) {
    switch (issue) {
      case RideIssue.noShow:
        return t('issue_no_show');
      case RideIssue.wrongLocation:
        return t('issue_wrong_location');
      case RideIssue.badBehavior:
        return t('issue_bad_behavior');
      case RideIssue.safetyConcern:
        return t('issue_safety');
      case RideIssue.appIssue:
        return t('issue_app');
      case RideIssue.other:
        return t('issue_other');
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canSubmit = _selected != null && !_submitting;
    final t = AppLocalizations.of(context).translate;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.bg(context),
        appBar: AppBar(
          backgroundColor: AppColors.surface(context),
          elevation: 0,
          scrolledUnderElevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            color: AppColors.text(context),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t('tracking_report_title'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text(context),
                ),
              ),
              Text(
                widget.passengerName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.subtext(context),
                ),
              ),
            ],
          ),
          titleSpacing: 0,
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            // ── Trip context card ─────────────────────────────
            TripContextCard(
              passengerName: widget.passengerName,
              pickupAddress: widget.pickupAddress,
              dropOffAddress: widget.dropOffAddress,
            ),
            const SizedBox(height: 20),

            // ── Issue categories ──────────────────────────────────
            SectionLabel(label: t('tracking_report_subtitle')),
            const SizedBox(height: 10),
            ...RideIssue.values.map(
              (issue) => IssueTile(
                issue: issue,
                label: _issueLabel(issue, t),
                selected: _selected == issue,
                isDark: isDark,
                onTap: () => setState(() => _selected = issue),
              ),
            ),

            // ── Notes field ───────────────────────────────────────
            const SizedBox(height: 24),
            SectionLabel(label: t('report_additional_details')),
            const SizedBox(height: 10),
            TextField(
              controller: _noteController,
              focusNode: _noteFocus,
              maxLines: 5,
              maxLength: 500,
              textInputAction: TextInputAction.done,
              style: TextStyle(fontSize: 14, color: AppColors.text(context)),
              decoration: InputDecoration(
                hintText: t('report_hint_describe'),
                hintStyle: TextStyle(
                  color: AppColors.subtext(context),
                  fontSize: 14,
                ),
                filled: true,
                fillColor: AppColors.surface(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border(context)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border(context)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primaryPurple,
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.all(14),
                counterStyle: TextStyle(
                  color: AppColors.subtext(context),
                  fontSize: 11,
                ),
              ),
            ),

            // ── Photo grid ────────────────────────────────────────
            const SizedBox(height: 24),
            SectionLabel(label: t('report_attach_photos')),
            const SizedBox(height: 10),
            PhotoGrid(
              photos: _photos,
              onAdd: _showPhotoSourceSheet,
              onRemove: _removePhoto,
            ),

            // ── Submit button ─────────────────────────────────────
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: canSubmit ? _submit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  disabledBackgroundColor: AppColors.primaryPurple.withValues(
                    alpha: 0.35,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        t('report_submit'),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

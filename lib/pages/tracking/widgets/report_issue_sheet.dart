// lib/pages/tracking/report_issue_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moviroo_driver_app/l10n/app_localizations.dart';
import 'package:moviroo_driver_app/theme/app_colors.dart';
import 'package:moviroo_driver_app/services/support_service.dart';
import 'package:moviroo_driver_app/core/models/ticket_model.dart';
import 'package:moviroo_driver_app/core/widgets/app_toast.dart';
import 'photo_grid.dart';

// ── Issue categories ──────────────────────────────────────────────────────────

enum RideIssue {
  noShow('Passenger No-Show', Icons.person_off_outlined),
  wrongLocation('Wrong Pickup Location', Icons.location_off_outlined),
  badBehavior('Passenger Behavior Problem', Icons.warning_amber_rounded),
  safetyConcern('Safety Concern', Icons.shield_outlined),
  appIssue('App / Technical Issue', Icons.bug_report_outlined),
  other('Other', Icons.more_horiz_rounded);

  const RideIssue(this.label, this.icon);
  final String label;
  final IconData icon;
}

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
        subject:     _selected!.label,
        description: _noteController.text.trim().isEmpty
            ? _selected!.label
            : _noteController.text.trim(),
        category:    _issueToCategory(_selected!),
        rideId:      widget.rideId,
        metadata: {
          'pickupAddress':  widget.pickupAddress,
          'dropOffAddress': widget.dropOffAddress,
          'passengerName':  widget.passengerName,
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
            _TripContextCard(
              passengerName: widget.passengerName,
              pickupAddress: widget.pickupAddress,
              dropOffAddress: widget.dropOffAddress,
            ),
            const SizedBox(height: 20),

            // ── Issue categories ──────────────────────────────────
            _SectionLabel(label: t('tracking_report_subtitle')),
            const SizedBox(height: 10),
            ...RideIssue.values.map(
              (issue) => _IssueTile(
                issue: issue,
                label: _issueLabel(issue, t),
                selected: _selected == issue,
                isDark: isDark,
                onTap: () => setState(() => _selected = issue),
              ),
            ),

            // ── Notes field ───────────────────────────────────────
            const SizedBox(height: 24),
            _SectionLabel(label: t('report_additional_details')),
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
            _SectionLabel(label: t('report_attach_photos')),
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

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.subtext(context),
        letterSpacing: 0.3,
      ),
    );
  }
}

// ── Issue tile ────────────────────────────────────────────────────────────────

class _IssueTile extends StatelessWidget {
  final RideIssue issue;
  final String label;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _IssueTile({
    required this.issue,
    required this.label,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryPurple.withValues(alpha: isDark ? 0.22 : 0.07)
              : AppColors.surface(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? AppColors.primaryPurple
                : AppColors.border(context),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              issue.icon,
              size: 20,
              color: selected
                  ? AppColors.primaryPurple
                  : AppColors.subtext(context),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected
                      ? AppColors.text(context)
                      : AppColors.subtext(context),
                ),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: selected
                  ? const Icon(
                      Icons.check_circle_rounded,
                      key: ValueKey('check'),
                      size: 18,
                      color: AppColors.primaryPurple,
                    )
                  : const SizedBox(key: ValueKey('empty'), width: 18),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Photo grid — see photo_grid.dart ─────────────────────────────────────────

// ── Trip context card ─────────────────────────────────────────────────────────

class _TripContextCard extends StatelessWidget {
  final String passengerName;
  final String pickupAddress;
  final String dropOffAddress;

  const _TripContextCard({
    required this.passengerName,
    required this.pickupAddress,
    required this.dropOffAddress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryPurple.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryPurple.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_outline_rounded,
                  size: 14, color: AppColors.primaryPurple),
              const SizedBox(width: 6),
              Text(
                passengerName,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _TripRow(
            icon: Icons.radio_button_unchecked_rounded,
            label: pickupAddress,
          ),
          const SizedBox(height: 4),
          _TripRow(
            icon: Icons.circle,
            label: dropOffAddress,
          ),
        ],
      ),
    );
  }
}

class _TripRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _TripRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 10, color: AppColors.primaryPurple),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.subtext(context),
            ),
          ),
        ),
      ],
    );
  }
}

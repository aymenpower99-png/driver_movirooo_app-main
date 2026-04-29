// lib/pages/tracking/widgets/report/ride_issue.dart

import 'package:flutter/material.dart';

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

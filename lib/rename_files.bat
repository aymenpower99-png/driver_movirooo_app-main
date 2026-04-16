@echo off
cd /d "C:\dev\flutter-apps\driver_movirooo_app-main\lib"

echo Renaming Flutter files to lower_case_with_underscores...

rem 1. LoginDriver.dart
move "pages\auth\LoginDriver.dart" "pages\auth\login_driver.dart"

rem 2. _DriverCard.dart
move "pages\tabs [driver]\ActiveRide\_DriverCard.dart" "pages\tabs [driver]\ActiveRide\driver_card.dart"

rem 3. _NavigationBar.dart
move "pages\tabs [driver]\ActiveRide\_NavigationBar.dart" "pages\tabs [driver]\ActiveRide\navigation_bar.dart"

rem 4. _SlideToComplete.dart
move "pages\tabs [driver]\ActiveRide\_SlideToComplete.dart" "pages\tabs [driver]\ActiveRide\slide_to_complete.dart"

rem 5. EarningsTabs.dart
move "pages\tabs [driver]\Earnings\EarningsTabs.dart" "pages\tabs [driver]\Earnings\earnings_tabs.dart"

rem 6. _EarningsChart.dart
move "pages\tabs [driver]\Earnings\_EarningsChart.dart" "pages\tabs [driver]\Earnings\earnings_chart.dart"

rem 7. _EarningsHeader.dart
move "pages\tabs [driver]\Earnings\_EarningsHeader.dart" "pages\tabs [driver]\Earnings\earnings_header.dart"

rem 8. _EarningsSummaryCard.dart
move "pages\tabs [driver]\Earnings\_EarningsSummaryCard.dart" "pages\tabs [driver]\Earnings\earnings_summary_card.dart"

rem 9. _MonthlyBreakdown.dart
move "pages\tabs [driver]\Earnings\_MonthlyBreakdown.dart" "pages\tabs [driver]\Earnings\monthly_breakdown.dart"

rem 10. _RecentMonths.dart
move "pages\tabs [driver]\Earnings\_RecentMonths.dart" "pages\tabs [driver]\Earnings\recent_months.dart"

rem 11. _StatsRow.dart
move "pages\tabs [driver]\Earnings\_StatsRow.dart" "pages\tabs [driver]\Earnings\stats_row.dart"

rem 12. _ChatInput.dart
move "pages\tabs [driver]\chat\_ChatInput.dart" "pages\tabs [driver]\chat\chat_input.dart"

rem 13. _ChatMessage.dart
move "pages\tabs [driver]\chat\_ChatMessage.dart" "pages\tabs [driver]\chat\chat_message.dart"

rem 14. _TranslationBanner.dart
move "pages\tabs [driver]\chat\_TranslationBanner.dart" "pages\tabs [driver]\chat\translation_banner.dart"

rem 15. _VoiceMessageBubble.dart
move "pages\tabs [driver]\chat\_VoiceMessageBubble.dart" "pages\tabs [driver]\chat\voice_message_bubble.dart"

rem 16. TermsOfUsePage.dart
move "pages\tabs [driver]\profile\privacy_terms\TermsOfUsePage.dart" "pages\tabs [driver]\profile\privacy_terms\terms_of_use_page.dart"

rem 17. _IssueTypeSelector.dart
move "pages\tabs [driver]\profile\rate\_IssueTypeSelector.dart" "pages\tabs [driver]\profile\rate\issue_type_selector.dart"

rem 18. _EtaBottomSheet.dart
move "pages\tabs [driver]\ride\_EtaBottomSheet.dart" "pages\tabs [driver]\ride\eta_bottom_sheet.dart"

rem 19. _RouteCard.dart
move "pages\tabs [driver]\ride\_RouteCard.dart" "pages\tabs [driver]\ride\route_card.dart"

rem 20. _TopBar.dart
move "pages\tabs [driver]\widgets\_TopBar.dart" "pages\tabs [driver]\widgets\top_bar.dart"

echo.
echo Done! All 20 files renamed.
echo You can now delete this script: del "%~f0"
pause

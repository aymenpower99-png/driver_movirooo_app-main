import 'package:flutter/material.dart';
import 'package:moviroo_driver_app/routing/router.dart';
import 'package:moviroo_driver_app/theme/app_colors.dart';

class RatePassengerPage extends StatefulWidget {
  const RatePassengerPage({super.key});

  @override
  State<RatePassengerPage> createState() => _RatePassengerPageState();
}

class _RatePassengerPageState extends State<RatePassengerPage> {
  int _rating = 4;
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              Container(
                width: 72, height: 72,
             
                child:  ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset('images/lsnn.png', width: 120, height: 120, fit: BoxFit.cover),
              ),
              ),

              const SizedBox(height: 20),

              Text('Rate your Passenger',
                  style: TextStyle(
                    color: AppColors.text(context),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  )),
              const SizedBox(height: 8),
              Text('How was your trip with Marcus?',
                  style: TextStyle(
                    color: AppColors.subtext(context),
                    fontSize: 14,
                  )),

              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final filled = i < _rating;
                  return GestureDetector(
                    onTap: () => setState(() => _rating = i + 1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          filled ? Icons.star_rounded : Icons.star_outline_rounded,
                          key: ValueKey(filled),
                          color: filled
                              ? AppColors.primaryPurple
                              : AppColors.border(context),
                          size: 40,
                        ),
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 28),

              Align(
                alignment: Alignment.centerLeft,
                child: Text('Add a note (optional)',
                    style: TextStyle(
                      color: AppColors.text(context),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    )),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _noteController,
                maxLines: 3,
                style: TextStyle(
                    color: AppColors.text(context), fontSize: 14),
                decoration: InputDecoration(
                  hintText:
                      'Great passenger, was ready at the\npickup location...',
                  hintStyle: TextStyle(
                      color: AppColors.subtext(context), fontSize: 13),
                  filled: true,
                  fillColor: AppColors.surface(context),
                  contentPadding: const EdgeInsets.all(14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        BorderSide(color: AppColors.border(context)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        BorderSide(color: AppColors.border(context)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                        color: AppColors.primaryPurple, width: 1.5),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface(context),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border(context)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Safety issues?',
                              style: TextStyle(
                                color: AppColors.text(context),
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              )),
                          const SizedBox(height: 2),
                          Text('Let us know if anything went wrong.',
                              style: TextStyle(
                                color: AppColors.subtext(context),
                                fontSize: 12,
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.flag_outlined,
                          size: 14, color: Colors.red),
                      label: const Text('Report',
                          style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w700,
                              fontSize: 13)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: Colors.red.withOpacity(0.40)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () =>
                      AppRouter.clearAndGo(context, AppRouter.driverDashboard),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Submit Rating',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      )),
                ),
              ),

              const SizedBox(height: 14),

              TextButton(
                onPressed: () =>
                    AppRouter.clearAndGo(context, AppRouter.driverDashboard),
                child: Text('Skip for now',
                    style: TextStyle(
                      color: AppColors.subtext(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
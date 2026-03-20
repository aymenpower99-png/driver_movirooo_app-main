import 'package:flutter/material.dart';
import 'package:moviroo_driver_app/pages/tabs%20%5Bdriver%5D/widgets/_TopBar.dart';
import 'package:moviroo_driver_app/routing/router.dart';
import 'package:moviroo_driver_app/theme/app_colors.dart';

class RatePage extends StatefulWidget {
  const RatePage({super.key});

  @override
  State<RatePage> createState() => _RatePageState();
}

class _RatePageState extends State<RatePage> {
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
              TopBar(title: 'Rate our App'  ),
                                        const SizedBox(height:120),

              Container(
                width: 72, height: 72,
             
                child:  ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset('images/lsnn.png', width: 120, height: 120, fit: BoxFit.cover),
              ),
              ),

              const SizedBox(height: 20),

              Text('Rate our App',
                  style: TextStyle(
                    color: AppColors.text(context),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  )),
              const SizedBox(height: 8),
              Text('How was your experience with our app?',
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
                      'Share your feedback to help us improve the app',
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

             
            ],
          ),
        ),
      ),
    );
  }
}
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';

class EmployerHomeCarousel extends StatefulWidget {
  const EmployerHomeCarousel({super.key, required this.onTap});

  final ValueChanged<int> onTap;

  @override
  State<EmployerHomeCarousel> createState() => _EmployerHomeCarouselState();
}

class _EmployerHomeCarouselState extends State<EmployerHomeCarousel> {
  final PageController _pageController = PageController();

  Timer? _autoPlayTimer;

  int _currentPage = 0;

  static const _banners = [
    _CarouselItem(
      image: 'assets/images/employer/carousel_plumbing.png',
      title: 'Best Plumbing Services',
      subtitle: 'Fast & reliable workers near you',
    ),
    _CarouselItem(
      image: 'assets/images/employer/carousel_cleaning.png',
      title: 'Professional Cleaning',
      subtitle: 'Trusted workers for your home',
    ),
    _CarouselItem(
      image: 'assets/images/employer/carousel_electrical.png',
      title: 'Electrical Services',
      subtitle: 'Get skilled electricians nearby',
    ),
  ];

  @override
  void initState() {
    super.initState();

    _autoPlayTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_pageController.hasClients) {
        return;
      }

      final nextPage = (_currentPage + 1) % _banners.length;

      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _banners.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final banner = _banners[index];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: GestureDetector(
                  onTap: () {
                    widget.onTap(index);
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          banner.image,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.imagePlaceholder,
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.image_outlined,
                                size: 40,
                                color: AppColors.imagePlaceholderIcon,
                              ),
                            );
                          },
                        ),

                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.transparent,
                                AppColors.carouselOverlay,
                              ],
                            ),
                          ),
                        ),

                        Positioned(
                          left: 18,
                          right: 18,
                          bottom: 17,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                banner.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                banner.subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.carouselSubtitle,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banners.length, (index) {
            final isSelected = index == _currentPage;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isSelected ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.employerPrimary
                    : AppColors.border,
                borderRadius: BorderRadius.circular(8),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _CarouselItem {
  const _CarouselItem({
    required this.image,
    required this.title,
    required this.subtitle,
  });

  final String image;
  final String title;
  final String subtitle;
}

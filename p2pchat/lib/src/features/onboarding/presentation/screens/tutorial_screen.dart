import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<TutorialData> _slides = [
    TutorialData(
      icon: Icons.hub_rounded,
      title: 'Serverless P2P Network',
      description: 'Your messages do not travel through central servers. Instead, they bounce directly between peers in an advanced local and global gossip network.',
      gradientColors: [Color(0xFF1565C0), Color(0xFF00897B)],
    ),
    TutorialData(
      icon: Icons.qr_code_scanner_rounded,
      title: 'Direct QR Code Invitation',
      description: 'Establish high-fidelity cryptographic trust by scanning contact QR codes in person or sharing secure invitations instantly without any centralized identity registers.',
      gradientColors: [Color(0xFF00897B), Color(0xFF8E24AA)],
    ),
    TutorialData(
      icon: Icons.security_rounded,
      title: 'Cryptographic Privacy',
      description: 'Every envelope is digitally signed via Ed25519 and sealed using dryoc NaCl-compatible encryption. Unauthorized eavesdroppers cannot read, forge, or tamper with your chats.',
      gradientColors: [Color(0xFF8E24AA), Color(0xFF1565C0)],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLastPage = _currentPage == _slides.length - 1;

    return Scaffold(
      body: Stack(
        children: [
          // Dynamic gradient background reflecting current slide
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _slides[_currentPage].gradientColors[0].withOpacity(0.08),
                  _slides[_currentPage].gradientColors[1].withOpacity(0.12),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: TextButton(
                      onPressed: () => context.go('/chats'),
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (int index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: _slides.length,
                    itemBuilder: (context, index) {
                      final slide = _slides[index];
                      return Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Center(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Icon block with premium custom gradient & glassmorphism shadow
                                Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: slide.gradientColors,
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(40),
                                    boxShadow: [
                                      BoxShadow(
                                        color: slide.gradientColors[0].withOpacity(0.4),
                                        blurRadius: 30,
                                        offset: const Offset(0, 15),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    slide.icon,
                                    size: 68,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 32),
                                Text(
                                  slide.title,
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  slide.description,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                                    height: 1.6,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Indicator and CTA Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Page Indicators
                      Row(
                        children: List.generate(
                          _slides.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(right: 8),
                            height: 8,
                            width: _currentPage == index ? 24 : 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      // Navigation Button (Circular Next/Done FAB style)
                      FloatingActionButton(
                        onPressed: () {
                          if (isLastPage) {
                            context.go('/chats');
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOutCubic,
                            );
                          }
                        },
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Icon(
                            isLastPage ? Icons.check_rounded : Icons.arrow_forward_rounded,
                            key: ValueKey<bool>(isLastPage),
                          ),
                        ),
                      ),
                    ],
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

class TutorialData {
  final IconData icon;
  final String title;
  final String description;
  final List<Color> gradientColors;

  TutorialData({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradientColors,
  });
}

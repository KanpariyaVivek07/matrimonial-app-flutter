import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:textformfield/Screens/Payment/Payment_Screen.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  Timer? _offerTimer;
  Duration _remaining = const Duration(minutes: 5);
  int? _selectedPlanIndex;

  final List<Map<String, dynamic>> plans = [
    {
      "title": "Basic Plan",
      "price": 1000,
      "desc": "🔍 View 20 profiles/day",
      "features": [
        "20 profile views per day",
        "Basic search filters",
        "Limited matches"
      ],
    },
    {
      "title": "Premium Plan",
      "price": 3000,
      "desc": "💬 Unlimited views + Chat",
      "features": [
        "Unlimited profile views",
        "Unlimited messaging",
        "Advanced search filters",
        "Priority customer support"
      ],
    },
    {
      "title": "Gold Plan",
      "price": 5000,
      "desc": "🌟 Premium + Highlight Profile",
      "features": [
        "All Premium features",
        "Profile highlighting",
        "Top of search results",
        "Verified badge",
        "Exclusive matchmaking"
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _startOfferTimer();
  }

  void _startOfferTimer() {
    _offerTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining.inSeconds <= 0) {
        _offerTimer?.cancel();
        setState(() {
          _remaining = Duration.zero;
          _selectedPlanIndex = null;
        });
      } else {
        setState(() {
          _remaining -= const Duration(seconds: 1);
        });
      }
    });
  }

  @override
  void dispose() {
    _offerTimer?.cancel();
    super.dispose();
  }

  void _selectPlan(int index) {
    setState(() {
      _selectedPlanIndex = index;
    });

    final plan = plans[index];
    final bool isOfferActive = _remaining.inSeconds > 0;
    final double price = plan['price'].toDouble();
    final double discount = isOfferActive ? 0.2 : 0.0;
    final double finalPrice = price * (1 - discount);

    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Row(
    //       children: [
    //         const Icon(Icons.check_circle, color: Colors.green),
    //         const SizedBox(width: 10),
    //         Expanded(
    //           child: Text(
    //             "Selected: ${plan['title']} for ₹${finalPrice.toStringAsFixed(0)}",
    //             style: const TextStyle(fontSize: 16),
    //           ),
    //         ),
    //       ],
    //     ),
    //     backgroundColor: Colors.black87,
    //     duration: const Duration(seconds: 2),
    //     behavior: SnackBarBehavior.floating,
    //     shape: RoundedRectangleBorder(
    //       borderRadius: BorderRadius.circular(10),
    //     ),
    //   ),
    // );
  }

  void _proceedToPayment() {
    if (_selectedPlanIndex == null) return;

    final plan = plans[_selectedPlanIndex!];
    final bool isOfferActive = _remaining.inSeconds > 0;
    final double price = plan['price'].toDouble();
    final double discount = isOfferActive ? 0.2 : 0.0;
    final double finalPrice = price * (1 - discount);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          plan: plan,
          price: finalPrice,
          isDiscounted: isOfferActive,
        ),
      ),
    );
  }

  Widget _buildTimerBanner() {
    if (_remaining.inSeconds <= 0) return const SizedBox.shrink();

    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(_remaining.inMinutes.remainder(60));
    final seconds = twoDigits(_remaining.inSeconds.remainder(60));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade400, Colors.orange.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.local_fire_department, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            "Limited Offer! Valid for $minutes:$seconds",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureList(List<String> features) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: features.map((feature) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle, size: 16, color: Colors.white70),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  feature,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan, int index) {
    final isGold = plan['title'] == "Gold Plan";
    final isPremium = plan['title'] == "Premium Plan";
    final double price = plan['price'].toDouble();

    final bool isOfferActive = _remaining.inSeconds > 0;
    final double discount = isOfferActive ? 0.2 : 0.0;
    final double discountedPrice = price * (1 - discount);
    final bool isSelected = _selectedPlanIndex == index;

    return GestureDetector(
      onTap: () => _selectPlan(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isGold
                ? [Colors.amber.shade400, Colors.orange.shade600]
                : isPremium
                ? [Colors.purple.shade300, Colors.purple.shade700]
                : [Colors.deepPurple.shade200, Colors.deepPurple.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            )
          ],
          border: isSelected
              ? Border.all(color: Colors.white, width: 2)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top badges
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (isOfferActive)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade700,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "20% OFF",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                if (isGold)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "⭐ POPULAR",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              plan['title'],
              style: GoogleFonts.montserrat(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              plan['desc'],
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 15),
            _buildFeatureList(List<String>.from(plan['features'])),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      if (isOfferActive)
                        TextSpan(
                          text: "₹${price.toStringAsFixed(0)} ",
                          style: const TextStyle(
                            color: Colors.white70,
                            decoration: TextDecoration.lineThrough,
                            fontSize: 16,
                          ),
                        ),
                      TextSpan(
                        text: "₹${discountedPrice.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const TextSpan(
                        text: "/month",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: isOfferActive ? () => _selectPlan(index) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    isOfferActive ? Colors.white : Colors.grey.shade400,
                    foregroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                  child: Text(
                    isOfferActive ? "SELECT" : "EXPIRED",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text(
          "Subscription Plans",
          style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        // centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  _buildTimerBanner(),
                  const SizedBox(height: 10),
                  ...plans.asMap().entries.map((entry) {
                    return _buildPlanCard(entry.value, entry.key);
                  }).toList(),
                  const SizedBox(height: 20),
                  const Text(
                    "All plans include:\n- Secure payment processing\n- Cancel anytime\n- 7-day money back guarantee",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_selectedPlanIndex != null && _remaining.inSeconds > 0)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Selected: ${plans[_selectedPlanIndex!]['title']}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text:
                                "₹${(plans[_selectedPlanIndex!]['price'] * 0.8).toStringAsFixed(0)}",
                                style: TextStyle(
                                  color: Colors.deepPurple,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const TextSpan(
                                text: "/month",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                              const TextSpan(text: "  "),
                              TextSpan(
                                text:
                                "₹${plans[_selectedPlanIndex!]['price'].toStringAsFixed(0)}",
                                style: const TextStyle(
                                  color: Colors.grey,
                                  decoration: TextDecoration.lineThrough,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _proceedToPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                    ),
                    child: const Text(
                      "Continue",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
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
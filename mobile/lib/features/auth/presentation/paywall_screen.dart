import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../data/subscription_provider.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  List<Package> _packages = [];
  bool _isLoading = true;
  bool _isPurchasing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      if (current != null) {
        setState(() => _packages = current.availablePackages);
      } else {
        setState(
          () => _errorMessage = 'No subscription plans available at this time.',
        );
      }
    } on PlatformException catch (e) {
      setState(() => _errorMessage = 'Unable to load plans: ${e.message}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _purchase(Package package) async {
    setState(() {
      _isPurchasing = true;
      _errorMessage = null;
    });
    try {
      final result = await Purchases.purchase(
        PurchaseParams.package(package),
      );
      final isActive = result.customerInfo.entitlements.active
          .containsKey('premium_access');
      if (isActive) {
        // Invalidate subscription provider so the app updates immediately
        ref.invalidate(isSubscribedProvider);
        if (mounted) {
          context.goNamed('programs');
        }
      }
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        setState(() => _errorMessage = 'Purchase failed: ${e.message}');
      }
    } finally {
      if (mounted) setState(() => _isPurchasing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscribe'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _buildContent(context),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _packages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _loadOfferings,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Unlock All Programs',
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Get unlimited access to all coach-designed programs, video guidance, and progress tracking.',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              _errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
              textAlign: TextAlign.center,
            ),
          ),
        ..._packages.map(
          (pkg) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _PackageCard(
              package: pkg,
              isPurchasing: _isPurchasing,
              onPurchase: () => _purchase(pkg),
            ),
          ),
        ),
        const Spacer(),
        Text(
          'Payment will be charged to your App Store or Google Play account. Subscription auto-renews unless cancelled at least 24 hours before the end of the current period.',
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _PackageCard extends StatelessWidget {
  const _PackageCard({
    required this.package,
    required this.isPurchasing,
    required this.onPurchase,
  });

  final Package package;
  final bool isPurchasing;
  final VoidCallback onPurchase;

  @override
  Widget build(BuildContext context) {
    final storeProduct = package.storeProduct;
    return Card(
      child: InkWell(
        onTap: isPurchasing ? null : onPurchase,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      storeProduct.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      storeProduct.description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(
                    storeProduct.priceString,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (isPurchasing)
                    const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

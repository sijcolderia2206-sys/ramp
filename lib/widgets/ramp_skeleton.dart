// lib/widgets/ramp_skeleton.dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Universal Shimmer Skeleton Loading Primitives & Domain Cards for RAMP
class RampSkeleton extends StatelessWidget {
  final Widget child;
  final bool enabled;

  const RampSkeleton({
    super.key,
    required this.child,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    return Shimmer.fromColors(
      baseColor: const Color(0xFFE2E8F0),
      highlightColor: const Color(0xFFF8FAFC),
      period: const Duration(milliseconds: 1200),
      child: child,
    );
  }
}

/// Generic Skeleton Box Shape
class RampSkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const RampSkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Generic Skeleton Line Shape
class RampSkeletonLine extends StatelessWidget {
  final double? width;
  final double height;

  const RampSkeletonLine({
    super.key,
    this.width,
    this.height = 12,
  });

  @override
  Widget build(BuildContext context) {
    return RampSkeletonBox(
      width: width ?? double.infinity,
      height: height,
      borderRadius: 4,
    );
  }
}

/// Domain Skeleton: Rental Unit Card Loader
class UnitCardSkeleton extends StatelessWidget {
  const UnitCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return RampSkeleton(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const RampSkeletonBox(width: 140, height: 18),
                const RampSkeletonBox(width: 70, height: 24, borderRadius: 12),
              ],
            ),
            const SizedBox(height: 12),
            const RampSkeletonLine(width: 200, height: 14),
            const SizedBox(height: 16),
            Row(
              children: [
                const RampSkeletonBox(width: 60, height: 12),
                const SizedBox(width: 16),
                const RampSkeletonBox(width: 60, height: 12),
                const Spacer(),
                const RampSkeletonBox(width: 90, height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Domain Skeleton: Tenant Row Item Loader
class TenantCardSkeleton extends StatelessWidget {
  const TenantCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return RampSkeleton(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const RampSkeletonBox(width: 48, height: 48, borderRadius: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  RampSkeletonLine(width: 120, height: 16),
                  SizedBox(height: 8),
                  RampSkeletonLine(width: 180, height: 12),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const RampSkeletonBox(width: 60, height: 24, borderRadius: 12),
          ],
        ),
      ),
    );
  }
}

/// Domain Skeleton: Payment Ledger Card Loader
class PaymentCardSkeleton extends StatelessWidget {
  const PaymentCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return RampSkeleton(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                RampSkeletonLine(width: 110, height: 16),
                SizedBox(height: 6),
                RampSkeletonLine(width: 150, height: 12),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                RampSkeletonLine(width: 80, height: 16),
                SizedBox(height: 6),
                RampSkeletonBox(width: 50, height: 18, borderRadius: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Domain Skeleton: Dashboard KPI Metrics Loader
class DashboardMetricsSkeleton extends StatelessWidget {
  const DashboardMetricsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return RampSkeleton(
      child: Column(
        children: [
          Container(
            height: 120,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      RampSkeletonLine(width: 100, height: 14),
                      SizedBox(height: 10),
                      RampSkeletonLine(width: 160, height: 26),
                      SizedBox(height: 8),
                      RampSkeletonLine(width: 120, height: 12),
                    ],
                  ),
                ),
                const RampSkeletonBox(width: 64, height: 64, borderRadius: 32),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
              Expanded(child: RampSkeletonBox(width: double.infinity, height: 90, borderRadius: 16)),
              SizedBox(width: 12),
              Expanded(child: RampSkeletonBox(width: double.infinity, height: 90, borderRadius: 16)),
            ],
          ),
        ],
      ),
    );
  }
}

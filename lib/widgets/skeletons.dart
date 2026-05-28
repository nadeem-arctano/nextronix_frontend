import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:shimmer/shimmer.dart';

/// Shimmer-aware skeleton primitives.
///
/// All public widgets here render a soft shimmering placeholder that mirrors
/// the shape of the real content — table rows, cards, charts, dashboard tiles.
/// Use these as the loading state for any screen that fetches data.
///
/// Usage:
///   isLoading
///       ? const TableSkeleton(rows: 8, columns: 5)
///       : MyRealTable()
class _ShimmerColors {
  static Color base(BuildContext context) {
    final theme = ShadTheme.of(context);
    return theme.brightness == Brightness.dark
        ? theme.colorScheme.muted.withValues(alpha: 0.45)
        : theme.colorScheme.muted.withValues(alpha: 0.55);
  }

  static Color highlight(BuildContext context) {
    final theme = ShadTheme.of(context);
    return theme.brightness == Brightness.dark
        ? theme.colorScheme.muted.withValues(alpha: 0.25)
        : Colors.white.withValues(alpha: 0.85);
  }
}

/// Single skeleton bar — common building block for everything else.
class SkeletonBar extends StatelessWidget {
  final double? width;
  final double height;
  final BorderRadius borderRadius;

  const SkeletonBar({
    super.key,
    this.width,
    this.height = 12,
    this.borderRadius = const BorderRadius.all(Radius.circular(6)),
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: _ShimmerColors.base(context),
      highlightColor: _ShimmerColors.highlight(context),
      period: const Duration(milliseconds: 1100),
      child: Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: _ShimmerColors.base(context),
          borderRadius: borderRadius,
        ),
      ),
    );
  }
}

/// Circular skeleton (avatars, icons).
class SkeletonCircle extends StatelessWidget {
  final double size;
  const SkeletonCircle({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: _ShimmerColors.base(context),
      highlightColor: _ShimmerColors.highlight(context),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: _ShimmerColors.base(context),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// Skeleton replacement for a paginated list table.
class TableSkeleton extends StatelessWidget {
  final int rows;
  final int columns;
  final bool showHeader;
  final double rowHeight;

  const TableSkeleton({
    super.key,
    this.rows = 8,
    this.columns = 5,
    this.showHeader = true,
    this.rowHeight = 56,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return ShadCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showHeader)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: theme.colorScheme.muted.withValues(alpha: 0.3),
                border: Border(
                  bottom: BorderSide(color: theme.colorScheme.border),
                ),
              ),
              child: Row(
                children: List.generate(
                  columns,
                  (i) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: i == columns - 1 ? 0 : 16,
                      ),
                      child: const SkeletonBar(width: 80, height: 10),
                    ),
                  ),
                ),
              ),
            ),
          for (int r = 0; r < rows; r++) ...[
            Container(
              height: rowHeight,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: List.generate(
                  columns,
                  (i) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: i == columns - 1 ? 0 : 16,
                      ),
                      child: SkeletonBar(
                        width: i == 0 ? 140 : null,
                        height: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (r < rows - 1)
              Divider(height: 1, color: theme.colorScheme.border),
          ],
        ],
      ),
    );
  }
}

/// Generic card skeleton (settings page sections, detail panes).
class CardSkeleton extends StatelessWidget {
  final int lines;
  final double? height;
  final EdgeInsetsGeometry padding;

  const CardSkeleton({
    super.key,
    this.lines = 4,
    this.height,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    return ShadCard(
      child: SizedBox(
        height: height,
        child: Padding(
          padding: padding,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SkeletonBar(width: 160, height: 14),
                      const SizedBox(height: 16),
                      for (int i = 0; i < lines; i++) ...[
                        SkeletonBar(
                          width: i.isEven ? double.infinity : 240,
                          height: 10,
                        ),
                        if (i < lines - 1) const SizedBox(height: 10),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Dashboard layout skeleton: 4 KPI tiles + chart + 2 lists.
class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final cols = width < 700 ? 2 : 4;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonBar(width: 220, height: 22),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: cols,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 2.4,
            children: List.generate(4, (_) => const CardSkeleton(lines: 2)),
          ),
          const SizedBox(height: 24),
          const SizedBox(height: 280, child: CardSkeleton(lines: 6)),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(child: SizedBox(height: 220, child: CardSkeleton())),
              SizedBox(width: 16),
              Expanded(child: SizedBox(height: 220, child: CardSkeleton())),
            ],
          ),
        ],
      ),
    );
  }
}

/// Form skeleton — labels + inputs + a primary button stub.
class FormSkeleton extends StatelessWidget {
  final int fields;
  const FormSkeleton({super.key, this.fields = 4});

  @override
  Widget build(BuildContext context) {
    return ShadCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < fields; i++) ...[
              const SkeletonBar(width: 120, height: 10),
              const SizedBox(height: 6),
              const SkeletonBar(height: 38),
              const SizedBox(height: 18),
            ],
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: SkeletonBar(
                width: 140,
                height: 36,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Chart placeholder — a tall card with bars of varying heights.
class ChartSkeleton extends StatelessWidget {
  final double height;
  final int bars;

  const ChartSkeleton({super.key, this.height = 260, this.bars = 12});

  @override
  Widget build(BuildContext context) {
    return ShadCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          height: height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SkeletonBar(width: 180, height: 14),
              const SizedBox(height: 16),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(
                    bars,
                    (i) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: SkeletonBar(
                          height: 30 + (i % 5) * 20.0,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

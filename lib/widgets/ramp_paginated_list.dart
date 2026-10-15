// lib/widgets/ramp_paginated_list.dart
import 'package:flutter/material.dart';
import 'ramp_skeleton.dart';
import 'ramp_empty_state.dart';
import '../theme.dart';

/// Reusable Infinite Scroll Paginated List View for RAMP
/// Connects seamlessly with Supabase range queries & Riverpod state.
class RampPaginatedListView<T> extends StatefulWidget {
  final Future<List<T>> Function(int pageIndex, int pageSize) fetchPage;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget Function(BuildContext context)? skeletonLoader;
  final Widget Function(BuildContext context)? emptyState;
  final int pageSize;
  final EdgeInsetsGeometry padding;
  final Future<void> Function()? onRefresh;

  const RampPaginatedListView({
    super.key,
    required this.fetchPage,
    required this.itemBuilder,
    this.skeletonLoader,
    this.emptyState,
    this.pageSize = 15,
    this.padding = const EdgeInsets.all(16),
    this.onRefresh,
  });

  @override
  State<RampPaginatedListView<T>> createState() => _RampPaginatedListViewState<T>();
}

class _RampPaginatedListViewState<T> extends State<RampPaginatedListView<T>> {
  final ScrollController _scrollController = ScrollController();
  final List<T> _items = [];

  int _currentPage = 0;
  bool _isLoadingInitial = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadInitialPage();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    // Trigger load when user scrolls past 80% threshold
    if (currentScroll >= (maxScroll * 0.8) && !_isLoadingMore && _hasMore && !_isLoadingInitial) {
      _loadNextPage();
    }
  }

  Future<void> _loadInitialPage() async {
    setState(() {
      _isLoadingInitial = true;
      _errorMessage = null;
      _currentPage = 0;
      _items.clear();
      _hasMore = true;
    });

    try {
      final newItems = await widget.fetchPage(0, widget.pageSize);
      if (mounted) {
        setState(() {
          _items.addAll(newItems);
          _isLoadingInitial = false;
          _hasMore = newItems.length >= widget.pageSize;
          _currentPage = 1;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingInitial = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _loadNextPage() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final newItems = await widget.fetchPage(_currentPage, widget.pageSize);
      if (mounted) {
        setState(() {
          _items.addAll(newItems);
          _isLoadingMore = false;
          _hasMore = newItems.length >= widget.pageSize;
          _currentPage++;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingInitial) {
      return widget.skeletonLoader?.call(context) ??
          ListView.builder(
            padding: widget.padding,
            itemCount: 5,
            itemBuilder: (context, index) => const UnitCardSkeleton(),
          );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: RampTheme.errorRed),
              const SizedBox(height: 12),
              Text(
                'Failed to load data',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(_errorMessage!, style: const TextStyle(fontSize: 12, color: RampTheme.textSecondary)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadInitialPage,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_items.isEmpty) {
      return widget.emptyState?.call(context) ??
          RampEmptyState(
            title: 'No Data Available',
            description: 'There are currently no records to display.',
            onActionPressed: _loadInitialPage,
            actionLabel: 'Refresh',
          );
    }

    Widget content = ListView.builder(
      controller: _scrollController,
      padding: widget.padding,
      itemCount: _items.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _items.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(RampTheme.primaryBlue),
                ),
              ),
            ),
          );
        }
        return widget.itemBuilder(context, _items[index], index);
      },
    );

    if (widget.onRefresh != null) {
      return RefreshIndicator(
        onRefresh: () async {
          await widget.onRefresh!();
          await _loadInitialPage();
        },
        color: RampTheme.primaryBlue,
        child: content,
      );
    }

    return content;
  }
}

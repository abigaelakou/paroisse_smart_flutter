import 'package:flutter/material.dart';
import 'dart:async';

typedef ItemBuilder<T> = Widget Function(BuildContext context, T item);
typedef LoadMoreCallback = Future<void> Function();

class HorizontalCarousel<T> extends StatefulWidget {
  final List<T> items;
  final ItemBuilder<T> itemBuilder;
  final ScrollController? controller;
  final LoadMoreCallback? onLoadMore;
  final double itemWidth;
  final double height;
  final bool autoScroll;
  final Duration scrollDuration;

  const HorizontalCarousel({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.controller,
    this.onLoadMore,
    this.itemWidth = 250,
    this.height = 200,
    this.autoScroll = false,
    this.scrollDuration = const Duration(seconds: 4),
  });

  @override
  State<HorizontalCarousel<T>> createState() => _HorizontalCarouselState<T>();
}

class _HorizontalCarouselState<T> extends State<HorizontalCarousel<T>> {
  late ScrollController _scrollController;
  bool _isLoadingMore = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_onScroll);

    if (widget.autoScroll) {
      _timer = Timer.periodic(widget.scrollDuration, (_) {
        if (_scrollController.hasClients && widget.items.isNotEmpty) {
          double maxScroll = _scrollController.position.maxScrollExtent;
          double nextPos = _scrollController.offset + widget.itemWidth + 12;
          if (nextPos >= maxScroll) nextPos = 0;
          _scrollController.animateTo(
            nextPos,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  void _onScroll() {
    if (widget.onLoadMore == null || _isLoadingMore) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (widget.onLoadMore == null) return;
    setState(() => _isLoadingMore = true);
    await widget.onLoadMore!();
    if (mounted) setState(() => _isLoadingMore = false);
  }

  @override
  void dispose() {
    _timer?.cancel();
    if (widget.controller == null) _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = widget.items.length + (_isLoadingMore ? 1 : 0);

    return SizedBox(
      height: widget.height,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        itemBuilder: (context, index) {
          if (index >= widget.items.length) {
            return Container(
              width: 80,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple[100]!, Colors.purple[200]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.purple[600]!,
                  ),
                  strokeWidth: 3,
                ),
              ),
            );
          }
          final item = widget.items[index];
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: widget.itemWidth,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: widget.itemBuilder(context, item),
          );
        },
      ),
    );
  }
}

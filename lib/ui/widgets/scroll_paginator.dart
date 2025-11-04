import 'package:flutter/material.dart';

class ScrollPaginator extends StatefulWidget {
  const ScrollPaginator({
    super.key,
    required this.child,
    required this.onFetchMore,
    required this.hasMore,
    this.isLoadingMore = false,
    this.padding = const EdgeInsets.all(0),
  });

  final Widget child;
  final Future<void> Function() onFetchMore;
  final bool hasMore;
  final bool isLoadingMore;
  final EdgeInsets padding;

  @override
  State<ScrollPaginator> createState() => _ScrollPaginatorState();
}

class _ScrollPaginatorState extends State<ScrollPaginator> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!widget.hasMore || widget.isLoadingMore) return;
    if (_controller.position.pixels >= _controller.position.maxScrollExtent - 100) {
      widget.onFetchMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: PrimaryScrollController(
        controller: _controller,
        child: widget.child,
      ),
    );
  }
}

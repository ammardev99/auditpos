import 'package:auditpos/shell/audit_sessions_data/data/after_model.dart';

class AfterAuditItemsState {
  final bool loading;
  final List<AfterAuditItemModel> items;
  final bool showOnlyMismatches;
  final String searchQuery; // Add this!

  AfterAuditItemsState({
    this.loading = false,
    this.items = const [],
    this.showOnlyMismatches = true,
    this.searchQuery = '', // Add this!
  });

  // Ensure visibleItems handles the filter logic cleanly
  List<AfterAuditItemModel> get visibleItems {
    List<AfterAuditItemModel> filtered = items;

    if (showOnlyMismatches) {
      filtered = filtered.where((item) => item.isMismatch && !item.isApproved).toList();
    }

    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((item) =>
          item.productName.toLowerCase().contains(query) ||
          item.barcode.toLowerCase().contains(query)).toList();
    }

    return filtered;
  }

  int get totalMismatches => items.where((item) => item.isMismatch && !item.isApproved).length;

  AfterAuditItemsState copyWith({
    bool? loading,
    List<AfterAuditItemModel>? items,
    bool? showOnlyMismatches,
    String? searchQuery, // Add this!
  }) {
    return AfterAuditItemsState(
      loading: loading ?? this.loading,
      items: items ?? this.items,
      showOnlyMismatches: showOnlyMismatches ?? this.showOnlyMismatches,
      searchQuery: searchQuery ?? this.searchQuery, // Add this!
    );
  }
}
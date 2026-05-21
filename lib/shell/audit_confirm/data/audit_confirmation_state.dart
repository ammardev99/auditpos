import 'confirmation_item_model.dart';

class AuditConfirmationState {
  final bool isLoading;
  final List<ConfirmationItemModel> items;
  final bool showMismatchesOnly;
  final String searchQuery;
  final String? errorMessage;

  AuditConfirmationState({
    this.isLoading = false,
    this.items = const [],
    this.showMismatchesOnly = true, // Default to true as requested
    this.searchQuery = '',
    this.errorMessage,
  });

  // Client-side mapping filters rows by typing query locally
  List<ConfirmationItemModel> get computedVisibleItems {
    List<ConfirmationItemModel> outputList = items;

    if (searchQuery.isNotEmpty) {
      final textQuery = searchQuery.toLowerCase();
      outputList = outputList.where((item) =>
          item.productName.toLowerCase().contains(textQuery) ||
          item.barcode.toLowerCase().contains(textQuery)).toList();
    }
    return outputList;
  }

  AuditConfirmationState copyWith({
    bool? isLoading,
    List<ConfirmationItemModel>? items,
    bool? showMismatchesOnly,
    String? searchQuery,
    String? errorMessage,
  }) {
    return AuditConfirmationState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      showMismatchesOnly: showMismatchesOnly ?? this.showMismatchesOnly,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
    );
  }
}
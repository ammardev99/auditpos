// // loading
// // auditSession
// // items
// // filteredItems
// // searchQuery
// // completed
// // error
// import '../../../config/audit/data/audit_session_model.dart';
// import 'audit_item_model.dart';

// class AuditState {
//   final bool loading;
//   final AuditSessionModel? session;
//   final List<AuditItemModel> items;
//   final List<AuditItemModel> filteredItems;
//   final String searchQuery;
//   final bool showOnlyMismatches; // UI filtering condition
//   final String? error;

//   AuditState({
//     this.loading = false,
//     this.session,
//     this.items = const [],
//     this.filteredItems = const [],
//     this.searchQuery = '',
//     this.showOnlyMismatches =
//         true, // Default to true to isolate mismatches right away
//     this.error,
//   });

//   int get totalMismatches =>
//       items.where((e) => e.isMismatch && !e.isApproved).length;

//   AuditState copyWith({
//     bool? loading,
//     AuditSessionModel? session,
//     List<AuditItemModel>? items,
//     List<AuditItemModel>? filteredItems,
//     String? searchQuery,
//     bool? showOnlyMismatches,
//     String? error,
//   }) {
//     return AuditState(
//       loading: loading ?? this.loading,
//       session: session ?? this.session,
//       items: items ?? this.items,
//       filteredItems: filteredItems ?? this.filteredItems,
//       searchQuery: searchQuery ?? this.searchQuery,
//       showOnlyMismatches: showOnlyMismatches ?? this.showOnlyMismatches,
//       error: error,
//     );
//   }
// }

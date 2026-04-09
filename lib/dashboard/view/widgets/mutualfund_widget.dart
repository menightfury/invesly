// part of '../dashboard_page.dart';

// class _MutualFundWidget extends StatefulWidget {
//   const _MutualFundWidget({super.key});

//   @override
//   State<_MutualFundWidget> createState() => _MutualFundWidgetState();
// }

// class _MutualFundWidgetState extends State<_MutualFundWidget> {
//   @override
//   Widget build(BuildContext context) {
//     final textTheme = Theme.of(context).textTheme;

//     return Section(
//       title: const Text('Mutual Funds'),
//       icon: const Icon(Icons.pie_chart_outline_rounded),
//       trailingIcon: GestureDetector(
//         onTap: () {
//           Navigator.of(context).push(GenreDetailsPage.route(AmcGenre.mf, filteredStats?.toList() ?? []));
//         },
//         child: const Icon(Icons.chevron_right_rounded),
//       ),
//       tiles: <Widget>[
//         SectionTile(
//           title: BlocBuilder<AccountsCubit, AccountsState>(
//             builder: (context, accountsState) {
//               return BlocBuilder<TransactionStatCubit, TransactionStatState>(
//                 builder: (context, statState) {
//                   if (accountsState.isLoaded && (statState.isInitial || statState.isEmpty)) {
//                     return EmptyWidget(label: Text('This is so empty.\n Add some transactions to see stats here.'));
//                   }

//                   final isError = accountsState.isError || statState.isError;
//                   final isLoading = !isError && (accountsState.isLoading || statState.isLoading);
//                   final stats = accountsState.isEmpty
//                       ? <TransactionStat>[]
//                       : statState is TransactionStatLoadedState
//                       ? statState.stats.where((stat) => stat.amc.genre == AmcGenre.mf).toList()
//                       : null;
//                   final totalAmount = stats?.fold<double>(0.0, (v, el) => v + el.totalAmount);
//                   stats?.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

//                   return Skeletonizer(
//                     enabled: isLoading,
//                     child: Column(
//                       children: <Widget>[
//                         // ~ Total amount
//                         BlocSelector<AppCubit, AppState, bool>(
//                           selector: (state) => state.isPrivateMode,
//                           builder: (context, isPrivateMode) {
//                             return CurrencyView(
//                               amount: totalAmount ?? 0.0,
//                               style: textTheme.headlineLarge?.copyWith(
//                                 color: isError ? context.colors.error : AmcGenre.mf.color,
//                               ),
//                               decimalsStyle: textTheme.headlineSmall?.copyWith(
//                                 color: isError ? context.colors.error : AmcGenre.mf.color,
//                               ),
//                               currencyStyle: textTheme.bodyMedium?.copyWith(
//                                 color: isError ? context.colors.error : AmcGenre.mf.color,
//                               ),
//                               privateMode: isPrivateMode,
//                               // compactView: snapshot.data! >= 1_00_00_000
//                             );
//                           },
//                         ),

//                         // ~ Holdings
//                         Text('${stats?.length ?? 0} holdings'),

//                         // ~ Top five holdings
//                         Section(
//                           margin: EdgeInsets.zero,
//                           tiles: List.generate(math.min(stats?.length ?? 0, 5), (i) {
//                             final stat = stats?.elementAt(i);

//                             return SectionTile(
//                               tileColor: Colors.white.withAlpha(100),
//                               // icon: isLoading
//                               //     ? Skeleton()
//                               //     : CircleAvatar(
//                               //         backgroundColor: genre.color.lighten(70),
//                               //         child: Icon(genre.icon, color: genre.color),
//                               //       ),
//                               title: stat == null ? Skeleton2() : Text(stat.amc.name, overflow: TextOverflow.ellipsis),
//                               subtitle: stats == null
//                                   ? Skeleton2(color: isError ? context.colors.error : null)
//                                   : Text('${stat?.numTransactions ?? 0} transactions', overflow: TextOverflow.ellipsis),
//                               trailingIcon: stats == null
//                                   ? Skeleton2(color: isError ? context.colors.error : null)
//                                   : BlocSelector<AppCubit, AppState, bool>(
//                                       selector: (state) => state.isPrivateMode,
//                                       builder: (context, isPrivateMode) {
//                                         return CurrencyView(
//                                           amount: stat?.totalAmount ?? 0,
//                                           style: context.textTheme.headlineMedium?.copyWith(
//                                             color: isError ? context.colors.error : AmcGenre.mf.color,
//                                           ),
//                                           decimalsStyle: context.textTheme.headlineSmall?.copyWith(
//                                             fontSize: 13.0,
//                                             color: isError ? context.colors.error : AmcGenre.mf.color,
//                                           ),
//                                           currencyStyle: context.textTheme.bodySmall?.copyWith(
//                                             color: isError ? context.colors.error : AmcGenre.mf.color,
//                                           ),
//                                           privateMode: isPrivateMode,
//                                         );
//                                       },
//                                     ),
//                               // onTap: () {},
//                             );
//                           }),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }

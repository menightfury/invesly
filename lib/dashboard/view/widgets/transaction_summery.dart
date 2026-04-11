part of '../dashboard_page.dart';

class _TransactionSummeryWidget extends StatelessWidget {
  const _TransactionSummeryWidget({
    super.key,
    required this.genre,
    this.totalInvestedAmount = 0.0,
    this.transactions = const [],
  });

  final AmcGenre genre;
  final double totalInvestedAmount;
  final List<TransactionStat> transactions;

  @override
  Widget build(BuildContext context) {
    final totalGenreAmount = transactions.isEmpty ? 0.0 : transactions.fold<double>(0, (v, el) => v + el.totalAmount);
    double share = 0.0;
    if (totalGenreAmount > 0 && totalInvestedAmount > 0) {
      share = totalGenreAmount / totalInvestedAmount;
    }
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    // $logger.f(transactions);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // ~ Heading
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: <Widget>[
              const Icon(Icons.trending_up_rounded, color: Colors.lightBlue, size: 32.0),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(genre.title, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4.0),
                    Text(totalGenreAmount.toCompact(), style: textTheme.headlineMedium),
                  ],
                ),
              ),
              if (share > 0)
                CircularPercentIndicator(
                  percent: share,
                  radius: 40.0,
                  lineWidth: 16.0,
                  circularStrokeCap: CircularStrokeCap.round,
                  animation: true,
                  animateFromLastPercent: true,
                  progressColor: colorScheme.primary,
                  backgroundColor: colorScheme.secondary,
                  center: Text('${(share * 100).toCompact()} %'),
                ),
            ],
          ),
        ),

        // ~ Lists
        buildTransactionList(context, totalGenreAmount),
      ],
    );
  }

  Widget buildTransactionList(BuildContext context, double totalClassAmount) {
    if (transactions.isEmpty) {
      return EmptyWidget(height: 160.0, label: Text('No transactions in ${genre.title.toLowerCase()}'));
    }

    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      height: 240.0,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          final genre = transaction.amc;
          final shareWithinClass = transaction.totalAmount / totalClassAmount;
          final overallShare = transaction.totalAmount / totalInvestedAmount;

          // final tags = [amc.plan, amc.sector, amc.subSector].whereNotNull().toList(growable: false);
          // final tags = genre.tags?.toList() ?? <String>[];

          return Material(
            elevation: 1.0,
            borderRadius: BorderRadius.circular(12.0),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {},
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    colors: [Color(0xFFA8EDEA), Color(0xFFFED6E3)],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: SizedBox(
                    width: 160.0,
                    height: 192.0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // ~ Amc name
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(genre.name, maxLines: 2, overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(height: 4.0),

                        // ~ Amc tags like plan, scheme, sector, sub_sector etc.
                        // SizedBox(
                        //   height: 24.0,
                        //   child: ListView.separated(
                        //     scrollDirection: Axis.horizontal,
                        //     padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        //     separatorBuilder: (_, __) => const SizedBox(width: 8.0),
                        //     itemBuilder: (context, i) {
                        //       final tag = tags[i];
                        //       return Center(
                        //         child: ConstrainedBox(
                        //           constraints: const BoxConstraints(maxWidth: 96.0),
                        //           child: Material(
                        //             color: const Color.fromARGB(255, 5, 60, 141),
                        //             shape: const StadiumBorder(),
                        //             child: Padding(
                        //               padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        //               child: Text(
                        //                 tag,
                        //                 style: textTheme.labelSmall?.copyWith(color: Colors.white),
                        //                 overflow: TextOverflow.ellipsis,
                        //               ),
                        //             ),
                        //           ),
                        //         ),
                        //       );
                        //     },
                        //     itemCount: tags.length,
                        //   ),
                        // ),
                        const SizedBox(height: 16.0),
                        const Spacer(),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            children: <Widget>[
                              // ~ Amount
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  transaction.totalAmount.toCompact(),
                                  textAlign: TextAlign.right,
                                  style: textTheme.headlineSmall,
                                ),
                              ),
                              const SizedBox(height: 16.0),

                              // ~ % Share within genre
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(transaction.amc.name, style: textTheme.labelSmall),
                                      Text('${(shareWithinClass * 100).toCompact()}%', style: textTheme.labelSmall),
                                    ],
                                  ),
                                  LinearPercentIndicator(
                                    percent: shareWithinClass.isNegative ? 0.0 : shareWithinClass,
                                    backgroundColor: Colors.teal.withAlpha(50),
                                    progressColor: Colors.teal,
                                    lineHeight: 4.0,
                                    padding: EdgeInsets.zero,
                                    barRadius: const Radius.circular(8.0),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12.0),

                              // ~ % Overall share
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text('Total', style: textTheme.labelSmall),
                                        Text('${(overallShare * 100).toCompact()}%', style: textTheme.labelSmall),
                                      ],
                                    ),
                                  ),
                                  LinearPercentIndicator(
                                    percent: overallShare.isNegative ? 0.0 : overallShare,
                                    backgroundColor: Colors.teal.withAlpha(50),
                                    progressColor: Colors.teal,
                                    lineHeight: 4.0,
                                    padding: EdgeInsets.zero,
                                    barRadius: const Radius.circular(8.0),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
        separatorBuilder: (_, _) => const SizedBox(width: 16.0),
      ),
    );
  }
}

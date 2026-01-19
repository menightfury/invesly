import 'package:invesly/amcs/model/amc_repository.dart';
import 'package:invesly/amcs/view/amc_overview/cubit/amc_overview_cubit.dart';
import 'package:invesly/common_libs.dart';

class AmcOverviewScreen extends StatelessWidget {
  const AmcOverviewScreen(this.amcId, {super.key});

  final String amcId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AmcOverviewCubit(repository: context.read<AmcRepository>()),
      child: _AmcOverviewScreen(amcId),
    );
  }
}

class _AmcOverviewScreen extends StatefulWidget {
  const _AmcOverviewScreen(this.amcId, {super.key});

  final String amcId;

  @override
  State<_AmcOverviewScreen> createState() => _AmcOverviewScreenState();
}

class _AmcOverviewScreenState extends State<_AmcOverviewScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AmcOverviewCubit>().fetchAmcOverview(widget.amcId);
  }

  @override
  void didUpdateWidget(covariant _AmcOverviewScreen oldWidget) {
    if (oldWidget.amcId != widget.amcId) {
      context.read<AmcOverviewCubit>().fetchAmcOverview(widget.amcId);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AmcOverviewCubit, AmcOverviewState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: state is AmcOverviewLoadedState && state.amc != null ? Text(state.amc!.name) : Text(widget.amcId),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                // Stock Card
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      // Stock Header
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'IOCL',
                                  style: TextStyle(
                                    color: Colors.teal.shade500,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(Icons.chevron_right, color: Colors.teal.shade500),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('₹160.70', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                Text('+1.65 (1.04%)', style: TextStyle(color: Colors.teal.shade500, fontSize: 14)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),

                      // Stock Details
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildDetailRow('Shares', '50'),
                            const SizedBox(height: 12),
                            _buildDetailRow('Total returns', '+₹1,035.00 (14.79%)', valueColor: Colors.teal.shade500),
                            const SizedBox(height: 12),
                            _buildDetailRow('1D returns', '+₹77.00 (0.97%)', valueColor: Colors.teal.shade500),
                            const SizedBox(height: 20),
                            _buildDetailRow('Current', '₹8,035.00'),
                            const SizedBox(height: 12),
                            _buildDetailRow('Invested', '₹7,000.00'),
                            const SizedBox(height: 20),
                            _buildDetailRow('Mkt. price', '₹160.70'),
                            const SizedBox(height: 12),
                            _buildDetailRow('Avg. price', '₹140.00'),
                          ],
                        ),
                      ),
                      const Divider(height: 1),

                      // Order History Button
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Center(
                          child: Text(
                            'Order history',
                            style: TextStyle(color: Colors.teal.shade500, fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Pledge Section
                InkWell(
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Pledge', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            SizedBox(height: 4),
                            Text(
                              'Get extra balance for stocks intraday and F&O trading',
                              style: TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                          ],
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Holding Transactions Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Holding transactions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('Avg price (Invested)', style: TextStyle(color: Colors.grey, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('50 qty', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                            SizedBox(height: 4),
                            Text('08 Nov \'24', style: TextStyle(color: Colors.grey, fontSize: 14)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('₹140.00', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                            SizedBox(height: 4),
                            Text('(₹7,000.00)', style: TextStyle(color: Colors.grey, fontSize: 14)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                const Spacer(),

                // Buy/Sell Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Sell', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal.shade500,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Buy', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.black87, fontSize: 16)),
        Text(
          value,
          style: TextStyle(color: valueColor ?? Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

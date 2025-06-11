import 'dart:async';

import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/amcs/model/amc_repository.dart';
import 'package:invesly/common_libs.dart';

class InveslyAmcPickerWidget extends StatefulWidget {
  const InveslyAmcPickerWidget({super.key, this.amcId, this.onPickup});

  final String? amcId;
  final ValueChanged<InveslyAmc>? onPickup;

  static Future<InveslyAmc?> showModal(BuildContext context, [String? amcId]) async {
    return await showDialog<InveslyAmc>(
      context: context,
      builder: (context) {
        return InveslyAmcPickerWidget(amcId: amcId, onPickup: (amc) => Navigator.maybePop(context, amc));
      },
    );
  }

  @override
  State<InveslyAmcPickerWidget> createState() => _InveslyAmcPickerWidgetState();
}

class _InveslyAmcPickerWidgetState extends State<InveslyAmcPickerWidget> {
  late final Debouncer _debouncer;
  late final AmcRepository _amcRepository;
  String? _currentQuery;
  late final TextEditingController _searchController;
  List<InveslyAmc> _queryResults = [];

  @override
  void initState() {
    super.initState();
    _debouncer = Debouncer(1.seconds);
    _amcRepository = context.read<AmcRepository>();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }

  Future<List<InveslyAmc>?> _searchAmc(String query) async {
    if (query == _currentQuery) return _queryResults;

    try {
      await _debouncer.wait(); // wait for 1 second
      final amcs = await _amcRepository.getAmcs(); // TODO: implement search from database

      _queryResults = amcs;
      _currentQuery = query;
      return _queryResults;
    } on Exception catch (error) {
      $logger.e(error);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppConstants.formFieldLabelSpacing,
          children: <Widget>[
            const Text('Asset Management Company (AMC)'),
            TextFormField(controller: _searchController),
            Expanded(
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: _searchController,
                builder: (context, searchQuery, _) {
                  $logger.d(searchQuery.text);

                  return FutureBuilder<List<InveslyAmc>?>(
                    future: _searchAmc(searchQuery.text),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasError) {
                          return const Center(child: Text('Error occurred while fetching AMCs'));
                        }
                        if (snapshot.hasData) {
                          final amcs = snapshot.data;
                          if (amcs == null || amcs.isEmpty) {
                            return const Center(child: Text('Sorry! No results found 😞'));
                          }

                          return ListView.separated(
                            padding: EdgeInsets.zero,
                            itemCount: amcs.length,
                            // shrinkWrap: true,
                            itemBuilder: (context, index) {
                              final amc = amcs.elementAt(index);

                              return ListTile(
                                onTap: () => widget.onPickup?.call(amc),
                                dense: true,
                                title: Text(amc.name),
                                subtitle: Text(amc.genre?.title ?? 'NULL'),
                              );
                            },
                            separatorBuilder: (_, _) => const InveslyDivider(),
                          );
                        }
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Debouncer {
  Debouncer(this.delay);

  final Duration delay;
  Timer? _timer;

  Future<void> wait() async {
    final completer = Completer<void>();
    if (_timer?.isActive ?? false) {
      _timer?.cancel();
    }
    _timer = Timer(delay, () => completer.complete());
    return completer.future;
  }

  void dispose() {
    _timer?.cancel();
  }
}

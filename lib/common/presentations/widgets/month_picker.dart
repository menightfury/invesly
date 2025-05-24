import 'package:invesly/common_libs.dart';

// class MonthYear {
//   final DateTime start;
//   final DateTime end;

//   MonthYear(this.start, this.end);
// }

class MonthYearPicker extends StatefulWidget {
  const MonthYearPicker({
    super.key,
    required this.start,
    required this.end,
    this.initial,
    this.height = 48.0,
    this.onChanged,
  });

  final DateTime start;
  final DateTime end;
  final DateTime? initial;
  final double height;
  final ValueChanged<DateTime>? onChanged;

  @override
  State<MonthYearPicker> createState() => MonthYearPickerState();
}

class MonthYearPickerState extends State<MonthYearPicker> with SingleTickerProviderStateMixin {
  final _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  late final TabController tabController;
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initial ?? DateTime.now();
    tabController = TabController(
      length: _months.length,
      // length: DateTime.monthsPerYear,
      vsync: this,
      initialIndex: _selected.month - 1,
    );
  }

  Future<int> _showYearPicker(BuildContext context) async {
    final year = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      shape: const Border(top: BorderSide()),
      builder: (context) {
        return const Padding(
          padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
          child: Text('Year picker', textAlign: TextAlign.center),
        );
      },
    );

    return year ?? 2023;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF4E0B8),
      shape: const Border(top: BorderSide()),
      child: SizedBox(
        height: widget.height,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              child: TabBar(
                isScrollable: true,
                controller: tabController,
                indicatorColor: Colors.redAccent,
                labelColor: Colors.redAccent,
                tabs: _months.map((m) => Text(m)).toList(),
                onTap: (value) {
                  _selected = DateTime(_selected.year, value + 1);
                  _handleChange(_selected);
                },
              ),
            ),
            DecoratedBox(
              decoration: const BoxDecoration(border: Border(left: BorderSide())),
              child: InkWell(
                onTap: () async {
                  final year = await _showYearPicker(context);
                  _selected = DateTime(year, _selected.month);
                  _handleChange(_selected);
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[Text('2023'), Icon(Icons.keyboard_arrow_down_rounded)],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleChange(DateTime date) {
    widget.onChanged?.call(date);
  }
}

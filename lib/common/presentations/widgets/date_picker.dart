import 'package:invesly/common_libs.dart';

class InveslyDatePicker extends StatefulWidget {
  const InveslyDatePicker({super.key, this.date, this.onPickup, this.prefixIcon, this.style});

  final DateTime? date;
  final ValueChanged<DateTime>? onPickup;
  final Widget? prefixIcon;
  final ButtonStyle? style;

  @override
  State<InveslyDatePicker> createState() => _InveslyDatePickerState();
}

class _InveslyDatePickerState extends State<InveslyDatePicker> {
  late final DateTime _dateNow;
  late final ValueNotifier<DateTime> _dateNotifier;

  @override
  void initState() {
    super.initState();
    _dateNow = DateTime.now();
    _dateNotifier = ValueNotifier<DateTime>(widget.date ?? _dateNow);
  }

  Future<void> _selectDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateNotifier.value,
      firstDate: DateTime(1990),
      lastDate: _dateNow,
    );
    if (date == null) return;

    _dateNotifier.value = date;
    if (widget.onPickup != null) widget.onPickup!(date);
  }

  @override
  void dispose() {
    _dateNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      icon: widget.prefixIcon,
      label: ValueListenableBuilder<DateTime>(
        valueListenable: _dateNotifier,
        builder: (context, date, _) {
          int days = _dateNow.difference(date).inDays;
          String label;
          switch (days) {
            case 0:
              label = 'Today';
              break;
            case 1:
              label = 'Yesterday';
              break;
            default:
              label = date.toReadable();
          }
          return Text(label);
        },
      ),
      style: widget.style,
      onPressed: () async => await _selectDate(context),
    );
  }
}

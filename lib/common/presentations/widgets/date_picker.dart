import 'package:invesly/common/cubit/app_cubit.dart';
import 'package:invesly/common/presentations/widgets/async_form_field.dart';
import 'package:invesly/common_libs.dart';

class InveslyDatePicker extends StatefulWidget {
  const InveslyDatePicker({
    super.key,
    this.initialDate,
    this.onPickup,
    this.leadingIcon = const Icon(Icons.edit_calendar_rounded),
    this.color,
    this.validator,
  });

  final DateTime? initialDate;
  final ValueChanged<DateTime>? onPickup;
  final Widget? leadingIcon;
  final Color? color;
  final FormFieldValidator<DateTime>? validator;

  @override
  State<InveslyDatePicker> createState() => _InveslyDatePickerState();
}

class _InveslyDatePickerState extends State<InveslyDatePicker> {
  late final DateTime _dateNow;

  @override
  void initState() {
    super.initState();
    _dateNow = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return AsyncFormField<DateTime>(
      initialValue: widget.initialDate,
      validator: widget.validator,
      onTapCallback: (value) async {
        final newDate = await showDatePicker(
          context: context,
          initialDate: value ?? _dateNow,
          firstDate: DateTime(1990),
          lastDate: _dateNow,
        );
        if (newDate == null) {
          return value;
        }
        final startOfDay = newDate.startOfDay;
        widget.onPickup?.call(startOfDay);
        return startOfDay;
      },
      childBuilder: (date) {
        if (date == null) {
          return const Text('Select date', style: TextStyle(color: Colors.grey));
        }
        final days = _dateNow.difference(date).inDays;
        final label = switch (days) {
          0 => 'Today',
          1 => 'Yesterday',
          _ => date.toReadable(context.read<AppCubit>().state.dateFormat),
        };
        return Text(label, overflow: TextOverflow.ellipsis);
      },
    );
  }
}

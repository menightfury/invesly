import 'package:invesly/common_libs.dart';

class InveslyDatePicker extends StatelessWidget {
  const InveslyDatePicker({
    super.key,
    this.initialDate,
    this.onPickup,
    this.leadingIcon = const Icon(Icons.edit_calendar_rounded),
    this.color,
    // this.validator,
    this.enabled = true,
    required this.child,
  });

  final DateTime? initialDate;
  final ValueChanged<DateTime>? onPickup;
  final Widget? leadingIcon;
  final Color? color;
  // final FormFieldValidator<DateTime>? validator;
  final bool enabled;
  final Widget child;

  //   @override
  //   State<InveslyDatePicker> createState() => _InveslyDatePickerState();
  // }

  // class _InveslyDatePickerState extends State<InveslyDatePicker> {
  //   late final DateTime _dateNow;
  //   DateTime? _date;
  //   String? _errorText;

  // @override
  // void initState() {
  //   super.initState();
  //   _dateNow = DateTime.now();
  //   _date = widget.initialDate;
  // }

  // @override
  // void didUpdateWidget(covariant InveslyDatePicker oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   if (widget.initialDate != oldWidget.initialDate) {
  //     _date = widget.initialDate;
  //   }
  // }

  // void _validate() {
  //   if (widget.validator != null) {
  //     _errorText = widget.validator!(_date);
  //   }
  // }

  // bool get _hasError => _errorText != null;

  // Set<WidgetState> get widgetState => <WidgetState>{
  //   if (!widget.enabled) WidgetState.disabled,
  //   if (_hasError) WidgetState.error,
  // };

  // Color get defaultColor => WidgetStateColor.resolveWith((Set<WidgetState> states) {
  //   if (states.contains(WidgetState.disabled)) {
  //     return context.theme.disabledColor;
  //   }

  //   if (states.contains(WidgetState.error)) {
  //     return context.colors.errorContainer;
  //   }

  //   return context.colors.primaryContainer;
  // });

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    // final colors = theme.colorScheme;
    // final textTheme = theme.textTheme;

    // TextStyle errorStyle = textTheme.bodySmall ?? const TextStyle();
    // errorStyle = errorStyle.copyWith(color: colors.error).merge(theme.inputDecorationTheme.errorStyle);

    // Widget? error;
    // if (_hasError) {
    //   error = Text(_errorText!, style: errorStyle, overflow: TextOverflow.ellipsis, maxLines: 1);
    // }
    final dateNow = DateTime.now();

    return Tappable(
      onTap: () async {
        final newDate = await showDatePicker(
          context: context,
          initialDate: initialDate ?? dateNow,
          firstDate: DateTime(1990),
          lastDate: dateNow,
        );
        if (newDate == null) return;

        onPickup?.call(newDate.startOfDay);
      },
      childAlignment: AlignmentGeometry.centerLeft,
      padding: iFormFieldContentPadding,
      leading: leadingIcon,
      // trailing: trailing,
      color: color,
      child: child,
    );
  }
}

import 'package:intl/intl.dart';
import 'package:invesly/common_libs.dart';

class InveslyDateFormatPicker extends StatefulWidget {
  const InveslyDateFormatPicker({super.key, this.value, this.onPickup});

  static const dateFormats = <String>[
    'dd MMM yyyy',
    'dd MMMM yyyy',
    'd-M-yy',
    'd.M.yy',
    'dd-MM-yy',
    'dd-MM-yyyy',
    'yyyy-MM-dd',
  ];

  final String? value;
  final ValueChanged<String>? onPickup;

  static Future<String?> showModal(BuildContext context, [String? dateFormat]) async {
    return await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return InveslyDateFormatPicker(value: dateFormat, onPickup: (value) => Navigator.maybePop(context, value));
      },
    );
  }

  @override
  State<InveslyDateFormatPicker> createState() => _InveslyDateFormatPickerState();
}

class _InveslyDateFormatPickerState extends State<InveslyDateFormatPicker> {
  late final ValueNotifier<String?> _dateFormat;

  @override
  void initState() {
    super.initState();
    _dateFormat = ValueNotifier(widget.value);
  }

  @override
  void dispose() {
    _dateFormat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateNow = DateTime.now();

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 12.0),
                child: Text(
                  'Select a date format',
                  style: context.textTheme.labelLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ValueListenableBuilder<String?>(
                valueListenable: _dateFormat,
                builder: (context, dateFormat, _) {
                  return RadioGroup<String>(
                    groupValue: dateFormat,
                    onChanged: (value) {
                      if (value == null) return;
                      _dateFormat.value = value;
                      widget.onPickup?.call(value);
                    },
                    child: Section(
                      tiles: InveslyDateFormatPicker.dateFormats.map((data) {
                        // final isSelectionAllowed = !columnsToExclude.contains(data.key);
                        return RadioSectionTile<String>(
                          title: Text(DateFormat(data).format(dateNow)),
                          subtitle: Text(data),
                          value: data,
                          // onTap: () => context.pop(data),
                          // secondaryIcon: data == value ? const Icon(Icons.check_rounded) : null,
                          // selectedTileColor: context.theme.primaryColor.withAlpha(125),
                          // enabled: isSelectionAllowed,
                          // selected: data == value,
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

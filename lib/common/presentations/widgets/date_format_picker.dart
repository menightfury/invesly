import 'package:intl/intl.dart';
import 'package:invesly/common/presentations/widgets/section.dart';
import 'package:invesly/common_libs.dart';

class InveslyDateFormatPicker extends StatelessWidget {
  const InveslyDateFormatPicker({super.key, this.value, this.onPickup});

  static const dateFormats = <String>[
    'd-M-yy',
    'd.M.yy',
    'dd-MM-yy',
    'dd-MM-yyyy',
    'dd MMM yyyy',
    'dd MMMM yyyy',
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
              Section(
                tiles: dateFormats.map((data) {
                  // final isSelectionAllowed = !columnsToExclude.contains(data.key);
                  return SectionTile(
                    title: Text(DateFormat(data).format(dateNow)),
                    subtitle: Text(data),
                    onTap: () => context.pop(data),
                    trailingIcon: data == value ? const Icon(Icons.check_rounded) : null,
                    selectedTileColor: context.theme.primaryColor.withAlpha(125),
                    // enabled: isSelectionAllowed,
                    selected: data == value,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

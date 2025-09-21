import 'package:intl/intl.dart';
import 'package:invesly/common_libs.dart';

class InveslyDateFormatPicker extends StatelessWidget {
  const InveslyDateFormatPicker({super.key, this.value, this.onPickup});

  final String? value;
  final ValueChanged<String>? onPickup;
  final _dateFormats = const ['d-M-yy', 'd.M.yy', 'dd-MM-yy', 'dd-MM-yyyy', 'dd MMMM yyyy', 'yyyy-MM-dd'];

  static Future<String?> showModal(BuildContext context, [String? dateFormat]) async {
    return await showModalBottomSheet<String>(
      context: context,
      // isScrollControlled: true,
      builder: (context) {
        return InveslyDateFormatPicker(value: dateFormat, onPickup: (value) => Navigator.maybePop(context, value));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateNow = DateTime.now();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 8.0),
            child: Text(
              'Select a date format',
              style: TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          ...List.generate(_dateFormats.length, (index) {
            final dateFormat = _dateFormats.elementAt(index);

            return ListTile(
              // leading: CircleAvatar(foregroundImage: dateFormat != null ? AssetImage(dateFormat.avatar) : null),
              title: Text(dateFormat),
              subtitle: Text(DateFormat(dateFormat).format(dateNow)),
              trailing: dateFormat == value ? const Icon(Icons.check_rounded) : null,
              onTap: () => onPickup?.call(dateFormat),
            );
          }),
        ],
      ),
    );
  }
}

import 'package:invesly/common/presentations/widgets/simple_chip.dart';
import 'package:invesly/common_libs.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

@UseCase(name: 'Default', type: SimpleChip)
Widget buildSimpleChipUseCase(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Center(
      child: Column(
        mainAxisSize: .min,
        spacing: 16.0,
        children: <Widget>[
          SimpleChip(
            // elevation: 4.0,
            // color: context.colors.primary,
            // shadowColor: Colors.red,
            // borderRadius: BorderRadius.all(Radius.circular(2.0)),
            padding: EdgeInsets.zero,
            // clipBehavior: Clip.antiAlias,
            child: const Text('Simple Chip'),
          ),

          TextField(maxLines: 3, decoration: const InputDecoration(hintText: 'Notes')),
        ],
      ),
    ),
  );
}

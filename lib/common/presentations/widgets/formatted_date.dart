import 'package:invesly/common/cubit/app_cubit.dart';
import 'package:invesly/common_libs.dart';

class FormattedDate extends StatelessWidget {
  const FormattedDate({super.key, required this.date, this.style, this.textAlign, this.overflow, this.maxLines});

  final DateTime date;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<AppCubit, AppState, String?>(
      selector: (state) => state.dateFormat,
      builder: (context, dateFormat) {
        return Text(
          date.toReadable(dateFormat),
          style: style,
          textAlign: textAlign,
          overflow: overflow,
          maxLines: maxLines,
        );
      },
    );
  }
}

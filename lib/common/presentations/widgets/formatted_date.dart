import 'package:invesly/common/cubit/app_cubit.dart';
import 'package:invesly/common_libs.dart';

class FormattedDate extends StatelessWidget {
  const FormattedDate({
    super.key,
    required this.date,
    this.prefixText,
    this.suffixText,
    this.style,
    this.textAlign,
    this.overflow,
    this.maxLines,
  });

  final DateTime date;
  final String? prefixText;
  final String? suffixText;
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
          '${prefixText ?? ''}${date.toReadable(dateFormat)}${suffixText ?? ''}',
          style: style,
          textAlign: textAlign,
          overflow: overflow,
          maxLines: maxLines,
        );
      },
    );
  }
}

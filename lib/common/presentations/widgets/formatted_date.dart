import 'package:invesly/common/cubit/app_cubit.dart';
import 'package:invesly/common_libs.dart';

class FormattedDate extends StatelessWidget {
  const FormattedDate({
    super.key,
    required this.date,
    this.prefix,
    this.suffix,
    this.style,
    this.textAlign,
    this.overflow,
    this.maxLines,
  });

  final DateTime date;
  final Widget? prefix;
  final Widget? suffix;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle = Theme.of(context).textTheme.bodyMedium!;
    return BlocSelector<AppCubit, AppState, String?>(
      selector: (state) => state.dateFormat,
      builder: (context, dateFormat) {
        Widget? prefixWidget, suffixWidget;
        if (prefix != null) {
          prefixWidget = DefaultTextStyle(style: style ?? defaultTextStyle, child: prefix!);
        }

        if (suffix != null) {
          suffixWidget = DefaultTextStyle(style: style ?? defaultTextStyle, child: suffix!);
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ?prefixWidget,
            Text(
              date.toReadable(dateFormat),
              style: style ?? defaultTextStyle,
              textAlign: textAlign,
              overflow: overflow,
              maxLines: maxLines,
            ),
            ?suffixWidget,
          ],
        );
      },
    );
  }
}

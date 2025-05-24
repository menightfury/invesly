import 'package:invesly/common_libs.dart';

class EmptyWidget extends StatelessWidget {
  const EmptyWidget({super.key, this.height = 256.0, this.label, this.onPressed});

  final double height;
  final String? label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            height: height,
            // child: SvgPicture.asset('assets/images/empty.svg', height: height * 0.75),
            child: Image.asset('assets/images/empty_1.png', height: height * 0.75),
          ),
          if (label != null) Text(label!, style: Theme.of(context).textTheme.labelMedium),
          if (onPressed != null)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: ElevatedButton.icon(
                onPressed: onPressed,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add user'),
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:invesly/common_libs.dart';

class PMErrorWidget extends StatelessWidget {
  const PMErrorWidget({super.key, this.height = 200.0, this.label, this.onPressed});

  final double height;
  final String? label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(height: height, child: SvgPicture.asset('assets/images/error.svg', height: height * 0.75)),
          if (label != null) Text(label!, style: const TextStyle(fontSize: 16.0)),
          if (onPressed != null)
            ElevatedButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add user'),
            ),
        ],
      ),
    );
  }
}

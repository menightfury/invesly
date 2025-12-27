part of '../dashboard_screen.dart';

class _StockWidget extends StatefulWidget {
  const _StockWidget(this.status, {super.key});

  final _AccountsStatus status;

  @override
  State<_StockWidget> createState() => __StockWidgetState();
}

class __StockWidgetState extends State<_StockWidget> {
  @override
  Widget build(BuildContext context) {
    return Section(title: Text('Stock'), icon: const Icon(Icons.food_bank), tiles: []);
  }
}

part of '../dashboard_screen.dart';

class _MutualFundWidget extends StatefulWidget {
  const _MutualFundWidget(this.status, {super.key});

  final _AccountsStatus status;

  @override
  State<_MutualFundWidget> createState() => __MutualFundWidgetState();
}

class __MutualFundWidgetState extends State<_MutualFundWidget> {
  @override
  Widget build(BuildContext context) {
    return Section(title: Text('Mutual fund'), icon: const Icon(Icons.food_bank), tiles: []);
  }
}

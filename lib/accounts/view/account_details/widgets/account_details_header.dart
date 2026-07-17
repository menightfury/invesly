part of '../account_details_page.dart';

class _AccountDetailsHeader extends StatelessWidget {
  const _AccountDetailsHeader({super.key, required this.account});

  final InveslyAccount account;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 16.0,
      children: <Widget>[
        account.icon.buildWidget(
          context,
          radius: 60.0,
          backgroundColor: account.color?.withAlpha(0x33),
          color: account.color,
          iconSize: 28.0,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            spacing: 4.0,
            children: <Widget>[
              Text(account.name, style: context.textTheme.headlineSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(
                'Account Details',
                style: context.textTheme.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

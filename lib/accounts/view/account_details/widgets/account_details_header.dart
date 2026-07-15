part of '../account_details_page.dart';

class _AccountDetailsHeader extends StatelessWidget {
  const _AccountDetailsHeader({super.key, required this.account});

  final InveslyAccount account;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 16.0,
      children: <Widget>[
        SizedBox.square(
          dimension: 60.0,
          child: PhysicalModel(color: Colors.white, shape: BoxShape.circle, child: Image.asset(account.avatarSrc)),
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

// ignore_for_file: public_member_api_docs, sort_constructors_first, avoid_print

// import 'package:googleapis/admin/directory_v1.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/google_drive/google_drive.dart';
import 'package:invesly/settings/cubit/settings_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildListDelegate.fixed([
              _SettingsSection(
                title: const Text('General'),
                tiles: <Widget>[
                  _SettingsTile(
                    icon: const Icon(Icons.language),
                    title: const Text('Test page'),

                    // value: Text(context.watch<SettingsRepository>().currentLocale.name),
                    onTap: () => context.push(AppRouter.test),
                  ),
                  _SettingsTile(
                    icon: const Icon(Icons.language),
                    title: const Text('Add AMC'),

                    // value: Text(context.watch<SettingsRepository>().currentLocale.name),
                    onTap: () => context.push(AppRouter.editAmc),
                  ),
                  _SettingsTile(
                    icon: const Icon(Icons.language),
                    title: const Text('Google Sign-in'),

                    // value: Text(context.watch<SettingsRepository>().currentLocale.name),
                    onTap:
                        () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SignInDemo())),
                  ),
                  _SettingsTile(
                    icon: const Icon(Icons.language),
                    title: const Text('Language'),

                    // value: Text(context.watch<SettingsRepository>().currentLocale.name),
                    // onTap: () => _showLanguageSelectionModal(context),
                  ),
                  // SettingsTile
                  BlocSelector<SettingsCubit, SettingsState, bool>(
                    selector: (state) => state.isDarkMode,
                    builder: (context, value) {
                      return _SettingsTile.switchTile(
                        onChanged: (value) => context.read<SettingsCubit>().setDarkTheme(value),
                        value: value,
                        icon: const Icon(Icons.format_paint),
                        title: const Text('Dark mode'),
                      );
                    },
                  ),
                  _SettingsTile(icon: const Icon(Icons.format_paint), title: const Text('Currency')),
                  _SettingsTile.navigation(
                    icon: const Icon(Icons.format_paint),
                    title: const Text('Security'),
                    // onTap: () => context.push(Screens.security),
                  ),
                  _SettingsTile.navigation(icon: const Icon(Icons.format_paint), title: const Text('Notification')),
                  _SettingsTile.navigation(
                    icon: const Icon(Icons.format_paint),
                    title: const Text('Backup / Restore'),
                    onTap: () => context.push(AppRouter.backup),
                  ),
                ],
              ),
              _SettingsSection(
                title: const Text('More'),
                tiles: [
                  _SettingsTile.navigation(icon: const Icon(Icons.format_paint), title: const Text('Privacy policy')),
                  _SettingsTile.navigation(icon: const Icon(Icons.format_paint), title: const Text('Terms')),
                  _SettingsTile.navigation(icon: const Icon(Icons.format_paint), title: const Text('Help & feedback')),
                ],
              ),

              // ~ Extra space for content below bottom navigation bar
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ]),
          ),
        ],
      ),
    );
  }

  // void _showLanguageSelectionModal(BuildContext context) {
  //   // final Map<String, String> languages = {'bn': 'Bengali', 'en': 'English'};
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (context) {
  //       return LocalePicker(
  //         onChanged: (language) {
  //           context.read<SettingsRepository>().saveLocale(language);
  //           Navigator.pop(context);
  //         },
  //       );
  //     },
  //   );
  // }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({super.key, this.title, required this.tiles});

  final Widget? title;
  final List<Widget> tiles;

  @override
  Widget build(BuildContext context) {
    if (title == null) {
      return buildTileList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsetsDirectional.only(top: 24, bottom: 10, start: 24, end: 24), child: title),
        buildTileList(),
      ],
    );
  }

  Widget buildTileList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          // color: theme.disabledColor, // TODO: fix background color
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: tiles),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  _SettingsTile({this.title, this.subTitle, this.icon, Widget? value, VoidCallback? onTap, bool enabled = true})
    : content = ListTile(
        title: title,
        subtitle: subTitle,
        leading: icon,
        trailing: value,
        onTap: onTap,
        enabled: enabled,
      );

  _SettingsTile.switchTile({
    this.title,
    this.subTitle,
    this.icon,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) : content = SwitchListTile(title: title, subtitle: subTitle, secondary: icon, value: value, onChanged: onChanged);

  _SettingsTile.navigation({this.title, this.subTitle, this.icon, VoidCallback? onTap, bool enabled = true})
    : content = ListTile(
        title: title,
        subtitle: subTitle,
        leading: icon,
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
        enabled: enabled,
      );

  final Widget? title;
  final Widget? subTitle;
  final Widget? icon;

  final Widget content;

  @override
  Widget build(BuildContext context) {
    return content;
  }
}

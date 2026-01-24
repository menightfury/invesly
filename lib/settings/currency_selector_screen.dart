import 'package:invesly/common/cubit/app_cubit.dart';
import 'package:invesly/common/data/currencies.dart';
import 'package:invesly/common/model/currency.dart';
import 'package:invesly/common/presentations/widgets/section.dart';
import 'package:invesly/common_libs.dart';

class CurrencySelectorScreen extends StatelessWidget {
  const CurrencySelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select currency')),
      body: BlocSelector<AppCubit, AppState, Currency?>(
        selector: (state) => state.currency,
        builder: (context, selectedCurrency) {
          final currentCurrency = selectedCurrency ?? Currencies.defaultCurrency;

          return Section.builder(
            tileCount: Currencies.list.length,
            // separatorBuilder: (_, _) => const InveslyDivider(thickness: 1, indent: 16, endIndent: 16),
            tileBuilder: (context, index) {
              final currency = Currencies.list[index];
              final isSelected = currency == currentCurrency;

              return SectionTile(
                onTap: () {
                  context.read<AppCubit>().updateCurrency(currency);
                  context.pop();
                },
                icon: CircleAvatar(
                  backgroundColor: isSelected ? context.theme.primaryColor : context.theme.disabledColor.withAlpha(25),
                  foregroundColor: isSelected
                      ? context.theme.colorScheme.onPrimary
                      : context.theme.colorScheme.onSurface,
                  child: Text(currency.symbol),
                ),
                title: Text('${currency.name} (${currency.code})'),
                trailingIcon: isSelected ? Icon(Icons.check_rounded, color: context.theme.primaryColor) : null,
              );
            },
          );
        },
      ),
    );
  }
}

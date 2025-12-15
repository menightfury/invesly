// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:invesly/common/extensions/widget_extension.dart';
import 'package:invesly/common/presentations/animations/shake.dart';
import 'package:invesly/common/utils/keyboard.dart';
import 'package:invesly/dashboard/view/dashboard_screen.dart';

import 'package:invesly/accounts/edit_account/cubit/edit_account_cubit.dart';
import 'package:invesly/accounts/model/account_model.dart';
import 'package:invesly/accounts/model/account_repository.dart';
import 'package:invesly/common_libs.dart';

class EditAccountScreen extends StatelessWidget {
  const EditAccountScreen({super.key, this.initialAccount});

  final InveslyAccount? initialAccount;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          EditAccountCubit(repository: context.read<AccountRepository>(), initialAccount: initialAccount),
      child: const _EditAccountScreen(),
    );
  }
}

class _EditAccountScreen extends StatefulWidget {
  const _EditAccountScreen({super.key});

  @override
  State<_EditAccountScreen> createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<_EditAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  // final _sliverAnimatedListKey = GlobalKey<SliverAnimatedListState>();
  late final ValueNotifier<AutovalidateMode> _validateMode;

  final _nameKey = GlobalKey<FormFieldState>();
  final _nameShakeKey = GlobalKey<ShakeState>();

  @override
  void initState() {
    super.initState();
    _validateMode = ValueNotifier<AutovalidateMode>(AutovalidateMode.disabled);
  }

  @override
  void dispose() {
    _formKey.currentState?.reset();
    _validateMode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cubit = context.read<EditAccountCubit>();

    return BlocListener<EditAccountCubit, EditAccountState>(
      listenWhen: (prevState, state) => prevState.status != state.status && state.status.isFailureOrSuccess,
      listener: (context, state) {
        late final SnackBar message;

        if (state.status == EditAccountFormStatus.success) {
          if (context.canPop) {
            context.pop();
          } else {
            context.go(const DashboardScreen());
          }
          message = const SnackBar(content: Text('Account saved successfully'), backgroundColor: Colors.teal);
        } else if (state.status == EditAccountFormStatus.failure) {
          message = const SnackBar(content: Text('Sorry! some error occurred'), backgroundColor: Colors.redAccent);
        }
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(message);
      },
      child: Scaffold(
        body: SafeArea(
          child: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                // title: ScrollBasedSliverAppBarContentBuilder(
                //   // TODO: Not working properly, fix this
                //   builder: (context, opacity) {
                //     return Text(
                //       cubit.state.isNewAccount ? 'Add account' : 'Edit account',
                //       style: TextStyle(color: Colors.black.withOpacity(opacity)),
                //     );
                //   },
                // ),
                snap: true,
                floating: true,
              ),
              SliverList(
                delegate: SliverChildListDelegate.fixed(<Widget>[
                  // ~ Title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Welcome,', style: textTheme.headlineSmall),
                        BlocSelector<EditAccountCubit, EditAccountState, String>(
                          selector: (state) => state.name,
                          builder: (context, name) {
                            return Text(name.trim().isEmpty ? 'Investor' : name, style: textTheme.headlineMedium);
                          },
                        ),
                      ],
                    ),
                  ),

                  // ~ Form
                  ValueListenableBuilder<AutovalidateMode>(
                    valueListenable: _validateMode,
                    builder: (context, vMode, child) {
                      return Form(key: _formKey, autovalidateMode: vMode, child: child!);
                    },
                    child: Column(
                      spacing: 32.0,
                      children: <Widget>[
                        // ~~~ Avatar picker ~~~
                        _AvatarPickerWidget(
                          avatars: InveslyAccountAvatar.values.map((e) => e.imgSrc).toList(),
                          onChanged: cubit.updateAvatar,
                          initialValue: cubit.state.avatarIndex,
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 16.0,
                            children: <Widget>[
                              // ~ Name
                              Shake(
                                key: _nameShakeKey,
                                child: TextFormField(
                                  key: _nameKey,
                                  decoration: InputDecoration(
                                    hintText: 'e.g. John Doe',
                                    helperText: cubit.state.isNewAccount ? 'Title can\'t be changed later' : null,
                                  ),
                                  initialValue: cubit.state.name,
                                  validator: (value) {
                                    if (value == null || !value.isValidText) {
                                      return 'Please enter your name';
                                    }
                                    return null;
                                  },
                                  onChanged: cubit.updateName,
                                  enabled: cubit.state.isNewAccount,
                                  onTapOutside: (_) => minimizeKeyboard(),
                                ).withLabel('Title'),
                              ),

                              // ~ PAN number
                              TextFormField(
                                decoration: const InputDecoration(hintText: 'e.g. ABCDE1245F'),
                                initialValue: cubit.state.panNumber,
                                textCapitalization: TextCapitalization.characters,
                                // onChanged: cubit.updatePanNumber,
                              ).withLabel('PAN number'),

                              // ~ Aadhaar number
                              TextFormField(
                                decoration: const InputDecoration(hintText: 'e.g. 1234-5678-9101'),
                                initialValue: cubit.state.aadhaarNumber,
                                keyboardType: TextInputType.number,
                                // onChanged: cubit.updateAadhaarNumber,
                              ).withLabel('Aadhaar Number'),
                              // const SizedBox(height: 160.0),

                              // ~ Accounts
                              // ListTile(
                              //   title: const Text('Account details'),
                              //   trailing: TextButton.icon(
                              //     onPressed: () {
                              //       _accounts.value.add(_AccountModel(bankName: $PMBanks.entries.first.key));
                              //       _accounts.insert(0, _AccountModel(bankName: $PMBanks.entries.first.key));
                              //       _sliverAnimatedListKey.currentState?.insertItem(0);
                              //     },
                              //     icon: const Icon(Icons.add_rounded),
                              //     label: const Text('Add'),
                              //   ),
                              //   contentPadding: const EdgeInsets.only(left: 16.0),
                              // ),

                              // ColumnBuilder(
                              //   itemBuilder: (context, index) {
                              //     final account = _accounts[index];

                              //     return _AccountWidget(
                              //       account: account,
                              //       onChanged: (val) {
                              //         $logger.d(val);
                              //         _accounts[index] = val;
                              //       },
                              //     );
                              //   },
                              //   separatorBuilder: (_, __) => const SizedBox(height: 16.0),
                              //   itemCount: _accounts.length,
                              // ),
                              // ColumnBuilder(
                              //   itemBuilder: (context, index) {
                              //     final account = _accounts[index];

                              //     return _AccountWidget2(
                              //       initialValue: account,
                              //       onChanged: (val) {
                              //         $logger.d(val);
                              //         _accounts[index] = val;
                              //       },
                              //       validator: (value) {
                              //         if (value?.bankName == null || value?.accountNumber == null) {
                              //           return 'Please enter account details';
                              //         }

                              //         return null;
                              //       },
                              //     );
                              //   },
                              //   separatorBuilder: (_, __) => const SizedBox(height: 16.0),
                              //   itemCount: _accounts.length,
                              // ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),

              // // ~ Save button
              // SliverFillRemaining(
              //   hasScrollBody: false,
              //   child: Align(
              //     alignment: Alignment.bottomCenter,
              //     child: Padding(
              //       padding: const EdgeInsets.symmetric(vertical: 8.0),
              //       child: BlocSelector<EditAccountCubit, EditAccountState, bool>(
              //         selector: (state) => state.status.isLoadingOrSuccess,
              //         builder: (context, isLoadingOrSuccess) {
              //           return ElevatedButton.icon(
              //             onPressed: isLoadingOrSuccess ? null : () => _handleSavePressed(context),
              //             label: isLoadingOrSuccess ? const Text('Saving account...') : const Text('Save account'),
              //             icon:
              //                 isLoadingOrSuccess
              //                     ? CircularProgressIndicator(
              //                       strokeWidth: 2.0,
              //                       // color: Colors.white,
              //                       constraints: BoxConstraints.tightForFinite(width: 16.0, height: 16.0),
              //                     )
              //                     : Icon(Icons.save_alt_rounded),
              //           );
              //         },
              //       ),
              //     ),
              //   ),
              // ),

              // ~ Accounts
              // SliverAnimatedList(
              //   key: _sliverAnimatedListKey,
              //   itemBuilder: (context, index, animation) {
              //     final account = _accounts[index];

              //     return FadeTransition(
              //       opacity: animation,
              //       child: Padding(
              //         padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              //         child: _AccountWidget(
              //           account: account,
              //           onChanged: (val) {
              //             $logger.d(val);
              //             _accounts.elementAt(index) = val;
              //           },
              //         ),
              //       ),
              //     );
              //   },
              //   initialItemCount: _accounts.length,
              // ),
            ],
          ),
        ),

        persistentFooterButtons: <Widget>[
          BlocSelector<EditAccountCubit, EditAccountState, bool>(
            selector: (state) => state.status.isLoadingOrSuccess,
            builder: (context, isLoadingOrSuccess) {
              return SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton.icon(
                    onPressed: isLoadingOrSuccess ? null : () => _handleSavePressed(context),
                    label: isLoadingOrSuccess ? const Text('Saving account...') : const Text('Save account'),
                    icon: isLoadingOrSuccess
                        ? CircularProgressIndicator(
                            strokeWidth: 2.0,
                            // color: Colors.white,
                            constraints: BoxConstraints.tightForFinite(width: 16.0, height: 16.0),
                          )
                        : Icon(Icons.save_alt_rounded),
                  ),
                ),
              );
            },
          ),
        ],
        persistentFooterAlignment: AlignmentDirectional.center,
      ),
    );
  }

  // ~ Save account
  Future<void> _handleSavePressed(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      context.read<EditAccountCubit>().save();
      // if (!context.mounted) return;
      // context.read<SettingsCubit>().saveCurrentAccount(account);
    } else {
      if (!(_nameKey.currentState?.isValid ?? false)) {
        _nameShakeKey.currentState?.shake();
      }
      if (_validateMode.value != AutovalidateMode.onUserInteraction) {
        _validateMode.value = AutovalidateMode.onUserInteraction;
      }
    }
  }
}

class _AvatarPickerWidget extends FormField<int> {
  _AvatarPickerWidget({
    super.key,
    required List<String> avatars,
    super.initialValue,
    ValueChanged<int>? onChanged,
    super.validator,
    super.onSaved,
  }) : super(
         builder: (FormFieldState<int> field) {
           final __AvatarPickerWidgetState state = field as __AvatarPickerWidgetState;
           void onChangedHandler(int idx) {
             onChanged?.call(idx);
           }

           return SizedBox(
             height: 150.0,
             child: PageView.builder(
               controller: state.controller,
               itemBuilder: (context, index) {
                 return AnimatedBuilder(
                   animation: state.controller,
                   builder: (context, _) {
                     double scale = 1.0;
                     double itemOffset = 0.0;
                     double page = state.controller.initialPage.toDouble();
                     final position = state.controller.position;
                     if (position.hasPixels && position.hasContentDimensions) {
                       page = state.controller.page ?? page;
                     }
                     itemOffset = page - index;

                     final num t = (1 - (itemOffset.abs() * 0.6)).clamp(0.3, 1.0);
                     scale = Curves.easeOut.transform(t as double);

                     return Transform.scale(
                       scale: scale,
                       child: Image.asset(
                         avatars[index],
                         color: Color.fromRGBO(255, 255, 255, scale),
                         colorBlendMode: BlendMode.modulate,
                       ),
                     );
                   },
                 );
               },
               itemCount: avatars.length,
               onPageChanged: onChangedHandler,
             ),
           );
         },
       );

  @override
  FormFieldState<int> createState() => __AvatarPickerWidgetState();
}

class __AvatarPickerWidgetState extends FormFieldState<int> {
  late final PageController _avatarController;

  PageController get controller => _avatarController;

  @override
  void initState() {
    _avatarController = PageController(initialPage: widget.initialValue ?? 0, viewportFraction: 0.35);
    super.initState();
  }

  @override
  void dispose() {
    _avatarController.dispose();
    super.dispose();
  }
}

class ScrollBasedSliverAppBarContentBuilder extends StatefulWidget {
  const ScrollBasedSliverAppBarContentBuilder({super.key, required this.builder});

  final Widget Function(BuildContext context, double opacity) builder;

  @override
  State<ScrollBasedSliverAppBarContentBuilder> createState() => _ScrollBasedSliverAppBarContentBuilderState();
}

class _ScrollBasedSliverAppBarContentBuilderState extends State<ScrollBasedSliverAppBarContentBuilder> {
  ScrollPosition? _position;
  late final FlexibleSpaceBarSettings settings;
  late final ValueNotifier<double> _opacityNotifier;

  @override
  void initState() {
    super.initState();
    _opacityNotifier = ValueNotifier(0);
    settings = context.getInheritedWidgetOfExactType<FlexibleSpaceBarSettings>()!;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_position != null) {
      _position!.removeListener(_positionListener);
    }
    _position = Scrollable.maybeOf(context)?.position;
    if (_position != null) {
      _position!.addListener(_positionListener);
    }
  }

  @override
  void dispose() {
    if (_position != null) {
      _position!.removeListener(_positionListener);
    }
    super.dispose();
  }

  void _positionListener() {
    _opacityNotifier.value = ((_position!.extentBefore - settings.minExtent) / 100).clamp(0.0, 1.0);
    // $logger.d(_position!.extentBefore - settings.minExtent);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: _opacityNotifier,
      builder: (context, value, _) {
        return widget.builder(context, value);
      },
    );
  }
}

// class _AccountModel extends Equatable {
//   final String? bankName;
//   final String? accountNumber;

//   const _AccountModel({this.bankName, this.accountNumber});

//   _AccountModel copyWith({String? bankName, String? accountNumber}) {
//     return _AccountModel(bankName: bankName ?? this.bankName, accountNumber: accountNumber ?? this.accountNumber);
//   }

//   @override
//   List<Object?> get props => [bankName, accountNumber];

//   Map<String, dynamic> toMap() => {'bankName': bankName, 'accountNumber': accountNumber};

//   factory _AccountModel.fromMap(Map<String, dynamic> map) {
//     return _AccountModel(bankName: map['bankName'] as String?, accountNumber: map['accountNumber'] as String?);
//   }

//   String toJson() => json.encode(toMap());

//   factory _AccountModel.fromJson(String source) => _AccountModel.fromMap(json.decode(source) as Map<String, dynamic>);
// }

// class _AccountWidget extends StatefulWidget {
//   const _AccountWidget({super.key, required this.account, this.onChanged});

//   // final void Function(String bankName, String accountNumber)? onChanged;
//   final _AccountModel account;
//   final ValueChanged<_AccountModel>? onChanged;

//   @override
//   State<_AccountWidget> createState() => __AccountWidgetState();
// }

// class __AccountWidgetState extends State<_AccountWidget> {
//   // late final TextEditingController _accountNumber;
//   late final ValueNotifier<String?> _bankName;
//   late final _AccountModel _account;

//   @override
//   void initState() {
//     super.initState();
//     // _accountNumber = TextEditingController(text: widget.account.accountNumber);
//     _bankName = ValueNotifier<String?>(widget.account.bankName);
//     _account = widget.account;
//   }

//   @override
//   void dispose() {
//     // _accountNumber.dispose();
//     _bankName.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Material(
//       color: theme.colorScheme.primary.withAlpha(30),
//       borderRadius: AppConstants.textFieldBorderRadius,
//       clipBehavior: Clip.antiAlias,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[
//           Row(
//             children: <Widget>[
//               Expanded(
//                 child: GestureDetector(
//                   onTap: () async {
//                     final newBank = await _selectBank(context);
//                     if (newBank == null) return;

//                     _bankName.value = newBank;
//                     widget.onChanged?.call(_account.copyWith(bankName: _bankName.value));
//                   },
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
//                     child: Row(
//                       children: <Widget>[
//                         Expanded(
//                           child: ValueListenableBuilder<String?>(
//                             valueListenable: _bankName,
//                             builder: (context, value, _) {
//                               return Text($PMBanks[value] ?? 'Select a bank');
//                             },
//                           ),
//                         ),
//                         const SizedBox(width: 8.0),
//                         const Icon(Icons.keyboard_arrow_down_rounded),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               Material(
//                 color: Colors.redAccent.withAlpha(60),
//                 child: InkWell(
//                   splashColor: Colors.redAccent.withAlpha(60),
//                   onTap: () => $logger.d('Deleting account'),
//                   child: const Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
//                     child: Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const InveslyDivider(),
//           TextFormField(
//             decoration: const InputDecoration(hintText: 'Account number, e.g. 1234567890', filled: false),
//             keyboardType: const TextInputType.numberWithOptions(),
//             validator: (value) {
//               if (value == null || !value.isValidText) return 'Please enter account number';

//               return null;
//             },
//             // controller: _accountNumber,
//             // onEditingComplete: () {
//             //   widget.onChanged?.call(_account.copyWith(accountNumber: _accountNumber.text));
//             // },
//             onChanged: (value) => widget.onChanged?.call(_account.copyWith(accountNumber: value)),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<String?> _selectBank(BuildContext context) async {
//     final bank = await showModalBottomSheet<String?>(
//       context: context,
//       builder: (context) {
//         return ListView.builder(
//           padding: const EdgeInsets.symmetric(vertical: 16.0),
//           itemBuilder: (context, index) {
//             final bank = $PMBanks.entries.elementAt(index);

//             return ListTile(
//               leading: CircleAvatar(child: Text(bank.value.substring(0, 1).toUpperCase())),
//               title: Text(bank.value),
//               onTap: () => Navigator.maybePop(context, bank.key),
//             );
//           },
//           itemCount: $PMBanks.length,
//         );
//       },
//     );

//     return bank;
//   }
// }

// class _AccountWidget2 extends FormField<_AccountModel> {
//   _AccountWidget2({
//     super.key,
//     super.initialValue,
//     ValueChanged<_AccountModel>? onChanged,
//     super.validator,
//     super.onSaved,
//   }) : super(
//          builder: (FormFieldState<_AccountModel> field) {
//            final state = field as __AccountWidget2State;
//            final theme = Theme.of(state.context);
//            final account = initialValue ?? const _AccountModel();

//            Future<String?> selectBank(BuildContext context) async {
//              final bank = await showModalBottomSheet<String?>(
//                context: context,
//                builder: (context) {
//                  return ListView.builder(
//                    padding: const EdgeInsets.symmetric(vertical: 16.0),
//                    itemBuilder: (context, index) {
//                      final bank = $PMBanks.entries.elementAt(index);

//                      return ListTile(
//                        leading: CircleAvatar(child: Text(bank.value.substring(0, 1).toUpperCase())),
//                        title: Text(bank.value),
//                        onTap: () => Navigator.maybePop(context, bank.key),
//                      );
//                    },
//                    itemCount: $PMBanks.length,
//                  );
//                },
//              );

//              return bank;
//            }

//            return Material(
//              color: theme.colorScheme.primary.withAlpha(30),
//              borderRadius: AppConstants.textFieldBorderRadius,
//              clipBehavior: Clip.antiAlias,
//              child: Column(
//                crossAxisAlignment: CrossAxisAlignment.start,
//                children: <Widget>[
//                  Row(
//                    children: <Widget>[
//                      Expanded(
//                        child: GestureDetector(
//                          onTap: () async {
//                            final newBank = await selectBank(state.context);
//                            if (newBank == null) return;

//                            state.bankName.value = newBank;
//                            onChanged?.call(account.copyWith(bankName: newBank));
//                          },
//                          child: Padding(
//                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
//                            child: Row(
//                              children: <Widget>[
//                                Expanded(
//                                  child: ValueListenableBuilder<String?>(
//                                    valueListenable: state.bankName,
//                                    builder: (context, value, _) {
//                                      return Text($PMBanks[value] ?? 'Select a bank');
//                                    },
//                                  ),
//                                ),
//                                const SizedBox(width: 8.0),
//                                const Icon(Icons.keyboard_arrow_down_rounded),
//                              ],
//                            ),
//                          ),
//                        ),
//                      ),
//                      Material(
//                        color: Colors.redAccent.withAlpha(60),
//                        child: InkWell(
//                          splashColor: Colors.redAccent.withAlpha(60),
//                          onTap: () => $logger.d('Deleting account'),
//                          child: const Padding(
//                            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
//                            child: Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
//                          ),
//                        ),
//                      ),
//                    ],
//                  ),
//                  const InveslyDivider(),
//                  TextFormField(
//                    decoration: const InputDecoration(hintText: 'Account number, e.g. 1234567890', filled: false),
//                    keyboardType: const TextInputType.numberWithOptions(),
//                    // onEditingComplete: () {
//                    //   widget.onChanged?.call(_account.copyWith(accountNumber: _accountNumber.text));
//                    // },
//                    onChanged: (value) => onChanged?.call(account.copyWith(accountNumber: value)),
//                  ),
//                ],
//              ),
//            );
//          },
//        );

//   @override
//   FormFieldState<_AccountModel> createState() => __AccountWidget2State();
// }

// class __AccountWidget2State extends FormFieldState<_AccountModel> {
//   // late final PageController _avatarController;
//   late final ValueNotifier<String?> bankName;
//   // late final _AccountModel account;

//   // PageController get controller => _avatarController;

//   @override
//   void initState() {
//     // _avatarController = PageController(initialPage: widget.initialValue ?? 0, viewportFraction: 0.35);
//     super.initState();
//     bankName = ValueNotifier<String?>(widget.initialValue?.bankName);
//     // account = widget.initialValue;
//   }

//   @override
//   void dispose() {
//     // _avatarController.dispose();
//     bankName.dispose();
//     super.dispose();
//   }
// }

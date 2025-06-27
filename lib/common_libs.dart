import 'dart:math';

import 'package:faker/faker.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

export 'common/extensions/buildcontext_extension.dart';
export 'common/extensions/datetime_extension.dart';
export 'common/extensions/map_extension.dart';
export 'common/extensions/num_extension.dart';
export 'common/extensions/string_extension.dart';

export 'common/presentations/components/checkbox.dart';
export 'common/presentations/components/choice_chips.dart';
export 'common/presentations/components/column_builder.dart';
export 'common/presentations/components/divider.dart';
export 'common/presentations/components/selection_indicator.dart';
export 'common/presentations/components/tab_indicator.dart';
export 'common/presentations/components/tappable.dart';
export 'common/presentations/components/tapzoom_effect.dart';
export 'common/presentations/widgets/date_picker.dart';
export 'common/presentations/widgets/empty_widget.dart';
export 'common/presentations/widgets/error_widget.dart';
export 'common/presentations/widgets/month_picker.dart';

export 'common/presentations/styles/constants.dart';

export 'package:collection/collection.dart';
export 'package:dynamic_color/dynamic_color.dart';
// export 'package:connectivity_plus/connectivity_plus.dart';
export 'package:equatable/equatable.dart';
export 'package:file_picker/file_picker.dart';
export 'package:flutter/material.dart';
export 'package:flutter/services.dart';
export 'package:flutter_bloc/flutter_bloc.dart';
export 'package:flutter_svg/flutter_svg.dart';
export 'package:hive/hive.dart';
export 'package:hive_flutter/hive_flutter.dart';
export 'package:hydrated_bloc/hydrated_bloc.dart';
export 'package:loading_animation_widget/loading_animation_widget.dart';
export 'package:percent_indicator/percent_indicator.dart';
export 'package:permission_handler/permission_handler.dart';
export 'package:rxdart/rxdart.dart';
export 'package:smooth_page_indicator/smooth_page_indicator.dart';
export 'package:sqflite/sqflite.dart';
// export 'router.dart';
export 'package:gap/gap.dart';
export 'package:flutter_spinkit/flutter_spinkit.dart';
export 'package:flutter_slidable/flutter_slidable.dart' hide ConfirmDismissCallback;

const $uuid = Uuid();
final $logger = Logger();
final $faker = Faker();
final $random = Random();

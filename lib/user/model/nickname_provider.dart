import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/screen/root_tab.dart';

final nicknameProvider = StateProvider<String?>((ref) => null);

final currentOrderProvider = StateProvider<MenuType>((ref) => MenuType.priority);
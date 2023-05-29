import 'dart:ffi';

import 'package:dodo/user/model/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final partnerNotifierProvider = StateNotifierProvider<PartnerNotifier, UserDomain?>((ref) => PartnerNotifier());
class PartnerNotifier extends StateNotifier<UserDomain?> {
  PartnerNotifier():
      super(null);
 void delete() {
   state = null;
 }
 void setPartner(UserDomain partner) {
   state = partner;
 }
}
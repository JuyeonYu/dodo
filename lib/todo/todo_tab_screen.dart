import 'package:dodo/common/const/colors.dart';
import 'package:dodo/todo/todo_screen.dart';
import 'package:dodo/user/model/partner_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../common/const/data.dart';

class TodoTabScreen extends ConsumerStatefulWidget {
  const TodoTabScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TodoTabScreen> createState() => _TodoTabScreenState();
}

class _TodoTabScreenState extends ConsumerState<TodoTabScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int tabIndex = 0;
  BannerAd banner = BannerAd(
    listener: BannerAdListener(
      onAdFailedToLoad: (Ad ad, LoadAdError error) {},
      onAdLoaded: (_) {},
    ),
    size: AdSize.banner,
    adUnitId: defaultTargetPlatform == TargetPlatform.android
        ? androidBannerId
        : iOSBannerId,
    request: const AdRequest(),
  )..load();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
    );
    _tabController.addListener(() {
      setState(() {
        tabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var state = ref.watch(partnerNotifierProvider);
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TabBar(
                  labelColor: TEXT_COLOR,
                  indicatorColor: PRIMARY_COLOR,
                  isScrollable: true,
                  tabs: [
                    const Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('나'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: state == null
                          ? const Text('초대된 사람이 없습니다.')
                          : Text(ref.watch(partnerNotifierProvider)!.name),
                    ),
                  ],
                  controller: _tabController),
            ),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: <Widget>[
                TodoScreen(
                  isMine: true,
                ),
                TodoScreen(
                  isMine: false,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 50,
            child: AdWidget(ad: banner),
          )
        ],
      ),
    );
  }
}

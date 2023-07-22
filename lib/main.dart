import 'dart:async';
import 'dart:convert';

import 'package:auto_bitcoin/data/CandleData.dart';
import 'package:auto_bitcoin/data/LogData.dart';
import 'package:auto_bitcoin/data/RealTimeTradeData.dart';
import 'package:auto_bitcoin/data/Socket_NowPrice.dart';
import 'package:auto_bitcoin/data/TrackingData.dart';
import 'package:auto_bitcoin/models/res_account.dart';
import 'package:auto_bitcoin/models/res_martket_code.dart';
import 'package:auto_bitcoin/providers/NetworkProvider.dart';
import 'package:auto_bitcoin/view/Market_List.dart';
import 'package:auto_bitcoin/view/View_Chart.dart';
import 'package:auto_bitcoin/view/Volume_Chart.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:window_manager/window_manager.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Must add this line.
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1000, 800),
    minimumSize: Size(1000, 800),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  runApp(const MyApp());

  /// Listen for all incoming data
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // ignore: prefer_const_constructors
    return MaterialApp(
      title: 'Flutter Demo',
      home: const MyHomePage(title: 'Hiro Match Program'),
      theme: ThemeData(
          primarySwatch: Colors.green,
          scrollbarTheme: ScrollbarThemeData(
              thickness: MaterialStateProperty.all(10),
              thumbColor: MaterialStateProperty.all(
                  const Color.fromARGB(255, 57, 47, 151)),
              radius: const Radius.circular(10),
              minThumbLength: 10)),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  final int _counter = 0;
  var channel;
  final ScrollController _scrollController = ScrollController();
  Map<String, List<CandleData>> price_data = {};
  List<ItemMarketCode>? codeList;
  List<String> selectMarketCode = [];
  String selectCandleData = '';
  String targetMarketCode = '';
  List<String> targetIndex = [];
  String balance = '';
  String locked = '';
  String total = '';
  String tradeModey = '';
  String isBuyPrice = '';
  String isSellPrice = '';
  List<ResAccount> account = [];
  late TabController _tabController;

  final List<Stack> myTabs2 = [];

  bool trackingMode = false;
  String trackingCode = '';
  TrackingData? trackingData;
  int trackingLastTrade = 0;

  List<LogData> trackingLog = [];

  Map<String, Map<DateTime, RealTimeTradeData>> realTrade = {};

  Stack coinTab(String title) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
          ),
        ),
        const Align(
          alignment: Alignment.topRight,
          child: IconButton(
              alignment: Alignment.topRight,
              onPressed: null,
              icon: Icon(
                Icons.check,
                color: Colors.white,
                size: 15,
              )),
        ),
      ],
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMarketCode();
    _tabController = TabController(length: myTabs2.length, vsync: this);
  }

  Future getAccountInfo() async {
    var data = await NetworkProvider().getAccountInfo();
    if (data != null) {
      account = data;
      //avg_buy_price
      setState(() {
        if (data.length > 1 && trackingCode.isNotEmpty) {
          var td = data[data.indexWhere((element) =>
              trackingCode.replaceAll('KRW', '').contains(element.currency))];
          isBuyPrice = td.avg_buy_price.toString();
          trackingData =
              TrackingData(marketCode: trackingCode, price: isBuyPrice);
          trackingLog.add(LogData(
              log:
                  "${codeList![codeList!.indexWhere((forele) => forele.market == trackingCode)].koreanName!} 매수 : ${(double.parse(td.balance) * double.parse(td.avg_buy_price)).floor()} 원",
              time: DateFormat('yyyy-mm-dd hh:mm:ss').format(DateTime.now())));
        } else {
          isBuyPrice = '';
        }
        tradeModey = double.parse(data[0].balance).floor().toString();
        balance =
            '${double.parse(data[0].balance).floor()} ${data[0].unit_currency}';
        locked =
            '${double.parse(data[0].locked).floor()} ${data[0].unit_currency}';
        total =
            '${(double.parse(data[0].balance) + double.parse(data[0].locked)).floor()} ${data[0].unit_currency}';
      });
    }
  }

  Future getAccountInfoAndSell() async {
    var data = await NetworkProvider().getAccountInfo();
    if (data != null)
      // ignore: curly_braces_in_flow_control_structures
      for (var element in data) {
        if (selectMarketCode.contains('KRW-${element.currency}')) {
          orderToMarket('ask', targetMarketCode, element.balance);
        } else if (trackingCode.contains('KRW-${element.currency}')) {
          orderToMarket('ask', targetMarketCode, element.balance);
          trackingData = null;
          trackingCode = '';
        }
      }
  }

  Future getMarketCode() async {
    var data = await NetworkProvider().getMarketCode();
    setState(() {
      codeList = data;
    });
  }

  Future orderToMarket(String type, String marketCode, String price) async {
    var data = await NetworkProvider().order(type, marketCode, price);
    setState(() {
      Timer(const Duration(seconds: 5), () {
        getAccountInfo();
      });
    });
  }

  Future getCandleData() async {
    // myTabs2.clear();
    var data = await NetworkProvider().getMinuteCandle(selectCandleData);
    targetMarketCode = selectCandleData;
    targetIndex.add(targetMarketCode);
    selectMarketCode.add(selectCandleData);
    if (channel != null) {
      channel.sink.close();
    }
    print('TTT : $selectCandleData');
    if (data != null) {
      List<CandleData> list = [];
      for (var element in data) {
        var candleData = CandleData(
            time: DateTime.parse(element.candleDateTimeKst!),
            low: element.lowPrice,
            high: element.highPrice,
            open: element.openingPrice,
            close: element.tradePrice,
            volume: element.candleAccTradeVolume);
        list.add(candleData);

        // if (price_data[targetIndex].isEmpty) {
        // price_data.add([candleData]);
        // } else {
        //   price_data[targetIndex].add(candleData);
        // }
      }
      price_data[targetMarketCode] = list;
    }
    setState(() {
      myTabs2.add(coinTab(targetMarketCode));
      _tabController = TabController(length: myTabs2.length, vsync: this);
      _tabController.animateTo(myTabs2.length - 1);
    });
    _requestData();
  }

  String _listToStringCode() {
    String data = '';
    for (var element in selectMarketCode) {
      data += '"$element",';
    }

    return data.substring(0, data.lastIndexOf(','));
  }

  _requestData() {
    channel = IOWebSocketChannel.connect(
        Uri.parse('wss://api.upbit.com/websocket/v1'));
    channel.sink.add(
        '[{"ticket": "test"},{"type": "ticker","codes": [${_listToStringCode()}]}]');
    setState(() {
      trackingLog.add(LogData(
          log: "트래킹 시작",
          time: DateFormat('yyyy-mm-dd hh:mm:ss').format(DateTime.now())));
    });
    channel.stream.listen(
      (data) {
        // print(String.fromCharCodes(data));
        setState(() {
          var realTimeData =
              Socket_NowPrice.fromJson(jsonDecode(String.fromCharCodes(data)));
          var contain = price_data[realTimeData.code]!
              .where((element) => element.time == realTimeData.timestamp);

          var realtime = price_data[realTimeData.code]!;

          // 매도 타이밍 감지
          if (trackingMode && trackingData != null) {
            // 매수하였던 종목의 정보 수신
            if (trackingData!.marketCode == realTimeData.code) {
              // 매수한금액보다 3% 금액이 떨어진 경우 매도
              if (double.parse(trackingData!.price) * 0.97 >
                  realTimeData.tradePrice) {
                if (trackingMode) {
                  trackingData = null;
                  trackingMode = false;
                  trackingCode = '';
                  trackingLog.add(LogData(
                      log: "3% 손절하였습니다.",
                      time: DateFormat('yyyy-mm-dd hh:mm:ss')
                          .format(DateTime.now())));
                  getAccountInfoAndSell(); //전량 매도
                }
              } else

              // 매수한금액보다 3% 금액이 인상된 경우 매도
              if (double.parse(trackingData!.price) * 1.03 <=
                  realTimeData.tradePrice) {
                if (trackingMode) {
                  trackingData = null;
                  trackingMode = false;
                  trackingCode = '';
                  trackingLog.add(LogData(
                      log: '3% 익절하였습니다.',
                      time: DateFormat('yyyy-mm-dd hh:mm:ss')
                          .format(DateTime.now())));
                  getAccountInfoAndSell(); //전량 매도
                }
              }
            }
          } else if (realtime.length != trackingLastTrade) {
            // 매수 타이밍 감지
            var nowPrice = realtime.first.close; // 현재가
            var nowVolume = realtime.first.volume; // 현재거래량

            var dCloseprice = realtime[realtime.length - 2].close; // 전 종가
            var ddCloseprice = realtime[realtime.length - 3].close; // 전전 종가

            var dVolume = realtime[realtime.length - 2].volume; // 전 거래량
            var ddVolume = realtime[realtime.length - 3].volume; // 전전 거래량

            if (nowPrice > dCloseprice &&
                nowPrice > ddCloseprice &&
                nowVolume > dVolume * 1.5 &&
                nowVolume > ddVolume * 1.2) {
              if (!trackingMode) {
                trackingMode = true;
                trackingLastTrade = realtime.length;
                trackingCode = realTimeData.code!;
                orderToMarket('bid', realTimeData.code!,
                    (int.parse(tradeModey) * 0.9).toString());
              }
            }
          }

          //캔들 데이터 그리기
          if (contain.isNotEmpty) {
            int index = price_data[realTimeData.code]!.indexWhere(
                (element) => element.time == realTimeData.timestamp);

            var candleData = CandleData(
                time: realTimeData.timestamp,
                low: (price_data[realTimeData.code]![index].low! <
                        realTimeData.tradePrice)
                    ? price_data[realTimeData.code]![index].low
                    : realTimeData.tradePrice,
                high: (price_data[realTimeData.code]![index].high! >
                        realTimeData.tradePrice)
                    ? price_data[realTimeData.code]![index].high
                    : realTimeData.tradePrice,
                open: price_data[realTimeData.code]![index].open,
                close: realTimeData.tradePrice,
                volume: price_data[realTimeData.code]![index].volume +
                    realTimeData.tradeVolume);

            price_data[realTimeData.code]![index] = candleData;
          } else {
            var candleData = CandleData(
                time: realTimeData.timestamp,
                low: realTimeData.tradePrice,
                high: realTimeData.tradePrice,
                open: realTimeData.tradePrice,
                close: realTimeData.tradePrice,
                volume: realTimeData.tradeVolume);
            price_data[realTimeData.code]!.add(candleData);
          }
        });
      },
      onError: (error) => print(error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          backgroundColor: Colors.grey.shade800,
          foregroundColor: Colors.white,
          toolbarHeight: 30,
          title: const Padding(
            padding: EdgeInsets.only(left: 60),
            child: Text(
              'Hiro Match Program',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
        ),
        body: Container(
          color: const Color.fromARGB(255, 20, 20, 28),
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  child: Row(
                children: [
                  const Text(
                    "지갑 정보",
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(
                    width: 100,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(width: 1),
                        color: const Color.fromARGB(255, 57, 47, 151)),
                    child: GestureDetector(
                      onTap: () => getAccountInfo(),
                      child: const Text(
                        '연결',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 50,
                  ),
                  Container(
                    child: Row(
                      children: [
                        Container(
                          child: codeList != null
                              ? MarketList(codeList, (String marketCode) {
                                  selectCandleData = marketCode;
                                })
                              : null,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(width: 1),
                              color: const Color.fromARGB(255, 57, 47, 151)),
                          child: GestureDetector(
                            onTap: () => getCandleData(),
                            child: const Text(
                              '등록',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        if (selectMarketCode.isNotEmpty)
                          for (var element in selectMarketCode)
                            Row(
                              children: [
                                const SizedBox(
                                  width: 5,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(width: 1),
                                      color: Colors.deepPurpleAccent),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        codeList![codeList!.indexWhere(
                                                (forele) =>
                                                    forele.market ==
                                                    element.replaceAll(
                                                        '"', ''))]
                                            .koreanName!,
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 12),
                                      ),
                                      IconButton(
                                        padding: const EdgeInsets.only(
                                            left: 10, top: 5, bottom: 5),
                                        constraints: const BoxConstraints(),
                                        onPressed: () {
                                          setState(() {
                                            var index = selectMarketCode
                                                .indexWhere((index) =>
                                                    index == element);
                                            myTabs2.removeAt(index);
                                            _tabController = TabController(
                                                length: myTabs2.length,
                                                vsync: this);

                                            if (_tabController.index == index) {
                                              _tabController.animateTo(0);
                                            }
                                            targetIndex.removeAt(index);
                                            selectMarketCode.remove(element);
                                          });
                                        },
                                        iconSize: 15,
                                        icon: const Icon(
                                          Icons.cancel,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                      ],
                    ),
                  )
                ],
              )),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "총 자산",
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Container(
                          alignment: Alignment.centerRight,
                          width: 200,
                          decoration: BoxDecoration(
                              color: Colors.grey.shade800,
                              borderRadius: BorderRadius.circular(5)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 5,
                              horizontal: 10,
                            ),
                            child: Text(
                              total,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w300,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Text(
                          "사용 가능 자산",
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Container(
                          alignment: Alignment.centerRight,
                          width: 200,
                          decoration: BoxDecoration(
                              color: Colors.grey.shade800,
                              borderRadius: BorderRadius.circular(5)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 5,
                              horizontal: 10,
                            ),
                            child: Text(
                              balance,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w300,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Text(
                          "일일 수익률",
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Container(
                          alignment: Alignment.centerRight,
                          width: 200,
                          decoration: BoxDecoration(
                              color: Colors.grey.shade800,
                              borderRadius: BorderRadius.circular(5)),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 5,
                              horizontal: 10,
                            ),
                            child: Text(
                              "2.78 %",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w300,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Text(
                          "전체 수익률",
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Container(
                          alignment: Alignment.centerRight,
                          width: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade800,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 5,
                              horizontal: 10,
                            ),
                            child: Text(
                              "12.78 %",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w300,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Text(
                          "로그",
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Container(
                          padding: const EdgeInsets.all(5),
                          color: const Color.fromARGB(255, 28, 25, 46),
                          width: 200,
                          height: 250,
                          child: Scrollbar(
                            thumbVisibility: true,
                            controller: _scrollController,
                            child: ListView.builder(
                              controller: _scrollController,
                              itemCount: trackingLog.length,
                              itemBuilder: (context, index) {
                                _scrollController.jumpTo(
                                    _scrollController.position.maxScrollExtent);
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 3),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        trackingLog[index].time,
                                        style: const TextStyle(
                                            color: Colors.red, fontSize: 11),
                                      ),
                                      Text(
                                        trackingLog[index].log,
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        children: [
                          Container(
                            width: 700,
                            height: 300,
                            color: const Color.fromARGB(255, 28, 25, 46),
                            child: Scaffold(
                              appBar: AppBar(
                                backgroundColor:
                                    const Color.fromARGB(255, 28, 25, 46),
                                toolbarHeight: 1,
                                bottom: TabBar(
                                  controller: _tabController,
                                  onTap: (int index) {
                                    setState(() {
                                      targetMarketCode = targetIndex[index];
                                    });
                                  },
                                  indicatorColor: Colors.white,
                                  tabs: myTabs2,
                                ),
                              ),
                              body: Container(
                                color: const Color.fromARGB(255, 20, 20, 28),
                                child: TabBarView(
                                  controller: _tabController,
                                  children: myTabs2.map((Stack tab) {
                                    return ViewChart(
                                      price_data[targetMarketCode],
                                      isBuyPrice,
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 700,
                            height: 150,
                            color: const Color.fromARGB(255, 28, 25, 46),
                            child: price_data[targetMarketCode] != null
                                ? VolumeChart(price_data[targetMarketCode])
                                : null,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              Container(
                                height: 200,
                                width: 150,
                                color: const Color.fromARGB(255, 28, 25, 46),
                              ),
                              const SizedBox(
                                width: 40,
                              ),
                              Container(
                                height: 200,
                                width: 150,
                                color: const Color.fromARGB(255, 28, 25, 46),
                              ),
                              const SizedBox(
                                width: 30,
                              ),
                              Container(
                                height: 200,
                                width: 300,
                                color: const Color.fromARGB(255, 28, 25, 46),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "매수 금액",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 12),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Container(
                                        alignment: Alignment.centerRight,
                                        width: 200,
                                        decoration: BoxDecoration(
                                            color: Colors.grey.shade800,
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 5,
                                            horizontal: 10,
                                          ),
                                          child: Text(
                                            "",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w300,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 50,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 3,
                                              ),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border: Border.all(width: 1),
                                                  color: Colors.red),
                                              child: GestureDetector(
                                                onTap: () => orderToMarket(
                                                    'bid',
                                                    targetMarketCode,
                                                    (int.parse(tradeModey) *
                                                            0.9)
                                                        .toString()),
                                                child: const Text(
                                                  '시장가 전량 매수',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 3,
                                              ),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border: Border.all(width: 1),
                                                  color: Colors.blue),
                                              child: GestureDetector(
                                                onTap: () =>
                                                    getAccountInfoAndSell(),
                                                child: const Text(
                                                  '시장가 전량 매도',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}

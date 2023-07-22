import 'package:auto_bitcoin/data/CandleData.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

var colorRed = const Color.fromARGB(255, 224, 41, 74);
var colorGreen = const Color.fromARGB(255, 46, 189, 133);
var colorbackground = const Color.fromARGB(255, 28, 25, 46);

class ViewChart extends StatelessWidget {
  const ViewChart(this.priceData, this.isBuyPrice, {super.key});

  final List<CandleData>? priceData;
  final isBuyPrice;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SfCartesianChart(
        backgroundColor: colorbackground,
        zoomPanBehavior: ZoomPanBehavior(enableMouseWheelZooming: true),
        onTrackballPositionChanging: (TrackballArgs args) {
          args.chartPointInfo.label = "test";
        },
        trackballBehavior: TrackballBehavior(enable: true),
        series: <ChartSeries>[
          CandleSeries<CandleData, DateTime>(
            dataSource: priceData!,
            enableSolidCandles: true,
            bearColor: colorRed,
            bullColor: colorGreen,
            xValueMapper: (CandleData data, _) => data.time,
            highValueMapper: (CandleData data, _) => data.high,
            lowValueMapper: (CandleData data, _) => data.low,
            openValueMapper: (CandleData data, _) => data.open,
            closeValueMapper: (CandleData data, _) => data.close,
            name: 'Bollinger',
            // name: 'HiloOpenClose',
          ),
        ],
        // primaryYAxis: NumericAxis(minimum: 2700, maximum: 3200, interval: 50),
        // primaryXAxis: DateTimeAxis(),
        primaryYAxis: NumericAxis(
          plotBands: <PlotBand>[
            if (isBuyPrice.isNotEmpty)
              PlotBand(
                isVisible: true,
                start: isBuyPrice,
                end: isBuyPrice,
                text: 'bye',
                horizontalTextAlignment: TextAnchor.end,
                textStyle: const TextStyle(
                  color: Colors.yellow,
                ),
                borderWidth: 1,
                borderColor: Colors.yellow,
              ),
          ],
          majorGridLines: const MajorGridLines(width: 0.2),
          opposedPosition: true,
          numberFormat: NumberFormat.compact(),
        ),
        primaryXAxis: DateTimeAxis(
          minimum: DateTime.now().subtract(
            const Duration(minutes: 50),
          ),
          maximum: DateTime.now().add(
            const Duration(minutes: 10),
          ),
          majorGridLines: const MajorGridLines(width: 0.2),
          intervalType: DateTimeIntervalType.minutes,
          desiredIntervals: 5,
          interval: 5,
        ),
        // indicators: <TechnicalIndicators<dynamic, dynamic>>[
        //   BollingerBandIndicator<dynamic, dynamic>(
        //       period: 5, seriesName: 'Bollinger')
        // ],
      ),
    );
  }
}

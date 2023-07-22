import 'package:auto_bitcoin/data/CandleData.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

var colorRed = const Color.fromARGB(168, 224, 41, 75);
var colorGreen = const Color.fromARGB(168, 46, 189, 133);

class VolumeChart extends StatelessWidget {
  const VolumeChart(this.priceData, {super.key});

  final List<CandleData>? priceData;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SfCartesianChart(
        series: <ChartSeries>[
          ColumnSeries<CandleData, DateTime>(
            animationDuration: 0,
            dataSource: priceData!,
            xValueMapper: (CandleData data, _) => data.time,
            yValueMapper: (CandleData data, _) => data.volume,
            pointColorMapper: (CandleData data, _) =>
                data.open < data.close ? colorGreen : colorRed,
          ),
        ],
        primaryYAxis: NumericAxis(
          majorGridLines: const MajorGridLines(width: 0.2),
          numberFormat: NumberFormat.compact(),
          opposedPosition: true,
        ),
        primaryXAxis: DateTimeAxis(
          majorGridLines: const MajorGridLines(width: 0.2),
          minimum: DateTime.now().subtract(
            const Duration(minutes: 50),
          ),
          maximum: DateTime.now().add(
            const Duration(minutes: 10),
          ),
          intervalType: DateTimeIntervalType.minutes,
          desiredIntervals: 5,
          interval: 5,
        ),
      ),
    );
  }
}

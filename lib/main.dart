import 'package:flutter/material.dart';

void main() => runApp(const CalcApp());

class CalcApp extends StatelessWidget {
  const CalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const Calculator(),
    );
  }
}

class Calculator extends StatefulWidget {
  const Calculator({super.key});

  @override
  State<Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  String display = '0';
  double? first;
  String? op;
  bool newInput = true;

  String fmt(double v) {
    if (v.isNaN || v.isInfinite) return 'خطأ';
    return v == v.truncateToDouble()
        ? v.toInt().toString()
        : v.toString();
  }

  double calc(double a, double b, String o) {
    switch (o) {
      case '+':
        return a + b;
      case '-':
        return a - b;
      case '×':
        return a * b;
      case '÷':
        return b == 0 ? double.nan : a / b;
    }
    return b;
  }

  void press(String k) {
    setState(() {
      if (k == 'C') {
        display = '0';
        first = null;
        op = null;
        newInput = true;
      } else if (k == '⌫') {
        if (display.length > 1 && !newInput) {
          display = display.substring(0, display.length - 1);
        } else {
          display = '0';
          newInput = true;
        }
      } else if (k == '±') {
        if (display != '0' && display != 'خطأ') {
          display = display.startsWith('-')
              ? display.substring(1)
              : '-$display';
        }
      } else if (k == '%') {
        final v = double.tryParse(display);
        if (v != null) display = fmt(v / 100);
      } else if (['+', '-', '×', '÷'].contains(k)) {
        final cur = double.tryParse(display);
        if (cur == null) return;
        if (first != null && op != null && !newInput) {
          final r = calc(first!, cur, op!);
          display = fmt(r);
          first = r.isNaN ? null : r;
        } else {
          first = cur;
        }
        op = k;
        newInput = true;
      } else if (k == '=') {
        final cur = double.tryParse(display);
        if (first != null && op != null && cur != null) {
          display = fmt(calc(first!, cur, op!));
          first = null;
          op = null;
          newInput = true;
        }
      } else if (k == '.') {
        if (newInput) {
          display = '0.';
          newInput = false;
        } else if (!display.contains('.')) {
          display += '.';
        }
      } else {
        if (newInput || display == '0') {
          display = k;
          newInput = false;
        } else {
          display += k;
        }
      }
    });
  }

  Widget btn(String t, {Color? color}) {
    final isOp = ['+', '-', '×', '÷', '='].contains(t);
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: SizedBox(
          height: 72,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  color ?? (isOp ? Colors.orange : const Color(0xFF2A2F3A)),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () => press(t),
            child: Text(t, style: const TextStyle(fontSize: 26)),
          ),
        ),
      ),
    );
  }

  Widget row(List<String> keys) =>
      Row(children: keys.map((k) => btn(k)).toList());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.all(24),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    display,
                    style: const TextStyle(
                        fontSize: 72, fontWeight: FontWeight.w300),
                  ),
                ),
              ),
            ),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Column(
                children: [
                  row(['C', '⌫', '%', '÷']),
                  row(['7', '8', '9', '×']),
                  row(['4', '5', '6', '-']),
                  row(['1', '2', '3', '+']),
                  row(['±', '0', '.', '=']),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
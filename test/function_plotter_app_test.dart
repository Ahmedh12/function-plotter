import 'package:flutter_test/flutter_test.dart';

import 'package:function_plotter/function_plotter_app.dart';

void main() {
  late FunctionPlotterApp app;
  late dynamic element;
  late dynamic state;
  setUp(() {
    app = FunctionPlotterApp();
    element = app.createElement();
    state = element.state as FunctionPlotterAppState;
  });

  test('should build without crashing', () {
    expect(app, isNotNull);
  });

  group("testing input validation", () {
    test('Accept numeric input', () {
      expect(state.isValid('1'), isTrue);
    });

    test('Reject non-numeric input', () {
      expect(state.isValid('a'), isFalse);
    });

    test('Accept only x as an alphabetic input', () {
      expect(state.isValid('a'), isFalse);
    });

    test('Reject empty input', () {
      expect(state.isValid(''), isFalse);
    });
  });

  group("testing input parsing", () {
    test('Parse valid input', () {
      expect(state.parseEquation('1'), isNotNull);
    });

    test('Reject invalid input', () {
      expect(state.parseEquation('a'), []);
    });

    test('Reject empty input', () {
      expect(state.parseEquation(''), []);
    });

    test('Parse x as an alphabetic input', () {
      expect(state.parseEquation('x'), isNotNull);
    });

  });
}

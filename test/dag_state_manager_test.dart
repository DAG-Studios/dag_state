// MIT License

// Copyright (c) 2022 DAG Studios

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import 'package:mockito/mockito.dart';
import 'package:dag_state/dag_state.dart';
import 'package:flutter_test/flutter_test.dart';

abstract class TestState extends State<String> {
  final String _s;
  String _testStr='';
  bool valid;
  TestState(String name, [bool initialValid=true]):_s=name, valid=initialValid;

  @override
  String get value => _s;

  @override
  bool get isAvailable => valid;

  String get testString {
    return _testStr;
  }

  set testString(String str) {
    _testStr = str;
    notifyListeners();
  }
}

class State1 extends TestState {State1([bool valid=true]):super('State1', valid);}
class State2 extends TestState {State2([bool valid=true]):super('State2', valid);}
class State3 extends TestState {State3([bool valid=true]):super('State3', valid);}
class State4 extends TestState {State4([bool valid=true]):super('State4', valid);}

class MockCounter extends Mock {
  call();
}

void main() {
  group('Good State Manager', () {
    State1 firstState = State1();
    StateManager sm = StateManager(
      stateStreams: {'stream1':
        StateStream([
          firstState,
          State2(),
          State3()
        ]),
        'stream2':
        StateStream([
          State2(),
          State3(),
          State4()
        ], repeating: true)
      },
      initialStream: 'stream1'
    );
    final countSMNotify = MockCounter();
    final countState1Notify = MockCounter();
    firstState.addListener(countState1Notify);
    sm.addListener(countSMNotify);

    setUp(() {
      // Test Notify
      reset(countState1Notify);
      reset(countSMNotify);
    });
    test('Streams 1&2', () {
      expect(sm.currentState.value, 'State1');
      sm.nextState();
      expect(sm.currentState.value, 'State2');
      sm.nextState();
      expect(sm.currentState.value, 'State3');
      sm.nextState();
      expect(sm.currentState.value, 'State3');
      sm.changeStream('stream2');
      expect(sm.currentState.value, 'State2');
      sm.nextState();
      expect(sm.currentState.value, 'State3');
      sm.nextState();
      expect(sm.currentState.value, 'State4');
      sm.nextState();
      expect(sm.currentState.value, 'State2');
      sm.changeStream('stream1');
      expect(sm.currentState.value, 'State3');
      sm.resetStream();
      expect(sm.currentState.value, 'State1');
      verifyNever(countState1Notify());
      verify(countSMNotify()).called(8);
    });
    test('State1 Notify', () {
      firstState.testString = 'Hello';
      verifyNever(countSMNotify());
      verify(countState1Notify()).called(1);
    });
  });

  group('Conditional State Manager', () {
    State2 secondState = State2(false);
    StateManager sm = StateManager(
      stateStreams: {'stream1':
        StateStream([
          State1(true),
          secondState,
          State3(true)
        ]),
        'stream2':
        StateStream([
          State2(false),
          State3(true),
          State4(true)
        ], repeating: true)
      },
      initialStream: 'stream1'
    );
    final countSMNotify = MockCounter();
    final countState2Notify = MockCounter();
    secondState.addListener(countState2Notify);
    sm.addListener(countSMNotify);

    setUp(() {
      // Test Notify
      reset(countState2Notify);
      reset(countSMNotify);
    });
    test('Streams 1&2', () {
      expect(sm.currentState.value, 'State1');
      sm.nextState();
      expect(sm.currentState.value, 'State3');
      sm.nextState();
      expect(sm.currentState.value, 'State3');
      sm.changeStream('stream2');
      expect(sm.currentState.value, 'State3');
      sm.nextState();
      expect(sm.currentState.value, 'State4');
      sm.nextState();
      expect(sm.currentState.value, 'State3');
      sm.changeStream('stream1');
      expect(sm.currentState.value, 'State3');
      sm.resetStream();
      expect(sm.currentState.value, 'State1');
      secondState.valid=true;
      sm.nextState();
      expect(sm.currentState.value, 'State2');
      sm.nextState();
      expect(sm.currentState.value, 'State3');
      sm.nextState();
      expect(sm.currentState.value, 'State3');
      sm.changeStream('stream2');
      expect(sm.currentState.value, 'State3');
      sm.resetStream();
      expect(sm.currentState.value, 'State3');
      verifyNever(countState2Notify());
      verify(countSMNotify()).called(10);
    });
  });

  group('State Manager No Initial Stream', () {
    StateManager sm = StateManager(
      stateStreams: {'stream1':
        StateStream([
          State1(),
          State2(),
          State3()
        ]),
        'stream2':
        StateStream([
          State2(),
          State3(),
          State4()
        ], repeating: true)
      },
    );
    test('No initial, change to 1', () {
      expect(() => sm.currentState.value.data, throwsA(isA<NoCurrentStateStream>()));
      sm.nextState();
      expect(() => sm.currentState.value.data, throwsA(isA<NoCurrentStateStream>()));
      sm.changeStream('stream1');
      expect(sm.currentState.value, 'State1');
      sm.changeStream('foo');
      expect(sm.currentState.value, 'State1');
      sm.nextState();
      sm.nextState();
      expect(sm.currentState.value, 'State3');
      sm.changeStream('stream2');
      expect(sm.currentState.value, 'State2');
      sm.changeStream('stream1', resetState: true);
      expect(sm.currentState.value, 'State1');
    });
  });
}
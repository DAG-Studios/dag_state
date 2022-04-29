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

import 'package:dag_state/dag_state.dart';
import 'package:flutter_test/flutter_test.dart';

abstract class TestState implements State<String> {
  final String _s;
  TestState(String name):_s=name;
  @override
  String get value => _s;
}
class State1 extends TestState {State1():super('State1');}
class State2 extends TestState {State2():super('State2');}
class State3 extends TestState {State3():super('State3');}
class State4 extends TestState {State4():super('State4');}

void main() {
  group('Good State Manager', () {
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
      initialStream: 'stream1'
    );
    test('State Stream 1', () {
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
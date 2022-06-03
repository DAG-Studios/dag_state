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

library dag_state;
import 'package:flutter/foundation.dart';

abstract class State<T> extends ChangeNotifier {
  T get value;  
}

class StateStream<T> {
  final List<State<T>> _states;
  final bool _repeats;
  int _currentState;

  StateStream(this._states, {bool repeating=false}):_repeats=repeating,_currentState=_states.isNotEmpty?0:-1;
  State get currentState {
    return _states[_currentState];
  }

  bool nextState() {
    if (_currentState < _states.length-1) {
      _currentState++;
    }
    else if (_currentState == _states.length-1 && _repeats) {
      _currentState=0;
    }
    else {
      return false;
    }
    return true;
  }

  State reset() {
    _currentState=0;
    return currentState;
  }
}

class StateManager<T> extends ChangeNotifier {
  final Map<String,StateStream<T>> _streams;
  StateStream? _currentStream;

  StateManager({required Map<String,StateStream<T>> stateStreams, String? initialStream, bool throwOnInvalidStream=false}):_streams=stateStreams {
    _currentStream = _streams[initialStream];
    if (_currentStream != null) {
      notifyListeners();
    }
  }

  void changeStream(String streamName, {bool resetState=false}) {
    StateStream? newStream = _streams[streamName];
    if (newStream == null) {
      return;
    }

    if (resetState) {
      newStream.reset();
    }
    _currentStream = newStream;
    notifyListeners();
  }

  void resetStream() {
    _currentStream?.reset();
    notifyListeners();
  }

  void nextState() {
    if (_currentStream?.nextState()??false) {
      notifyListeners();
    }
  }

  State get currentState {
    if (_currentStream?.currentState == null) {
      throw NoCurrentStateStream();
    }
    return _currentStream!.currentState;
  }
}

class NoCurrentStateStream implements Exception {
  @override
  String toString() => 'There is no current stream';
}

class UnknownStateStream implements Exception {
  final String _streamName;

  UnknownStateStream(String streamName):_streamName=streamName;

  @override
  String toString() => 'No stream named: $_streamName';
}
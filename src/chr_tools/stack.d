/*
**  Chronos Ouroboros' D Tools
**  Copyright (C) 2016  Chronos Ouroboros
**
**  This program is free software; you can redistribute it and/or modify
**  it under the terms of the GNU General Public License as published by
**  the Free Software Foundation; either version 2 of the License, or
**  (at your option) any later version.
**
**  This program is distributed in the hope that it will be useful,
**  but WITHOUT ANY WARRANTY; without even the implied warranty of
**  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
**  GNU General Public License for more details.
**
**  You should have received a copy of the GNU General Public License along
**  with this program; if not, write to the Free Software Foundation, Inc.,
**  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
*/

/++
 + Defines a customizable stack type
++/
module chr_tools.stack;

/++
 + A generic stack type
++/
public class Stack (T) {
    private T [] _stackArray;
    private int _index = 0;
    private uint _max = 1000;

    /// The current stack index
    @property int index () { return _index; }
    /// The amount of things in the stack
    @property int count () { return _index + 1; }
    /// The stack's max
    @property uint max () { return max; }
    /// Whether or not the stack is full
    @property bool isFull () {
        if (_index == _max - 1)
            return true;
        else
            return false;
    }
    /// Whether or not the stack is empty
    @property bool isEmpty () {
        if (_index == 0)
            return true;
        else
            return false;
    }

    @disable this ();

    /// Constructs a stack with the specified maximum value
    this (uint max) {
        _stackArray.length = max;
        _max = max;
        _index = 0;
    }

    Stack opBinary (string op) (Stack!(T) rhs) {
        // Appends the righthand stack to the lefthand stack. If there's not enough space, it resizes the stack
        // The difference between this and push (Stack!(T)) is that this resizes the stack instead of only appending whatever fits
        static if (op == "~") {
            if (count + s2.count > _max)
                resize (count + s2.count);
            _stackArray ~= s2.asArray;
        } else
            static assert(0, "Operator " ~ op ~ " not implemented");
    }

    /// Resizes the stack
    bool resize (uint sz) {
        int oldSize = _max;
        _max = sz;
        _stackArray.length = sz;

        if (_stackArray.length == _max)
            return true;
        else if (_stackArray.length == oldSize) {
            _max = oldSize;
            return false;
        } else {
            _max = oldSize;
            _stackArray.length = oldSize;
            return false;
        }
    }

    /// Inserts a value into the stack
    bool push (T value) {
        if (_stackArray.length != _max)
            this.resize (_max);

        if (_index + 1 < _max) {
            _index++;
            _stackArray [_index] = value;
            return true;
        } else {
            return false;
        }
    }

    /++
     + Inserts an array of values into the stack
     + Returns: The amount of values inserted
    ++/
    int push (T [] values) {
        if (_stackArray.length != _max)
            this.resize (_max);
        
        int i = 0;

        for (; i < values.length; i++) {
            if (_index < _max - 1) {
                _index++;
                _stackArray [_index] = values [i];
            } else
                break;
        }

        return i + 1;
    }

    /++ Appends the contents of another stack to the stack
     +  Returns: The amount of values inserted
    ++/
    int push (Stack!(T) s2) {
        return this.push (s2.asArray);
    }

    /++ Retrieves a value without removing it from the stack
     +  Returns: The retrieved value or null if the stack is empty
    ++/
    T peek () {
        if (_index >= 0)
            return _stackArray [_index];
        else
            return null;
    }

    /++ Retrieves a value and removes it from the stack
     +  Returns: The retrieved value or null if the stack is empty
    ++/
    T pop () {
        if (_index >= 0) {
            _index--;
            return _stackArray [_index + 1];
        } else {
            return null;
        }
    }

    /// Returns the stack's contents as an array
    T [] asArray () { return _stackArray; }
}

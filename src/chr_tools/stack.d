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

class StackException : Exception {
    public this (string message, string file = __FILE__, int _line = __LINE__) {
        super (message, file, _line);
    }
}

/++
 + A generic stack type
++/
public class Stack (T, bool autoGrow = false) {
    protected T[] _stackArray;
    protected int _index = 0;
    protected uint _max = 1000;

    /// The current stack index
    @property int index () { return _index; }
    /// The amount of things in the stack
    @property int count () { return (_index + 1); }
    /// The stack's maximum capacity
    @property uint max () { return max; }
    /// Whether or not the stack is full
    @property bool isFull () { return (_index == _max - 1); }
    /// Whether or not the stack is empty
    @property bool isEmpty () { return (_index == 0); }

    @disable this ();

    /// Constructs a stack with the specified maximum value
    this (uint max) {
        _stackArray.length = max;
        _max = max;
        _index = 0;
    }

    /// Implements the concatenation operator.
    Stack opBinary (string op) (Stack!(T) rhs) {
        // Appends the righthand stack to the lefthand stack. If there's not enough space, it resizes the stack
        // The difference between this and push (Stack!(T)) is that this resizes the stack instead of only appending whatever fits
        static if (op == "~") {
            if (count + rhs.count > _max)
                resize (count + rhs.count);
            _stackArray ~= rhs.asArray;
        } else
            static assert (0, "Operator " ~ op ~ " not implemented");
    }

    /// Resizes the stack
    bool resize (uint sz) {
        const (int) oldSize = _max;
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
        static if (autoGrow) {
            if ((_index + 1) >= _max)
                resize (_max + (_max >> 2));
        } else {
            if ((_index + 1) >= _max)
                return false;
        }

        if (_stackArray.length != _max)
            this.resize (_max);

        _index++;
        _stackArray [_index] = value;
        return true;
    }

    /++
     + Inserts an array of values into the stack
     + Returns: The amount of values inserted
    ++/
    int push (T[] values) {
        static if (autoGrow) {
            const (int) newCount = (_index + values.length);
            if (newCount >= _max) {
                int newSize = _max + (_max >> 2);

                if (newCount >= newSize)
                    newSize = _max + (_max >> 2) + values.length;

                resize (newSize);
            }
        }

        if (_stackArray.length != _max)
            this.resize (_max);

        int i = 0;

        for (; i < values.length; i++) {
            if (_index >= _max - 1)
                break;

            _index++;
            _stackArray [_index] = values [i];
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
        if (_index < 1)
            throw new StackException ("Stack is empty");

        return _stackArray [_index];
    }

    /++ Retrieves a value and removes it from the stack
     +  Returns: The retrieved value or null if the stack is empty
    ++/
    T pop () {
        if (_index < 1)
            throw new StackException ("Stack is empty");

        _index--;
        return _stackArray [_index + 1];
    }

    /// Returns the stack's contents as an array
    T[] asArray () { return _stackArray.dup; }
}

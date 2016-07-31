/*
**  ??? - A DSFML game
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
 + Defines a customizable fixed-point type and other fixed-point arithmetic related functions
++/
module fixedpoint;

import std.string;
import std.math;

/++
 + Fixed point math functions
 + These functions might be slow, as they don't use LUTs like it is traditionally done with fixed-point.
++/
static struct FixedMath {
    // Constants
    static const Fixed!(int, 29) pi = 0x0;
    
    // Trig functions
    static T abs (T) (T x) {
        return x._value < 0 ? -x._value : x._value;
    }

    static uint toBAM (T) (T val) if (is (TemplateOf!(T) == Fixed)) {
        auto intermediary = val.precisionBits > 30 ? val.withPrecision!(uint, 28) : val;
        return cast (uint) (intermediary._value) << (32 - intermediary.precisionBits);
    }

    static T sin (T) (T val) if (is (TemplateOf!(T) == Fixed)) {
        if (!tablesGenerated)
            generateTables ();

        return fineSine [toBAM (val) >> 19];
    }

    static T cos (T) (T val) if (is (TemplateOf!(T) == Fixed)) {
        if (!tablesGenerated)
            generateTables ();

        return fineSine [(toBAM (val) + fineAngles / 4) >> 19];
    }

    // Trig functions LUT generation stuff
    // Ported from ZDoom 2.8.1's sourcecode
    static const int fineAngleBits = 13;
    static const int fineAngles    = 1 << fineAngleBits;
    static const int fracUnit      = 1 << 16;
    static bool tablesGenerated = false;
    static Fixed!(int, 13) [5 * fineAngles / 4] fineSine;
    static Fixed!(int, 13) [fineAngles / 2] fineTangent;

    static void generateTables (bool forceRegen = false) {
        if (this.tablesGenerated && !forceRegen)
            return;

        int i;
        double pimul = (cast (double) this.pi) * 2 / this.fineAngles;

        // viewangle tangent table
        this.fineTangent [0] = (this.fracUnit * std.math.tan ((0.5 - this.fineAngles / 4) * pimul) + 0.5);
        for (i = 1; i < this.fineAngles / 2; i++)
            this.fineTangent [i] = (this.fracUnit * std.math.tan ((i - this.fineAngles / 4) * pimul) + 0.5);
        
        // this.fineSine table
        for (i = 0; i < this.fineAngles / 4; i++)
            this.fineSine [i] = (this.fracUnit * std.math.sin (i * pimul));

        for (i = 0; i < this.fineAngles / 4; i++)
            this.fineSine [i + this.fineAngles / 4] = this.fineSine [this.fineAngles / 4 - 1 - i];

        for (i = 0; i < this.fineAngles / 2; i++)
            this.fineSine [i + this.fineAngles / 2] = -this.fineSine [i];

        this.fineSine[this.fineAngles / 4] = this.fracUnit;
        this.fineSine[this.fineAngles * 3 / 4] = -this.fracUnit;

        int n = 2;//4 * this.fineAngles / 4;
        int j = 0;

        while (n--) {
            this.fineSine [this.fineAngles + j] = this.fineSine [0 + j];
            j++;
        }

        this.tablesGenerated = true;
    }
}

/++
 + A customizable fixed-point type that can have any arbitrary precision
 + Arguments:
++/
struct Fixed (T, uint _precisionBits) {
protected:
    static immutable T _scale = cast (T) ((cast (T) 1) << _precisionBits);
    T _frac = _scale - 1;
    T _value;

public:
    @property pure nothrow real toReal () const { return cast (real) this; }
    alias toReal this;
    /*@property pure nothrow real toBool () { return cast (bool) this; }
    alias toBool this;*/

    static pure nothrow Fixed!(T2, _precisionBits) makeFixed (T2 : int, uint _precisionBits) (T2 _value) {
        Fixed!(T2, _precisionBits) ret;
        ret._value = _value;
        return ret;
    }
    static pure nothrow Fixed makeFixed (T2 : int) (T2 value) {
        Fixed!(T, _precisionBits) ret;
        ret._value = cast (T) value;
        return ret;
    }

    /++
     + Gets a copy of this fixed-point in another precision
     + Returns: An exact copy of the fixed-point in another precision
    ++/
    pure nothrow Fixed withPrecision (T2 : T, uint precBits) () {
        double intermediary = this._value / this._frac;
        T2 mask = (1 << precBits) - 1;
        return makedFixed!(T2, precBits) (cast (T2) (intermediary * mask));
    }

    /++
     + Gets the fractional mask for a fixed-point with this precision.
     + Returns: A fixed-point with all fractional bits set as a variable of type <T>.
    ++/
    @property pure nothrow immutable T fracMask () { return this._frac; }
    /+
     + Gets the scale value for a fixed-point with this precision.
     + Returns: "1.0" as a fixed point of this precision as a variable of type <T>.
    ++/
    @property pure nothrow immutable T scale () { return this._scale; }
    /+
     + Gets the fractional precision as the number of bits.
     + Returns: The number of bits used for the fractional part.
    ++/
    @property pure nothrow immutable T precisionBits () { return _precisionBits; }

    
    /// Sets the fixed-point's underlying value as a variable of type <T>.
    @property pure nothrow T value (T newVal) { return this._value = newVal; }
    /// Gets the fixed-point's underlying value as a variable of type <T>.
    @property pure nothrow T value () { return this._value; }

    static immutable T min = T.min;
    static immutable T max = T.max;

    /+
     + Converts an integer of type <valT> to a fixed-point value of integer type <fixT> with the specified scale.
     + 
     +
     +
     + Returns: The integer converted to a fixed-point value as a variable of type <fixT>.
    ++/
    static fixT convertInteger (fixT, valT) (fixT scale, valT value) {
        static if (fixT.max > valT.max && fixT.min < valT.min)
            return value * (scale - 1);
        else {
            valT fix = value * (scale - 1);
            fixT whole = cast (fixT) (fix & ~(scale - 1)),
                 frac  = cast (fixT) (fix &  (scale - 1));
            return whole | frac;
        }
    }

    /*
    **
    ** Constructors
    **
    */
    // Unsigned integers types:
    this (ubyte  newVal) { this._value = convertInteger!(T, ubyte)  (_scale, newVal); }
    this (ushort newVal) { this._value = convertInteger!(T, ushort) (_scale, newVal); }
    this (uint   newVal) { this._value = convertInteger!(T, uint)   (_scale, newVal); }
    this (ulong  newVal) { this._value = convertInteger!(T, ulong)  (_scale, newVal); }
    // Signed integer types:
    this (byte  newVal) { this._value = convertInteger!(T, byte)  (_scale, newVal); }
    this (short newVal) { this._value = convertInteger!(T, short) (_scale, newVal); }
    this (int   newVal) { this._value = convertInteger!(T, int)   (_scale, newVal); }
    this (long  newVal) { this._value = convertInteger!(T, long)  (_scale, newVal); }
    // Floating-point types:
    this (real newVal) {
        this._value = cast (T) (newVal * _frac);
    }

    /*
    **
    ** Unary Operators
    **
    */
    pure nothrow Fixed opUnary (string op) () {
        static if (op == "*")
            static assert (0, "Operator * not implemented");
        else if (op == "-" || op == "+" || op == "~")
            return makeFixed!(int, _precisionBits) (mixin (op ~ "this._value"));
        else if (op == "++") {
            this._value += _frac;
            return this;
        } else if (op == "--") {
            this._value -= _frac;
            return this;
        }
    }

    /*
    **
    ** Binary Operators
    **
    */
    pure nothrow Fixed opBinary (string op) (Fixed rhs) {
        static if (op == "+" || op == "-") {
            if (rhs._scale == this._scale)
                return makeFixed!(T, _precisionBits) (cast (T) mixin ("this._value " ~ op ~ " rhs._value"));
            else
                return makeFixed!(T, _precisionBits) (cast (T) mixin ("this._value " ~ op ~ " ((cast (real) rhs._value / rhs._frac) * this._frac)"));
        } else if (op == "%")
            return makeFixed!(T, _precisionBits) (cast (T) mixin ("((this._value / this._frac) " ~ op ~ " (cast (real) rhs._value / rhs._frac)) * this._frac"));
        else if (op == "*" || op == "/" || op == "&" || op == "^" || op == "|" || op == ">>" || op == "<<" || op == ">>>")
            return makeFixed!(T, _precisionBits) (cast (T) mixin ("this._value " ~ op ~ " (cast (real) rhs._value / rhs._frac)"));
    }
    private nothrow Fixed intBinaryOps (T2, string op) (T2 rhs) {
        static if (op == "+" || op == "-")
            return makeFixed!(T, _precisionBits) (cast (T) mixin ("this._value " ~ op ~ " cast (T) (rhs * _frac)"));
        else if (op == "%")
            return makeFixed!(T, _precisionBits) (cast (T) mixin ("((this._value / this._frac) " ~ op ~ " rhs) * this._frac"));
        else if (op == "*" || op == "/" || op == "&" || op == "^" || op == "|" || op == ">>" || op == "<<" || op == ">>>")
            return makeFixed!(T, _precisionBits) (cast (T) mixin ("this._value " ~ op ~ " cast (T) rhs"));
    }
    // Unsigned integer binary ops:
    pure nothrow Fixed opBinary (string op, T2 : ubyte) (T2 rhs) { return intBinaryOps!(T2,  op) (rhs); }
    // Signed integer binary ops:
    pure nothrow Fixed opBinary (string op, T2 : byte) (T2 rhs) { return intBinaryOps!(T2,  op) (rhs); }
    // Floating point ops:
    pure nothrow Fixed opBinary (string op, T2 : float) (T2 rhs) { return intBinaryOps!(T2,  op) (rhs); }

    /*
    **
    ** Assignment
    **
    */
    pure nothrow Fixed opAssign (Fixed rhs) {
        T val;

        if (rhs._scale == this._scale)
            this._value = rhs._value;
        else
            this._value = (rhs._value / rhs._frac) * this._value;

        return this;
    }
    // Unsigned integer op assignments:
    pure nothrow Fixed opAssign (T2 : ubyte) (T2 rhs) { this._value = cast (T) (rhs * _frac); return this; }
    // Signed integer op assignments:
    pure nothrow Fixed opAssign (T2 : byte) (T2  rhs) { this._value = cast (T) (rhs * _frac); return this; }
    // Floating point assignments:
    pure nothrow Fixed opAssign (T2 : float) (T2  rhs) { this._value = cast (T) (rhs * _frac); return this; }

    /*
    **
    ** Op assignment
    **
    */
    pure nothrow Fixed opOpAssign (string op) (Fixed rhs) {
        static if (op == "+" || op == "-") {
            if (rhs._scale == this._scale)
                this._value = cast (T) mixin ("this._value " ~ op ~ " rhs._value");
            else
                this._value = cast (T) mixin ("this._value " ~ op ~ " ((cast (real) rhs._value / rhs._frac) * this._frac)");
        } else if (op == "%")
            this._value = cast (T) mixin ("((this._value / this._frac) " ~ op ~ " (cast (real) rhs._value / rhs._frac)) * this._frac");
        else if (op == "*" || op == "/" || op == "&" || op == "^" || op == "|" || op == ">>" || op == "<<" || op == ">>>")
            this._value = cast (T) mixin ("this._value " ~ op ~ " (cast (real) rhs._value / rhs._frac)");

        return this;
    }
    private nothrow Fixed intAssignOps (T2, string op) (T2 rhs) {
        static if (op == "+" || op == "-")
            mixin ("this._value = this._value " ~ op ~ " cast (T) (rhs * _frac);");
        else if (op == "%")
            mixin ("this._value = ((this._value / this._frac) " ~ op ~ " rhs) * this._frac;");
        else if (op == "*" || op == "/" || op == "&" || op == "^" || op == "|" || op == ">>" || op == "<<" || op == ">>>")
            mixin ("this._value = this._value " ~ op ~ " cast (T) rhs;");

        return this;
    }
    // Unsigned integer op assignments:
    pure nothrow Fixed opOpAssign (string op, T2 : ubyte) (T2 rhs) { intAssignOps!(T2,  op) (rhs); return this; }
    // Signed integer op assignments:
    pure nothrow Fixed opOpAssign (string op, T2 : byte) (T2 rhs) { intAssignOps!(T2,  op) (rhs); return this; }
    // Floating point op assignments:
    pure nothrow Fixed opOpAssign (string op, T2 : float) (T2 rhs) { intAssignOps!(T2,  op) (rhs); return this; }

    /*
    **
    ** Casting
    **
    */
    // Signed integer casting:
    pure nothrow T2 opCast (T2 : int) () const {
        return cast (T2) (this._value / this._frac);
    }

    pure nothrow T2 opCast (T2 : float) () const {
        return cast (T2) ((cast (T2) this._value) / this._frac);
    }

    pure nothrow T2 opCast (T2 : bool) () const {
        return this._value >= 0;
    }



    // Unsigned integer casting:

    // String
    @property string asString () const { return toString (); }

    string toString () const {
        return format ("%.22f", cast (double) _value / _frac);
    }
}
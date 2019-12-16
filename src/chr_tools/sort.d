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

module chr_tools.sort;

void sortNullsInPlace (T) (T[] arr) {
    for (uint i = 0; i < arr.length; i++) {
        if (arr [i] is null) {
            uint j = i;
            for (; j < arr.length; j++) {
                if (!(arr [j] is null))
                    break;
            }

            if (j >= arr.length)
                continue;

            arr [i] = arr [j];
            arr [j] = null;
        }
    }
}

T[] sortNulls (T) (T[] arr) {
    T[] sortedArr;
    size_t index;

    sortedArr.length = arr.length;
    sortedArr [] = null;
    for (uint i = 0; i < arr.length; i++) {
        if (!(arr [i] is null)) {
            sortedArr [index] = arr [i];
            index++;
        }
    }

    return sortedArr;
}
/*
**  Chronos Ouroboros' D Tools
**  Copyright (C) 2016-2019 Chronos "phantombeta" Ouroboros
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

module chr_tools.bbcodes;

/*import std.regex;

struct bbcodeRegexEntry {
    @disable this ();

    StaticRegex exp;
    string format;

    this (StaticRegex regExp, string formatString) {
        exp = regExp;
        format = formatString;
    }
}

static const bbcodeRegexEntry [] bbCodesList = {
    new bbcodeRegexEntry (ctRegex ("\\[b\\](.*?)\\[/b\\]"), // bold
    "<b>$1</b>"),

    new bbcodeRegexEntry (ctRegex ("\\[i\\](.*?)\\[/i\\]"), // italic
    "<i>$1</i>"),

    new bbcodeRegexEntry (ctRegex ("\\[u\\](.*?)\\[/u\\]"), // underline
    "<span style=\"text-decoration:underline;\">$1</span>"),

    new bbcodeRegexEntry (ctRegex ("\\[s\\](.*?)\\[/s\\]"), // strikethrough
    "<strike>$1</strike>"),

    new bbcodeRegexEntry (ctRegex ("\\[quote\\](.*?)\\[/quote\\]"), // quote
    "<pre>$1</pre>"),

    new bbcodeRegexEntry (ctRegex ("\\[size=(.*?)\\](.*?)\\[/size\\]"), // size
    "<span style=\"font-size:$1px;\">$2</span>"),

    new bbcodeRegexEntry (ctRegex ("\\[color=(.*?)\\](.*?)\\[/color\\]"), // color
    "<span style=\"color:$1;\">$2</span>"),

    new bbcodeRegexEntry (ctRegex ("\\[url=\"((?:ftp|https?)://.*?)\"\\](.*?)\\[/url\\]"), // url
    "<a href=\"$1\">$2</a>"),

    new bbcodeRegexEntry (ctRegex ("\\[img\\](https?://.*?\\.(?:jpg|jpeg|gif|png|bmp))\\[/img\\]"), // img
    "<img src=\"$1\" alt="" />"),

    new bbcodeRegexEntry (ctRegex ("\\[nl\\]"), // newline
    "<br />"),

    new bbcodeRegexEntry (ctRegex ("\\[spoilerbox(=\"(.*?)\")?\\](.*?)\\[/spoilerbox\\]"), // spoilerbox
    "<div class=\"spoilerbox\"><div class=\"spoilertitle\">$2 <input onclick=\"node = this.parentNode.parentNode.getElementsByClassName (&quot;spoilercontent&quot;)[0]; if (node.style.display != '') { node.style.display = ''; this.value = 'Hide'; } else { node.style.display = 'none'; this.value = 'Show'; }\" value=\"Show\" class=\"spoilerbutton\" type=\"button\"></div><div class=\"spoilercontent\" style=\"display: none;\">$3</div></div>"),

    new bbcodeRegexEntry (ctRegex ("\\[spoiler\\](.*?)\\[/spoiler\\]"), // spoiler
    "<span class=\"spoiler\" title=\"Click to show\" onClick=\"if (this.className == 'spoiler') { this.className = 'spoilerClicked'; } else { this.className = 'spoiler'; }\">$1</span>"),

    new bbcodeRegexEntry (ctRegex ("\\[center\\](.*?)\\[/center\\]"), // center text
    "<p style=\"text-align: center;\"></p>"),
};

static pure string parsebbCode (string input) {
    string ret = input;

    foreach (code; bbCodesList)
        ret = replaceAll (ret, code.exp, code.format);

    return ret;
}*/
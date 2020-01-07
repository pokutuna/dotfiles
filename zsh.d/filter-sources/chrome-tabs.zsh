#!/usr/bin/env bash

# original: https://www.rasukarusan.com/entry/2019/12/20/000000

function getChromeTabs() {
osascript << EOF
    set _output to ""
    tell application "Google Chrome"
        set _window_index to 1
        repeat with w in windows
            set _tab_index to 1
            repeat with t in tabs of w
                set _title to get title of t
                set _url to get URL of t
                set _output to (_output & _window_index & "\t" & _tab_index & "\t" & _url & "\t" & _title & "\n")
                set _tab_index to _tab_index + 1
            end repeat
            set _window_index to _window_index + 1
            if _window_index > count windows then exit repeat
        end repeat
    end tell
    return _output
EOF
}

function setChromeActiveTab() {
local _window_index=$1
local _tab_index=$2
osascript -- - "$_window_index" "$_tab_index" << EOF
on run argv
    set _window_index to item 1 of argv
    set _tab_index to item 2 of argv
    tell application "Google Chrome"
        activate
        set index of window (_window_index as number) to (_window_index as number)
        set active tab index of window (_window_index as number) to (_tab_index as number)
    end tell
end run
EOF
}

chrome() {
    local selected
    IFS=$'\t' read -r -a selected < <(
        getChromeTabs | sed '/^$/d' | fzf --delimiter $'\t' --with-nth 4 --preview 'echo {3}' --preview-window down:1 "$@"
    )
    [ ${#selected[@]} -lt 2 ] && return 130
    setActiveTab ${selected[0]} ${selected[1]}
}

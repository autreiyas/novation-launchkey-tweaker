// keystroke_helper — sends a keystroke via CGEvents
// Usage: keystroke_helper <key> [modifier,modifier,...]
// Example: keystroke_helper l
//          keystroke_helper s cmd
//          keystroke_helper f5 cmd,shift

import CoreGraphics
import Foundation
import ApplicationServices

let keyCodes: [String: CGKeyCode] = [
    "a": 0, "s": 1, "d": 2, "f": 3, "h": 4, "g": 5, "z": 6, "x": 7,
    "c": 8, "v": 9, "b": 11, "q": 12, "w": 13, "e": 14, "r": 15,
    "y": 16, "t": 17, "1": 18, "2": 19, "3": 20, "4": 21, "6": 22,
    "5": 23, "=": 24, "9": 25, "7": 26, "-": 27, "8": 28, "0": 29,
    "]": 30, "o": 31, "u": 32, "[": 33, "i": 34, "p": 35,
    "enter": 36, "return": 36, "l": 37, "j": 38, "k": 40,
    ";": 41, ",": 43, "/": 44, "n": 45, "m": 46, ".": 47,
    "tab": 48, "space": 49, "`": 50, "delete": 51, "backspace": 51,
    "escape": 53, "esc": 53,
    "f1": 122, "f2": 120, "f3": 99, "f4": 118, "f5": 96, "f6": 97,
    "f7": 98, "f8": 100, "f9": 101, "f10": 109, "f11": 103, "f12": 111,
    "up": 126, "down": 125, "left": 123, "right": 124,
    "home": 115, "end": 119, "pageup": 116, "pagedown": 121,
]

let modifierFlags: [String: CGEventFlags] = [
    "cmd": .maskCommand,
    "command": .maskCommand,
    "shift": .maskShift,
    "alt": .maskAlternate,
    "opt": .maskAlternate,
    "option": .maskAlternate,
    "ctrl": .maskControl,
    "control": .maskControl,
]

guard CommandLine.arguments.count >= 2 else {
    fputs("Usage: keystroke_helper <key> [modifiers]\n", stderr)
    exit(1)
}

let keyName = CommandLine.arguments[1].lowercased()
guard let keyCode = keyCodes[keyName] else {
    fputs("ERROR: Unknown key: \(keyName)\n", stderr)
    exit(1)
}

// Check Accessibility trust
let trusted = AXIsProcessTrusted()
if !trusted {
    fputs("ERROR: Not trusted for Accessibility. Add this binary to System Settings → Privacy & Security → Accessibility.\n", stderr)
    exit(2)
}

var flags = CGEventFlags()
if CommandLine.arguments.count >= 3 {
    for mod in CommandLine.arguments[2].lowercased().split(separator: ",") {
        if let flag = modifierFlags[String(mod)] {
            flags.insert(flag)
        }
    }
}

let source = CGEventSource(stateID: .combinedSessionState)
guard let keyDown = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: true),
      let keyUp = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: false) else {
    fputs("ERROR: Failed to create CGEvent\n", stderr)
    exit(3)
}

if !flags.isEmpty {
    keyDown.flags = flags
    keyUp.flags = flags
}

// Small delay to let FL Studio finish processing the MIDI callback
usleep(50_000)  // 50ms

keyDown.post(tap: .cghidEventTap)
usleep(10_000)  // 10ms between down and up
keyUp.post(tap: .cghidEventTap)
fputs("OK: sent key=\(keyName) code=\(keyCode)\n", stderr)

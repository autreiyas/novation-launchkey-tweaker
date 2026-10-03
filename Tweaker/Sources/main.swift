import SwiftUI
import CoreGraphics
import ApplicationServices

let args = CommandLine.arguments

if args.count >= 3, args[1] == "--keystroke" {
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
        "cmd": .maskCommand, "command": .maskCommand,
        "shift": .maskShift,
        "alt": .maskAlternate, "opt": .maskAlternate, "option": .maskAlternate,
        "ctrl": .maskControl, "control": .maskControl,
    ]

    let keyName = args[2].lowercased()
    guard let keyCode = keyCodes[keyName] else {
        fputs("Unknown key: \(keyName)\n", stderr)
        exit(1)
    }

    var flags = CGEventFlags()
    if args.count >= 4 {
        for mod in args[3].lowercased().split(separator: ",") {
            if let flag = modifierFlags[String(mod)] {
                flags.insert(flag)
            }
        }
    }

    // Try CGEvents first (requires Accessibility trust)
    let trusted = AXIsProcessTrusted()
    if trusted {
        let source = CGEventSource(stateID: .combinedSessionState)
        if let keyDown = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: true),
           let keyUp = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: false) {
            if !flags.isEmpty {
                keyDown.flags = flags
                keyUp.flags = flags
            }
            keyDown.post(tap: .cghidEventTap)
            usleep(10_000)
            keyUp.post(tap: .cghidEventTap)
            fputs("OK(CGEvent): \(keyName)\n", stderr)
            exit(0)
        }
    }

    // Fallback: use inline AppleScript (no separate osascript process)
    let specialKeyCodes: [String: Int] = [
        "return": 36, "enter": 36, "tab": 48, "space": 49,
        "delete": 51, "backspace": 51, "escape": 53, "esc": 53,
        "up": 126, "down": 125, "left": 123, "right": 124,
        "home": 115, "end": 119, "pageup": 116, "pagedown": 121,
        "f1": 122, "f2": 120, "f3": 99, "f4": 118, "f5": 96, "f6": 97,
        "f7": 98, "f8": 100, "f9": 101, "f10": 109, "f11": 103, "f12": 111,
    ]

    let modMap = [
        "cmd": "command down", "command": "command down",
        "shift": "shift down",
        "alt": "option down", "opt": "option down", "option": "option down",
        "ctrl": "control down", "control": "control down",
    ]

    var modParts: [String] = []
    if args.count >= 4 {
        for mod in args[3].lowercased().split(separator: ",") {
            if let m = modMap[String(mod)] { modParts.append(m) }
        }
    }
    let usingClause = modParts.isEmpty ? "" : " using {\(modParts.joined(separator: ", "))}"

    let script: String
    if let code = specialKeyCodes[keyName] {
        script = "tell application \"System Events\" to key code \(code)\(usingClause)"
    } else if keyName.count == 1 {
        script = "tell application \"System Events\" to keystroke \"\(keyName)\"\(usingClause)"
    } else {
        fputs("Unknown key for AppleScript fallback: \(keyName)\n", stderr)
        exit(1)
    }

    if let appleScript = NSAppleScript(source: script) {
        var error: NSDictionary?
        appleScript.executeAndReturnError(&error)
        if let err = error {
            fputs("AppleScript error: \(err)\n", stderr)
            exit(4)
        }
        fputs("OK(AppleScript): \(keyName)\n", stderr)
    } else {
        fputs("Failed to create AppleScript\n", stderr)
        exit(5)
    }
    exit(0)
} else {
    TweakerApp.main()
}

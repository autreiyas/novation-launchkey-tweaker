// keystroke_server — background daemon that reads from a FIFO
// and sends keystrokes via CGEvents.
//
// Usage: tweaker_keystroke_server
// Reads from ~/.tweaker/keystroke.fifo
// Protocol: one line per keystroke — "key" or "key modifiers"
//   e.g. "l" or "s cmd,shift"

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

func sendKeystroke(_ line: String) {
    let parts = line.trimmingCharacters(in: .whitespacesAndNewlines)
        .lowercased()
        .split(separator: " ", maxSplits: 1)
    guard !parts.isEmpty else { return }

    let keyName = String(parts[0])
    guard let keyCode = keyCodes[keyName] else {
        fputs("Unknown key: \(keyName)\n", stderr)
        return
    }

    var flags = CGEventFlags()
    if parts.count > 1 {
        for mod in parts[1].split(separator: ",") {
            if let flag = modifierFlags[String(mod)] {
                flags.insert(flag)
            }
        }
    }

    let source = CGEventSource(stateID: .combinedSessionState)
    guard let keyDown = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: true),
          let keyUp = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: false) else {
        fputs("Failed to create CGEvent\n", stderr)
        return
    }

    if !flags.isEmpty {
        keyDown.flags = flags
        keyUp.flags = flags
    }

    keyDown.post(tap: .cghidEventTap)
    usleep(10_000)
    keyUp.post(tap: .cghidEventTap)
    fputs("Sent: \(keyName)\n", stderr)
}

// --- FIFO setup ---

let fifoDir = FileManager.default.homeDirectoryForCurrentUser
    .appendingPathComponent(".tweaker")
let fifoPath = fifoDir.appendingPathComponent("keystroke.fifo").path

// Create FIFO if it doesn't exist
if !FileManager.default.fileExists(atPath: fifoPath) {
    let result = mkfifo(fifoPath, 0o644)
    if result != 0 && errno != EEXIST {
        fputs("Failed to create FIFO: \(String(cString: strerror(errno)))\n", stderr)
        exit(1)
    }
}

// Check accessibility
if !AXIsProcessTrusted() {
    fputs("WARNING: Not trusted for Accessibility. Add this binary to System Settings → Privacy & Security → Accessibility.\n", stderr)
}

fputs("Keystroke server reading from \(fifoPath)\n", stderr)

// Signal handling for clean shutdown
signal(SIGINT) { _ in exit(0) }
signal(SIGTERM) { _ in exit(0) }

// Read loop — open blocks until a writer connects
while true {
    guard let fh = FileHandle(forReadingAtPath: fifoPath) else {
        fputs("Failed to open FIFO\n", stderr)
        usleep(500_000)
        continue
    }

    let data = fh.readDataToEndOfFile()
    fh.closeFile()

    if let message = String(data: data, encoding: .utf8) {
        for line in message.split(separator: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty {
                sendKeystroke(trimmed)
            }
        }
    }
}

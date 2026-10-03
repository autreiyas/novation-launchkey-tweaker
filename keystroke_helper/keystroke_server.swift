// tweaker_keystroke_server — background daemon that polls a command file
// and sends keystrokes via CGEvents (or AppleScript fallback).
//
// Usage: tweaker_keystroke_server
// Polls ~/.tweaker/keystroke_cmd every 50ms
// Protocol: one line per keystroke — "key" or "key modifiers"
//   e.g. "l" or "r cmd,shift"

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
    "cmd": .maskCommand, "command": .maskCommand,
    "shift": .maskShift,
    "alt": .maskAlternate, "opt": .maskAlternate, "option": .maskAlternate,
    "ctrl": .maskControl, "control": .maskControl,
]

func sendKeystrokeCGEvent(_ keyName: String, _ mods: [String]) -> Bool {
    guard let keyCode = keyCodes[keyName] else {
        fputs("Unknown key: \(keyName)\n", stderr)
        return false
    }

    var flags = CGEventFlags()
    for mod in mods {
        if let flag = modifierFlags[mod] {
            flags.insert(flag)
        }
    }

    let source = CGEventSource(stateID: .combinedSessionState)
    guard let keyDown = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: true),
          let keyUp = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: false) else {
        fputs("Failed to create CGEvent\n", stderr)
        return false
    }

    if !flags.isEmpty {
        keyDown.flags = flags
        keyUp.flags = flags
    }

    keyDown.post(tap: .cghidEventTap)
    usleep(10_000)
    keyUp.post(tap: .cghidEventTap)
    fputs("Sent(CGEvent): \(keyName)\n", stderr)
    return true
}

func sendKeystrokeAppleScript(_ keyName: String, _ mods: [String]) -> Bool {
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
    for mod in mods {
        if let m = modMap[mod] { modParts.append(m) }
    }
    let usingClause = modParts.isEmpty ? "" : " using {\(modParts.joined(separator: ", "))}"

    let script: String
    if let code = specialKeyCodes[keyName] {
        script = "tell application \"System Events\" to key code \(code)\(usingClause)"
    } else if keyName.count == 1 {
        script = "tell application \"System Events\" to keystroke \"\(keyName)\"\(usingClause)"
    } else {
        fputs("Unknown key for AppleScript: \(keyName)\n", stderr)
        return false
    }

    // Use /usr/bin/osascript as a subprocess (Apple-signed binary)
    let proc = Process()
    proc.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
    proc.arguments = ["-e", script]
    let pipe = Pipe()
    proc.standardError = pipe
    do {
        try proc.run()
        proc.waitUntilExit()
        if proc.terminationStatus == 0 {
            fputs("Sent(AppleScript): \(keyName)\n", stderr)
            return true
        } else {
            let errData = pipe.fileHandleForReading.readDataToEndOfFile()
            let errStr = String(data: errData, encoding: .utf8) ?? "unknown error"
            fputs("AppleScript failed: \(errStr)\n", stderr)
            return false
        }
    } catch {
        fputs("Failed to run osascript: \(error)\n", stderr)
        return false
    }
}

func sendKeystroke(_ line: String) {
    let parts = line.trimmingCharacters(in: .whitespacesAndNewlines)
        .lowercased()
        .split(separator: " ", maxSplits: 1)
    guard !parts.isEmpty else { return }

    let keyName = String(parts[0])
    var mods: [String] = []
    if parts.count > 1 {
        mods = parts[1].split(separator: ",").map { String($0) }
    }

    // Try CGEvents first (needs Accessibility trust)
    if AXIsProcessTrusted() {
        if sendKeystrokeCGEvent(keyName, mods) { return }
    }

    // Fallback: osascript subprocess
    _ = sendKeystrokeAppleScript(keyName, mods)
}

// --- Polling setup ---

let tweakerDir = FileManager.default.homeDirectoryForCurrentUser
    .appendingPathComponent(".tweaker")
let cmdFilePath = tweakerDir.appendingPathComponent("keystroke_cmd").path
let pidFilePath = tweakerDir.appendingPathComponent("keystroke_server.pid").path
let signalDir = tweakerDir.appendingPathComponent("signals")

// Also poll the FL Studio Novation script directory for command files
let novationDir = FileManager.default.homeDirectoryForCurrentUser
    .appendingPathComponent("Documents/Image-Line/FL Studio/Settings/Hardware/Novation")
let cmdFileNovation = novationDir.appendingPathComponent("keystroke_cmd").path

// Create directories
try? FileManager.default.createDirectory(at: signalDir, withIntermediateDirectories: true)

// Write PID file
try? "\(ProcessInfo.processInfo.processIdentifier)".write(toFile: pidFilePath, atomically: true, encoding: .utf8)

// Ensure trigger_ready and link_source exist for rename/link signals
let triggerReady = tweakerDir.appendingPathComponent("trigger_ready").path
let linkSource = tweakerDir.appendingPathComponent("link_source").path
if !FileManager.default.fileExists(atPath: triggerReady) {
    FileManager.default.createFile(atPath: triggerReady, contents: nil)
}
if !FileManager.default.fileExists(atPath: linkSource) {
    FileManager.default.createFile(atPath: linkSource, contents: nil)
}

// Track mtime for touch_* files
var touchMtimes: [String: Date] = [:]
func initTouchFiles() {
    if let items = try? FileManager.default.contentsOfDirectory(atPath: tweakerDir.path) {
        for item in items where item.hasPrefix("touch_") {
            let path = tweakerDir.appendingPathComponent(item).path
            if let attrs = try? FileManager.default.attributesOfItem(atPath: path),
               let mtime = attrs[.modificationDate] as? Date {
                touchMtimes[path] = mtime
            }
        }
    }
}
initTouchFiles()

// Check accessibility
if AXIsProcessTrusted() {
    fputs("Accessibility: TRUSTED (using CGEvents)\n", stderr)
} else {
    fputs("Accessibility: NOT TRUSTED (will use AppleScript fallback)\n", stderr)
    fputs("For best results, add this binary to System Settings → Privacy & Security → Accessibility\n", stderr)
}

fputs("Keystroke server polling (file, signals dir, rename, link, symlink, utime)\n", stderr)

// Signal handling
signal(SIGINT) { _ in
    try? FileManager.default.removeItem(atPath: pidFilePath)
    exit(0)
}
signal(SIGTERM) { _ in
    try? FileManager.default.removeItem(atPath: pidFilePath)
    exit(0)
}

/// Decode a command from a filename — underscores become spaces
func decodeSignalName(_ name: String) -> String {
    return name.replacingOccurrences(of: "_", with: " ")
}

// SIGUSR1 handler — just a wake-up signal, processing happens in poll loop
signal(SIGUSR1) { _ in
    fputs("Received SIGUSR1\n", stderr)
}

// Helper to process a command file
func processCommandFile(_ path: String, label: String) {
    guard FileManager.default.fileExists(atPath: path) else { return }
    if let contents = try? String(contentsOfFile: path, encoding: .utf8) {
        try? FileManager.default.removeItem(atPath: path)
        for line in contents.split(separator: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty {
                fputs("Command(\(label)): \(trimmed)\n", stderr)
                sendKeystroke(trimmed)
            }
        }
    }
}

// Poll loop — check all signal mechanisms every 50ms
while true {
    // 1. Command files
    processCommandFile(cmdFilePath, label: "home")
    processCommandFile(cmdFileNovation, label: "novation")

    // 2. Signal directories (os.mkdir) — dir name is the command
    if let items = try? FileManager.default.contentsOfDirectory(atPath: signalDir.path) {
        for item in items {
            let cmd = decodeSignalName(item)
            fputs("Signal(mkdir): \(cmd)\n", stderr)
            sendKeystroke(cmd)
            try? FileManager.default.removeItem(atPath: signalDir.appendingPathComponent(item).path)
        }
    }

    // 3-6. Check ~/.tweaker/ for renamed, linked, symlinked, and touched files
    if let items = try? FileManager.default.contentsOfDirectory(atPath: tweakerDir.path) {
        for item in items where item.hasPrefix("trigger_") && item != "trigger_ready" {
            let cmd = decodeSignalName(String(item.dropFirst("trigger_".count)))
            fputs("Signal(rename): \(cmd)\n", stderr)
            sendKeystroke(cmd)
            try? FileManager.default.removeItem(atPath: tweakerDir.appendingPathComponent(item).path)
            FileManager.default.createFile(atPath: triggerReady, contents: nil)
        }

        for item in items where item.hasPrefix("link_") && item != "link_source" {
            let cmd = decodeSignalName(String(item.dropFirst("link_".count)))
            fputs("Signal(link): \(cmd)\n", stderr)
            sendKeystroke(cmd)
            try? FileManager.default.removeItem(atPath: tweakerDir.appendingPathComponent(item).path)
        }

        for item in items where item.hasPrefix("sym_") {
            let cmd = decodeSignalName(String(item.dropFirst("sym_".count)))
            fputs("Signal(symlink): \(cmd)\n", stderr)
            sendKeystroke(cmd)
            try? FileManager.default.removeItem(atPath: tweakerDir.appendingPathComponent(item).path)
        }

        for item in items where item.hasPrefix("touch_") {
            let path = tweakerDir.appendingPathComponent(item).path
            if let attrs = try? FileManager.default.attributesOfItem(atPath: path),
               let mtime = attrs[.modificationDate] as? Date {
                if let prev = touchMtimes[path], mtime > prev {
                    let cmd = String(item.dropFirst("touch_".count))
                    fputs("Signal(utime): \(cmd)\n", stderr)
                    sendKeystroke(cmd)
                }
                touchMtimes[path] = mtime
            }
        }
    }

    usleep(50_000) // 50ms
}

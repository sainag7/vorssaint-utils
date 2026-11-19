// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Foundation

/// The island tile that runs one shortcut from Apple's Shortcuts app, such
/// as one that starts a FaceTime call. The tile takes the shortcut's name,
/// and its icon is chosen in Settings or guessed from that name.
enum NotchShortcutTile {
    /// Where macOS keeps the command that lists and runs shortcuts.
    static let tool = "/usr/bin/shortcuts"

    /// Icons offered in Settings, roughly in the order people reach for them.
    static let symbolChoices = [
        "video", "phone", "message", "envelope", "house", "lightbulb", "flashlight.on.fill",
        "moon", "music.note", "waveform", "alarm", "battery.100", "display", "photo",
        "qrcode", "figure.run", "car", "heart", "star", "bolt",
    ]

    static let fallbackSymbol = "bolt"

    static func name(in defaults: UserDefaults = .standard) -> String {
        (defaults.string(forKey: DefaultsKey.notchRunShortcutName) ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// The icon chosen in Settings, or one guessed from the name when the
    /// choice is Automatic or no longer offered.
    static func symbol(in defaults: UserDefaults = .standard) -> String {
        symbol(chosen: defaults.string(forKey: DefaultsKey.notchRunShortcutSymbol) ?? "", name: name(in: defaults))
    }

    static func symbol(chosen: String, name: String) -> String {
        symbolChoices.contains(chosen) ? chosen : guessedSymbol(for: name)
    }

    /// A first word wins over a later one: "Flashlight" is a flashlight
    /// before it is a light, and a FaceTime call is video before it is a call.
    static func guessedSymbol(for name: String) -> String {
        let name = name.lowercased()
        let rules: [(words: [String], symbol: String)] = [
            (["facetime", "video"], "video"),
            (["call", "phone", "dial"], "phone"),
            (["message", "text ", "imessage", "sms"], "message"),
            (["mail"], "envelope"),
            (["flashlight", "torch"], "flashlight.on.fill"),
            (["light", "lamp", "turn on", "turn off", "room"], "lightbulb"),
            (["home", "house"], "house"),
            (["sleep", "night", "focus", "dark"], "moon"),
            (["music", "song", "playlist", "spotify"], "music.note"),
            (["noise", "sound", "audio"], "waveform"),
            (["alarm", "timer", "remind"], "alarm"),
            (["battery", "power"], "battery.100"),
            (["photo", "gif", "image", "picture", "screenshot"], "photo"),
            (["display", "screen", "always on"], "display"),
            (["qr"], "qrcode"),
            (["gym", "workout", "run", "walk"], "figure.run"),
            (["drive", "car", "commute"], "car"),
        ]
        return rules.first { $0.words.contains(where: name.contains) }?.symbol ?? fallbackSymbol
    }

    /// `shortcuts list` prints one name per line; blank lines and repeats
    /// are dropped and the order is kept.
    static func names(fromList output: String) -> [String] {
        var seen = Set<String>()
        return output.split(whereSeparator: \.isNewline)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty && seen.insert($0).inserted }
    }

    /// The names a picker offers: the library, plus the saved choice when it
    /// was renamed or deleted so the picker still shows what the tile runs.
    static func choices(library: [String], current: String) -> [String] {
        current.isEmpty || library.contains(current) ? library : [current] + library
    }
}

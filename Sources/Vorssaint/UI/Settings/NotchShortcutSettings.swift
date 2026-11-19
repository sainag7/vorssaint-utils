// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import AppKit
import SwiftUI

/// Chooses what the island's Run Shortcut tile runs and how it looks. The
/// list is read again whenever Settings comes forward, so a shortcut just
/// made in the Shortcuts app is there on return.
struct NotchShortcutSettingsRows: View {
    @ObservedObject private var runner = NotchShortcutRunner.shared
    @ObservedObject private var l10n = L10n.shared
    @AppStorage(DefaultsKey.notchRunShortcutName) private var name = ""
    @AppStorage(DefaultsKey.notchRunShortcutSymbol) private var chosenSymbol = ""

    var body: some View {
        let text = NotchShortcutStrings.localized(l10n.language)
        let choices = NotchShortcutTile.choices(library: runner.library ?? [], current: name)
        VStack(alignment: .leading, spacing: 8) {
            SettingsRow(symbol: NotchShortcutTile.symbol(chosen: chosenSymbol, name: name),
                        title: text.pick, caption: text.caption) {
                HStack(spacing: 6) {
                    Picker(text.pick, selection: $name) {
                        Text(text.none).tag("")
                        if !choices.isEmpty { Divider() }
                        ForEach(choices, id: \.self) { Text($0).tag($0) }
                    }
                    .labelsHidden()
                    .frame(maxWidth: 200)
                    Button {
                        NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Applications/Shortcuts.app"))
                    } label: {
                        Image(systemName: "arrow.up.forward.app")
                    }
                    .buttonStyle(.borderless)
                    .help(text.openApp)
                    .accessibilityLabel(text.openApp)
                }
            }
            SettingsRow(symbol: "paintbrush", title: text.icon) {
                Picker(text.icon, selection: $chosenSymbol) {
                    Label(text.automatic, systemImage: NotchShortcutTile.guessedSymbol(for: name)).tag("")
                    Divider()
                    ForEach(NotchShortcutTile.symbolChoices, id: \.self) { symbol in
                        Image(systemName: symbol).accessibilityLabel(symbol).tag(symbol)
                    }
                }
                .labelsHidden()
                .fixedSize()
            }
        }
        .onAppear { runner.refresh() }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            runner.refresh()
        }
    }
}

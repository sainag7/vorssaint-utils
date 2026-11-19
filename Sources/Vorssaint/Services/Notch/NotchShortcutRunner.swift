// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import AppKit

/// Lists and runs the user's shortcuts with macOS's `shortcuts` command,
/// which runs them in the background instead of bringing the Shortcuts app
/// forward the way a shortcuts:// link does.
final class NotchShortcutRunner: ObservableObject {
    static let shared = NotchShortcutRunner()

    /// Every shortcut in the library, once it has been read.
    @Published private(set) var library: [String]?
    /// The shortcut still running, so a second tap cannot start it twice
    /// (twice is a second FaceTime call).
    @Published private(set) var running: String?

    private let queue = DispatchQueue(label: "com.vorssaint.notch-shortcuts", qos: .userInitiated)

    func refresh() {
        queue.async { [weak self] in
            let result = BoundedProcessRunner.run(NotchShortcutTile.tool, ["list"], timeout: 15,
                                                  maxOutputBytes: 512 * 1024)
            guard result.status == 0, !result.timedOut else { return }
            let names = NotchShortcutTile.names(fromList: String(decoding: result.output, as: UTF8.self))
            DispatchQueue.main.async { self?.library = names }
        }
    }

    func run(_ name: String) {
        dispatchPrecondition(condition: .onQueue(.main))
        guard !name.isEmpty, running == nil else { return }
        running = name
        let process = Process()
        process.executableURL = URL(fileURLWithPath: NotchShortcutTile.tool)
        process.arguments = ["run", name]
        process.standardInput = FileHandle.nullDevice
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        // Watched through the handler, so a long shortcut holds no thread.
        process.terminationHandler = { [weak self] finished in
            let failed = finished.terminationReason != .exit || finished.terminationStatus != 0
            DispatchQueue.main.async {
                self?.running = nil
                if failed { NSSound.beep() }
            }
        }
        do {
            try process.run()
        } catch {
            running = nil
            NSSound.beep()
        }
    }
}

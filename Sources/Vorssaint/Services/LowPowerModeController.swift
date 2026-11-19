// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Foundation

/// Reads and switches macOS Low Power Mode for the Power page. Switching
/// needs root, so it goes through a sudoers rule limited to
/// `pmset -a lowpowermode 1/0`; the first switch installs that rule behind
/// the system password prompt and every later one runs without it.
final class LowPowerModeController: ObservableObject {
    static let shared = LowPowerModeController()

    @Published private(set) var isOn = ProcessInfo.processInfo.isLowPowerModeEnabled
    /// A switch still in flight, so a second tap cannot stack a password prompt.
    @Published private(set) var isSwitching = false
    private var observer: NSObjectProtocol?

    private init() {
        // Also catches changes made in System Settings or Control Center.
        observer = NotificationCenter.default.addObserver(forName: .NSProcessInfoPowerStateDidChange,
                                                          object: nil, queue: .main) { [weak self] _ in
            self?.syncFromSystem()
        }
    }

    func set(_ on: Bool) {
        dispatchPrecondition(condition: .onQueue(.main))
        guard !isSwitching, on != ProcessInfo.processInfo.isLowPowerModeEnabled else { syncFromSystem(); return }
        isSwitching = true
        isOn = on
        let value = on ? "1" : "0"
        DispatchQueue.global(qos: .userInitiated).async {
            if Shell.run("/usr/bin/sudo", ["-n", "/usr/bin/pmset", "-a", "lowpowermode", value]).status == 0 {
                DispatchQueue.main.async { self.finish() }
                return
            }
            let path = Sudoers.lowPowerRulePath
            let rule = SudoersSupport.lowPowerRule(uid: getuid())
            // Writes and checks the rule (a failed check removes it), then
            // switches the mode in the same prompt.
            let command = "mkdir -p /etc/sudoers.d && chmod 0755 /etc/sudoers.d && echo '\(rule)' > \(path) && chmod 0440 \(path) && /usr/sbin/visudo -c -f \(path) || rm -f \(path); /usr/bin/pmset -a lowpowermode \(value)"
            let prompt = LowPowerModeStrings.localized(L10n.shared.language).prompt
            AdminShell.run(command, prompt: prompt) { _ in
                DispatchQueue.main.async { self.finish() }
            }
        }
    }

    private func finish() {
        isSwitching = false
        // powerd posts the change a moment after pmset returns.
        syncFromSystem()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in self?.syncFromSystem() }
    }

    private func syncFromSystem() {
        guard !isSwitching else { return }
        isOn = ProcessInfo.processInfo.isLowPowerModeEnabled
    }
}

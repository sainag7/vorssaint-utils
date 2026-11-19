// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import AppKit
import IOKit

/// Keeps the hourly battery-use ledger current whether or not any panel is
/// open: one battery reading a minute (a single registry read), plus one on
/// wake, saved in Application Support so the last day survives a relaunch.
final class BatteryUsageRecorder: ObservableObject {
    static let shared = BatteryUsageRecorder()

    @Published private(set) var ledger = BatteryUsageLedger()

    private var timer: Timer?
    private var wakeObserver: NSObjectProtocol?

    private init() {}

    func start() {
        guard PowerSampler.hasInternalBattery, timer == nil else { return }
        ledger = Self.load()
        sample()
        let timer = Timer(timeInterval: 60, repeats: true) { [weak self] _ in self?.sample() }
        timer.tolerance = 15
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
        wakeObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didWakeNotification, object: nil, queue: .main) { [weak self] _ in
            self?.sample()
        }
    }

    private func sample() {
        guard let percent = Self.chargePercent() else { return }
        var next = ledger
        if next.record(percent: percent, at: Date()) {
            ledger = next
            Self.save(next)
        }
    }

    /// Charge to a fraction of a percent from the raw capacities, falling
    /// back to the whole-percent figure macOS shows.
    private static func chargePercent() -> Double? {
        let service = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("AppleSmartBattery"))
        guard service != 0 else { return nil }
        defer { IOObjectRelease(service) }
        func int(_ key: String) -> Int? {
            IORegistryEntryCreateCFProperty(service, key as CFString, kCFAllocatorDefault, 0)?
                .takeRetainedValue() as? Int
        }
        if let current = int("AppleRawCurrentCapacity"), let maximum = int("AppleRawMaxCapacity"), maximum > 0 {
            return min(100, max(0, Double(current) / Double(maximum) * 100))
        }
        if let current = int("CurrentCapacity"), let maximum = int("MaxCapacity"), maximum > 0 {
            return min(100, max(0, Double(current) / Double(maximum) * 100))
        }
        return nil
    }

    // MARK: Storage

    private static var url: URL? {
        PrivateFileStore.containerURL?
            .appendingPathComponent("BatteryUsage", isDirectory: true)
            .appendingPathComponent("hourly.json", isDirectory: false)
    }

    private static func load() -> BatteryUsageLedger {
        guard let url, let data = try? Data(contentsOf: url),
              let ledger = try? JSONDecoder().decode(BatteryUsageLedger.self, from: data) else {
            return BatteryUsageLedger()
        }
        return ledger
    }

    private static func save(_ ledger: BatteryUsageLedger) {
        guard let url, let data = try? JSONEncoder().encode(ledger),
              PrivateFileStore.createDirectory(at: url.deletingLastPathComponent()) else { return }
        PrivateFileStore.write(data, to: url)
    }
}

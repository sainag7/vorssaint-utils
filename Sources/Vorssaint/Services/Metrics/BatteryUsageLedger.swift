// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Foundation

/// How much of the battery was used in each clock hour: the sum of every drop
/// in charge seen during that hour. Rises (charging) are not use, so an hour
/// spent plugged in and charging stays at zero, while a heavy load that drains
/// the battery even on the adapter still shows. Charge is tracked to a
/// fraction of a percent, so slow drains are not lost to rounding.
///
/// A drop seen across a gap (the Mac asleep, the app not running) is put in
/// the hour it was noticed, since when within the gap it happened is unknown.
struct BatteryUsageLedger: Codable, Equatable {
    /// Hours kept: one full day on screen plus a day of slack.
    static let retainedHours = 48

    /// Percent used, keyed by the hour's start in seconds since 1970.
    private(set) var hours: [Int: Double] = [:]
    private(set) var lastPercent: Double?

    /// Records a charge reading, 0...100. Returns whether anything changed
    /// that is worth saving.
    @discardableResult
    mutating func record(percent: Double, at date: Date, calendar: Calendar = .current) -> Bool {
        guard percent.isFinite, (0...100).contains(percent) else { return false }
        defer { lastPercent = percent }
        guard let last = lastPercent, percent < last else { return lastPercent == nil }
        let hour = Self.hourStart(of: date, calendar: calendar)
        hours[hour, default: 0] += last - percent
        prune(before: date, calendar: calendar)
        return true
    }

    /// The last `count` clock hours, oldest first, ending with the current one.
    func usage(endingAt date: Date, count: Int = 24, calendar: Calendar = .current)
        -> [(start: Date, percent: Double)] {
        let current = Self.hourStart(of: date, calendar: calendar)
        return (0..<max(0, count)).reversed().compactMap { back in
            guard let start = calendar.date(byAdding: .hour, value: -back,
                                            to: Date(timeIntervalSince1970: TimeInterval(current))) else { return nil }
            return (start, hours[Int(start.timeIntervalSince1970)] ?? 0)
        }
    }

    static func hourStart(of date: Date, calendar: Calendar = .current) -> Int {
        let start = calendar.dateInterval(of: .hour, for: date)?.start ?? date
        return Int(start.timeIntervalSince1970)
    }

    private mutating func prune(before date: Date, calendar: Calendar) {
        guard let cutoff = calendar.date(byAdding: .hour, value: -Self.retainedHours, to: date) else { return }
        let floor = Int(cutoff.timeIntervalSince1970)
        hours = hours.filter { $0.key >= floor }
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Foundation

/// Lifetime agent usage: one total per calendar day, kept after the agents
/// delete their logs and after a day leaves the thirteen-week activity map.
/// Each refresh merges the days still on disk, and a day only ever keeps its
/// largest total, so deleted logs never lower it. It holds counts and cost
/// per day, nothing about prompts, models or folders.
///
/// Stored in Application Support rather than the cache folder the archive
/// uses: the logs cannot rebuild days they no longer have.
struct AgentLifetimeLedger: Codable, Equatable {
    struct Day: Codable, Equatable {
        var tokens: Int
        var cost: Double
        var requests: Int
        var unpriced: Int
    }

    /// Keyed by local calendar day, `yyyy-MM-dd`.
    private(set) var days: [String: Day] = [:]

    var tokens: Int { days.values.reduce(0) { $0 + $1.tokens } }
    var cost: Double { days.values.reduce(0) { $0 + $1.cost } }
    /// Cost covers every response only when no day had an unpriced one.
    var fullyPriced: Bool { days.values.allSatisfy { $0.unpriced == 0 } }
    var firstDay: String? { days.keys.min() }

    static func key(for date: Date, calendar: Calendar = .current) -> String {
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", parts.year ?? 0, parts.month ?? 0, parts.day ?? 0)
    }

    /// Adds days with any use; a day already known keeps whichever total is
    /// larger. Returns whether anything changed.
    @discardableResult
    mutating func merge(_ buckets: [AgentBucket], calendar: Calendar = .current) -> Bool {
        var changed = false
        for bucket in buckets {
            let total = bucket.total
            guard total.requests > 0 || total.tokens.total > 0 else { continue }
            let day = Day(tokens: max(0, total.tokens.total), cost: max(0, total.cost),
                          requests: max(0, total.requests), unpriced: max(0, total.unpriced))
            let key = Self.key(for: bucket.start, calendar: calendar)
            if let known = days[key], known.tokens >= day.tokens, known.requests >= day.requests { continue }
            days[key] = day
            changed = true
        }
        return changed
    }

    // MARK: Storage

    private static var url: URL? {
        PrivateFileStore.containerURL?
            .appendingPathComponent("AgentUsage", isDirectory: true)
            .appendingPathComponent("lifetime.json", isDirectory: false)
    }

    static func load() -> AgentLifetimeLedger {
        guard let url, let data = try? Data(contentsOf: url),
              let ledger = try? JSONDecoder().decode(AgentLifetimeLedger.self, from: data) else {
            return AgentLifetimeLedger()
        }
        return ledger
    }

    @discardableResult
    func save() -> Bool {
        guard let url = Self.url, let data = try? JSONEncoder().encode(self),
              PrivateFileStore.createDirectory(at: url.deletingLastPathComponent()) else { return false }
        return PrivateFileStore.write(data, to: url)
    }
}

/// The lifetime figures the island shows.
struct AgentLifetimeUsage: Equatable {
    var tokens = 0
    var cost = 0.0
    var fullyPriced = true
    /// The first day on record.
    var since: Date?

    init() {}

    init(_ ledger: AgentLifetimeLedger, calendar: Calendar = .current) {
        tokens = ledger.tokens
        cost = ledger.cost
        fullyPriced = ledger.fullyPriced
        since = ledger.firstDay.flatMap { key in
            let parts = key.split(separator: "-").compactMap { Int($0) }
            guard parts.count == 3 else { return nil }
            return calendar.date(from: DateComponents(year: parts[0], month: parts[1], day: parts[2]))
        }
    }
}

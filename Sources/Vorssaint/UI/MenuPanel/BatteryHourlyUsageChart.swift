// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import SwiftUI

/// The last 24 clock hours as bars of how much battery each one used, so the
/// battery details show when the Mac actually drained it. Hovering a bar
/// names its hour and amount; otherwise the label shows the day's total.
struct BatteryHourlyUsageChart: View {
    @ObservedObject private var recorder = BatteryUsageRecorder.shared
    @ObservedObject private var l10n = L10n.shared
    @Environment(\.locale) private var locale
    @State private var hovered: Int?

    var body: some View {
        let strings = BatteryDisplayStrings.localized(l10n.language)
        let hours = recorder.ledger.usage(endingAt: Date())
        let total = hours.reduce(0) { $0 + $1.percent }
        // At least 5% tall so a quiet day does not blow small drops up to full bars.
        let ceiling = max(5, hours.map(\.percent).max() ?? 0)
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(strings.usedPerHour)
                    .font(.system(size: 9.5, weight: .medium))
                    .foregroundStyle(.secondary)
                Spacer()
                Text(caption(hours: hours, total: total, empty: strings.noUseYet))
                    .font(.system(size: 9.5, weight: .medium).monospacedDigit())
                    .foregroundStyle(hovered == nil ? .secondary : .primary)
            }
            HStack(alignment: .bottom, spacing: 2) {
                ForEach(Array(hours.enumerated()), id: \.offset) { index, hour in
                    let fraction = hour.percent / ceiling
                    RoundedRectangle(cornerRadius: 1.5, style: .continuous)
                        .fill(barColor(index: index, percent: hour.percent))
                        .frame(maxWidth: .infinity)
                        .frame(height: max(hour.percent > 0 ? 2 : 1, 34 * fraction))
                        .frame(height: 34, alignment: .bottom)
                        .contentShape(Rectangle())
                        .onHover { inside in
                            if inside { hovered = index } else if hovered == index { hovered = nil }
                        }
                }
            }
            .frame(height: 34)
            HStack {
                Text(hourLabel(hours.first?.start))
                Spacer()
                Text(hourLabel(hours.dropFirst(12).first?.start))
                Spacer()
                Text(hourLabel(hours.last?.start))
            }
            .font(.system(size: 8.5).monospacedDigit())
            .foregroundStyle(.tertiary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(strings.usedPerHour)
        .accessibilityValue(MetricFormat.percent(total / 100))
    }

    private func caption(hours: [(start: Date, percent: Double)], total: Double, empty: String) -> String {
        if let hovered, hours.indices.contains(hovered) {
            let hour = hours[hovered]
            return "\(hourLabel(hour.start)) · \(percentText(hour.percent))"
        }
        return total > 0 ? "24h · \(percentText(total))" : empty
    }

    private func percentText(_ value: Double) -> String {
        value >= 10 || value == 0
            ? String(format: "%.0f%%", locale: MetricFormat.locale, value)
            : String(format: "%.1f%%", locale: MetricFormat.locale, value)
    }

    private func hourLabel(_ date: Date?) -> String {
        guard let date else { return "" }
        return date.formatted(.dateTime.hour().locale(locale))
    }

    private func barColor(index: Int, percent: Double) -> Color {
        if percent <= 0 { return Color.secondary.opacity(0.18) }
        return hovered == index ? Color.accentColor : Color.green.opacity(0.85)
    }
}

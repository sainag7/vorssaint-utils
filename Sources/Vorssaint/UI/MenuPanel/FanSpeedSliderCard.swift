// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import SwiftUI

/// Quick manual fan control for the Fan speed detail: drag the slider and the
/// level applies on release. Uses the same protected helper, safety limits and
/// stored preferences as the full Fan Control section.
struct FanSpeedSliderCard: View {
    @ObservedObject private var l10n = L10n.shared
    @ObservedObject private var service = FanControlService.shared
    @AppStorage(DefaultsKey.fanControlMode) private var modeRaw = FanControlMode.system.rawValue
    @AppStorage(DefaultsKey.fanControlCoolingLevel) private var coolingLevel =
        FanControlPolicy.defaultCoolingLevel

    /// While dragging: the requested speed as a share of the maximum.
    @State private var draftPercent: Double?
    @ObservedObject private var monitor = SystemMonitor.shared

    private var strings: FanControlFeatureStrings { FeatureStrings.fanControl(l10n.language) }
    private var snapshot: FanControlSnapshot { service.snapshot }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            header
            if let message = stateMessage {
                Text(message)
                    .font(.system(size: 10))
                    .foregroundStyle(messageIsError ? Color.red : Color.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if needsApproval {
                Button(service.accessState == .requiresApproval ? strings.openSettings : strings.allowControl,
                       action: service.authorize)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                    .frame(maxWidth: .infinity)
            } else if canControl {
                Slider(value: sliderBinding, in: sliderRange, step: 1) { editing in
                    if !editing { applyDraft() }
                }
                .controlSize(.small)
                .disabled(service.isWorking)

                if snapshot.isCooling {
                    Button(strings.returnToSystem) {
                        draftPercent = nil
                        modeRaw = FanControlMode.system.rawValue
                        service.returnToSystem()
                    }
                    .controlSize(.small)
                    .disabled(service.isWorking)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .panelCard()
        .onAppear { service.panelDidAppear() }
        .onDisappear { service.panelDidDisappear() }
    }

    private var header: some View {
        HStack(spacing: 6) {
            Text(strings.coolingIntensity)
                .font(.system(size: 11, weight: .semibold))
            Spacer()
            if service.isWorking { ProgressView().controlSize(.mini) }
            Text(levelText)
                .font(.system(size: 11, weight: .semibold).monospacedDigit())
                .foregroundStyle(snapshot.isCooling || draftPercent != nil ? Color.cyan : Color.secondary)
        }
    }

    private var levelText: String {
        if let draftPercent { return "\(Int(draftPercent.rounded()))%" }
        guard snapshot.isCooling else { return strings.systemControl }
        if snapshot.configuration?.mode == .curve { return strings.customCurve }
        return activePercent.map { "\($0)%" } ?? strings.manualControl
    }

    /// The controlled fan whose speed the slider stands for: the busiest one,
    /// as in the readout above. Its bounds turn a share of the maximum into a
    /// cooling level and back.
    private var bounds: (minimum: Double, maximum: Double)? {
        let fans = snapshot.fans.filter {
            FanControlPolicy.validBounds(minimum: $0.minimumRPM, maximum: $0.maximumRPM)
        }
        let busiest = fans.max { lhs, rhs in
            (FanControlPolicy.percent(actual: lhs.actualRPM, maximum: lhs.maximumRPM) ?? 0)
                < (FanControlPolicy.percent(actual: rhs.actualRPM, maximum: rhs.maximumRPM) ?? 0)
        }
        return busiest.map { ($0.minimumRPM, $0.maximumRPM) }
    }

    /// From the fan's own minimum speed, which is as low as control can go,
    /// to its maximum.
    private var sliderRange: ClosedRange<Double> {
        guard let bounds, let low = FanControlPolicy.minimumPercent(minimum: bounds.minimum,
                                                                     maximum: bounds.maximum) else { return 0...100 }
        return Double(min(low, 99))...100
    }

    /// The live speed of the busiest fan as a share of its maximum, the same
    /// number the readout above shows.
    private var livePercent: Int? {
        if let percents = FanControlPolicy.percents(for: monitor.snapshot.fanSpeeds,
                                                    maximums: monitor.snapshot.fanMaximums) {
            return percents.max()
        }
        return snapshot.fans.compactMap {
            FanControlPolicy.percent(actual: $0.actualRPM, maximum: $0.maximumRPM)
        }.max()
    }

    /// The speed manual control is holding, as a share of the maximum.
    private var activePercent: Int? {
        guard let bounds, let level = snapshot.coolingLevel else { return nil }
        return FanControlPolicy.percentOfMaximum(level: level, minimum: bounds.minimum, maximum: bounds.maximum)
    }

    private var sliderBinding: Binding<Double> {
        Binding(
            get: {
                let value: Double
                if let draftPercent {
                    value = draftPercent
                } else if snapshot.isCooling, snapshot.configuration?.mode != .curve, let activePercent {
                    value = Double(activePercent)
                } else {
                    // Under system control (or a curve) the slider follows the
                    // fans, so it never shows a level nothing is running at.
                    value = Double(livePercent ?? 0)
                }
                return min(max(value, sliderRange.lowerBound), sliderRange.upperBound)
            },
            set: { draftPercent = $0 }
        )
    }

    private func applyDraft() {
        guard let draftPercent else { return }
        defer { self.draftPercent = nil }
        let level: Int
        if let bounds, let converted = FanControlPolicy.coolingLevel(forPercent: draftPercent,
                                                                      minimum: bounds.minimum,
                                                                      maximum: bounds.maximum) {
            level = converted
        } else {
            // No usable bounds: fall back to treating the slider as the level.
            let step = FanControlPolicy.coolingLevelStep
            level = min(max(Int((draftPercent / Double(step)).rounded()) * step,
                            FanControlPolicy.minimumCoolingLevel), FanControlPolicy.maximumCoolingLevel)
        }
        coolingLevel = level
        modeRaw = FanControlMode.manual.rawValue
        service.applyConfiguration(.manual(level: level))
    }

    // Mirrors FanControlCardContent so both surfaces agree on when control is offered.
    private var controlsCanAppear: Bool {
        !snapshot.fans.isEmpty
            && (service.error == nil || service.error == .controlFailed || snapshot.isCooling)
    }

    private var canControl: Bool {
        controlsCanAppear && service.accessState == .enabled
    }

    private var needsApproval: Bool {
        guard !snapshot.fans.isEmpty else { return false }
        switch service.error {
        case .noFans, .unsupportedHardware, .alreadyControlled: return false
        default: break
        }
        return service.accessState == .notRegistered || service.accessState == .requiresApproval
    }

    private var stateMessage: String? {
        if service.error == .noFans { return strings.noFans }
        if service.accessState == .unavailable { return strings.unsupported }
        switch service.error {
        case .alreadyControlled: return strings.alreadyControlled
        case .unsupportedHardware: return strings.unsupported
        case .helperUnavailable: return strings.helperUnavailable
        case .controlFailed: return strings.failed
        case .authorizationRequired: return strings.approvalCaption
        case .noFans, .none: break
        }
        if needsApproval { return strings.approvalCaption }
        switch snapshot.stopReason {
        case .temperatureUnavailable: return strings.temperatureUnavailable
        case .timeLimit, .appDisconnected, .heartbeatLost, .hardwareChanged,
             .thermalPressure, .recovery:
            return strings.safetyStopped
        case .none:
            return nil
        }
    }

    private var messageIsError: Bool {
        switch service.error {
        case .alreadyControlled, .unsupportedHardware, .helperUnavailable, .controlFailed: return true
        default: return false
        }
    }
}

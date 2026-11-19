// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import AppKit
import SwiftUI

/// The mixer as a list: the output and microphone on top, then one row per
/// app, pinned ones first, each with a level that slides left to right. Every
/// row action of the panel's list is here: the app's menu pins, moves and
/// routes it, Command-drag reorders, a click on a level types a new one. The
/// island's top row holds the output and opens the options: where sound
/// effects and the microphone go, the switches the panel keeps under Options,
/// and the hidden rows.
struct NotchMixerView: View {
    let size: CGSize
    @ObservedObject private var mixer = AppVolumeMixer.shared
    @ObservedObject private var input = AudioInputDeviceManager.shared
    @ObservedObject private var l10n = L10n.shared
    @AppStorage(DefaultsKey.mixerAppArrangement) private var arrangementValue = ""
    @AppStorage(DefaultsKey.mixerHideInactiveApps) private var hideInactiveApps = false
    @State private var showingOptions = false
    @State private var editingVolumeID: String?
    @State private var draggingAppID: String?
    @State private var dropTarget: MixerAppDropTarget?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.notchSettingsPreview) private var preview
    /// A microphone that reports no level has nothing to fade, as in the options.
    private var showsMicrophone: Bool { input.inputVolume != nil }

    private var arrangement: MixerAppArrangement { MixerAppArrangement(rawValue: arrangementValue) }

    /// The same order and the same hidden rows as the panel's list.
    private var apps: [MixerApp] {
        arrangement.ordered(mixer.apps, identity: { $0.persistenceID }).filter { app in
            MixerRoutingSupport.shouldShowApp(isPlaying: app.isPlaying, volume: app.volume,
                                              selectedOutputDeviceUID: app.selectedOutputDeviceUID,
                                              hideInactiveApps: hideInactiveApps)
        }
    }

    var body: some View {
        Group {
            if showingOptions {
                NotchMixerOptions(editingVolumeID: $editingVolumeID)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // The output and microphone stay put; only the apps scroll.
                VStack(spacing: NotchMixerRowLayout.spacing) {
                    NotchOutputRow(editingVolumeID: $editingVolumeID)
                    if showsMicrophone {
                        NotchMicrophoneRow(editingVolumeID: $editingVolumeID)
                    }
                    Rectangle().fill(.white.opacity(0.12)).frame(height: 1)
                        .accessibilityHidden(true)
                    desk.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        // The output and the options sit in the island's top row, beside the
        // camera where they fit, so the rows take the whole page.
        .notchBand(leading: { NotchOutputDeviceMenu(inBand: true) }, trailing: {
            NotchIconButton(symbol: showingOptions ? "xmark" : "slider.horizontal.3",
                            title: showingOptions ? l10n.s.menuClose : l10n.s.keepAwakeOptions,
                            selected: showingOptions, action: toggleOptions)
        })
        .onAppear { mixer.refreshApps() }
        // Escape closes the options before the island.
        .onChange(of: showingOptions) { _, showing in
            guard !preview else { return }
            NotchService.shared.setPageLayer(.mixer, close: showing ? closeOptions : nil)
        }
        .onDisappear { if !preview { NotchService.shared.setPageLayer(.mixer, close: nil) } }
    }

    private func toggleOptions() {
        editingVolumeID = nil
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.18)) { showingOptions.toggle() }
    }

    /// What Escape does: it only ever closes the options.
    private func closeOptions() {
        editingVolumeID = nil
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.18)) { showingOptions = false }
    }

    @ViewBuilder private var desk: some View {
        if !AppVolumeMixer.isSupported {
            NotchEmptyView(symbol: NotchModule.mixer.symbol, message: l10n.s.mixerUnavailable)
        } else if mixer.needsPermission {
            permission
        } else if apps.isEmpty {
            NotchEmptyView(symbol: NotchModule.mixer.symbol, message: l10n.s.mixerEmpty)
        } else {
            let apps = apps
            let ids = apps.compactMap(\.persistenceID)
            ScrollView {
                LazyVStack(spacing: NotchMixerRowLayout.spacing) {
                    ForEach(apps) { app in
                        NotchAppRow(app: app, editingVolumeID: $editingVolumeID,
                                    isPinned: arrangement.isPinned(app.persistenceID),
                                    togglePin: { updateArrangement { $0.togglePin(app.persistenceID ?? "") } },
                                    moveUp: moveAction(for: app, offset: -1, ids: ids),
                                    moveDown: moveAction(for: app, offset: 1, ids: ids))
                            .modifier(MixerAppReorderModifier(
                                id: app.persistenceID,
                                icon: ResponsibleProcess.icon(for: app.ownerPid, pointSize: 32),
                                draggingID: $draggingAppID,
                                target: $dropTarget,
                                dragChanged: { NotchService.shared.fileDragChanged($0, internalDrag: true) },
                                canMove: { source, target in
                                    ids.contains(source) && ids.contains(target)
                                        && arrangement.isPinned(source) == arrangement.isPinned(target)
                                },
                                move: { source, target, after in
                                    updateArrangement { $0.move(source, to: target, after: after, visibleIDs: ids) }
                                }))
                            .help(app.name + "\n" + FeatureStrings.mixer(l10n.language).arrange)
                    }
                }
                .padding(.bottom, 2)
            }
            .scrollIndicators(.automatic)
        }
    }

    private func updateArrangement(_ change: (inout MixerAppArrangement) -> Void) {
        var updated = arrangement
        change(&updated)
        arrangementValue = updated.rawValue
    }

    private func moveAction(for app: MixerApp, offset: Int, ids: [String]) -> (() -> Void)? {
        guard let id = app.persistenceID,
              arrangement.neighbor(of: id, offset: offset, visibleIDs: ids) != nil else { return nil }
        return { updateArrangement { $0.move(id, offset: offset, visibleIDs: ids) } }
    }

    private var permission: some View {
        HStack(spacing: 14) {
            Image(systemName: "waveform.badge.exclamationmark").font(.system(size: 24, weight: .light))
                .foregroundStyle(.white.opacity(0.65))
                .frame(width: 56, height: 56)
                .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 8) {
                Text(l10n.s.mixerPermissionBody).font(.system(size: 12)).foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                Button(l10n.s.permissionOpenSettings) { Permissions.shared.openAudioCaptureSettings() }
                    .buttonStyle(.bordered).controlSize(.small)
            }
        }
        .padding(.horizontal, 8)
    }
}

/// A level that reads as text and, clicked, takes a typed one: the same
/// editor as the panel's rows, so the two agree on what a "150" means.
private struct NotchEditablePercent: View {
    let percent: Int
    let maximum: Int
    let editorID: String
    @Binding var editingID: String?
    let label: String
    var tint: Color = .secondary
    var boosting = false
    var width: CGFloat = 40
    var height: CGFloat = 18
    let commit: (Double) -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        EditableVolumePercent(currentPercent: percent, maximumPercent: maximum, width: width, height: height,
                              editorID: editorID, editingID: $editingID, accessibilityLabel: label) {
            HStack(spacing: 1) {
                if boosting {
                    Image(systemName: "bolt.fill").font(.system(size: 7, weight: .bold)).foregroundStyle(tint)
                }
                Text("\(percent)%")
                    .font(.system(size: height > 18 ? 12 : 10, weight: .medium)).monospacedDigit()
                    .foregroundStyle(tint)
                    .contentTransition(.numericText())
                    .animation(reduceMotion ? nil : .smooth(duration: 0.2), value: percent)
            }
            .frame(maxWidth: .infinity, minHeight: height)
        } onCommit: { commit($0) }
        .frame(height: height)
    }
}

/// Every row shares one grid, so the sliders start and end on the same
/// lines whether the row is the output, the microphone or an app.
private enum NotchMixerRowLayout {
    static let height: CGFloat = 30
    static let spacing: CGFloat = 6
    static let gap: CGFloat = 8
    static let leading: CGFloat = 30
    static let name: CGFloat = 84
    static let percent: CGFloat = 44
    static let trailing: CGFloat = 80
    static let track: CGFloat = 20
}

/// A row's name beside its icon, cut short rather than pushing the slider.
private struct NotchMixerRowName: View {
    let text: String
    var pinned = false
    var body: some View {
        HStack(spacing: 3) {
            if pinned {
                Image(systemName: "pin.fill").font(.system(size: 8)).foregroundStyle(.secondary)
            }
            Text(text).font(.system(size: 11.5, weight: .medium)).foregroundStyle(.white.opacity(0.9))
                .lineLimit(1).truncationMode(.tail)
        }
        .frame(width: NotchMixerRowLayout.name, alignment: .leading)
    }
}

/// The system output: its mute, level and typed level, in the same row shape
/// as the apps under it.
private struct NotchOutputRow: View {
    @Binding var editingVolumeID: String?
    @ObservedObject private var mixer = AppVolumeMixer.shared
    @ObservedObject private var l10n = L10n.shared
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private var level: Double? { mixer.systemOutputVolume.map { mixer.systemOutputMuted == true ? 0 : $0 } }
    private var muted: Bool { mixer.systemOutputMuted == true }

    /// The slider already shows the level it sets, so the island's top row
    /// stays in view instead of repeating it.
    private func adjustOutput(volume: Double? = nil, muted: Bool? = nil) {
        NotchService.shared.noteOwnLevelAdjustment(.volume)
        mixer.requestOutputAdjustment(volume: volume, muted: muted)
    }

    var body: some View {
        HStack(spacing: NotchMixerRowLayout.gap) {
            Button {
                if let muted = mixer.systemOutputMuted { adjustOutput(muted: !muted) }
            } label: {
                Image(systemName: muted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(muted ? Color.red : Color.white)
                    .contentTransition(.symbolEffect(.replace))
                    .animation(reduceMotion ? nil : .smooth(duration: 0.24), value: muted)
                    .frame(width: NotchMixerRowLayout.leading, height: NotchMixerRowLayout.height)
                    .contentShape(Rectangle())
            }
            .buttonStyle(NotchButtonStyle(cornerRadius: 9))
            .disabled(mixer.systemOutputMuted == nil)
            .accessibilityLabel(muted ? l10n.s.actionUnmute : l10n.s.actionMute)
            NotchMixerRowName(text: l10n.s.mixerSystemOutputTitle)
            if let level {
                NotchLevelSlider(value: Binding(get: { level }, set: { adjustOutput(volume: $0) }),
                                 label: l10n.s.mixerSystemOutputTitle, trackThickness: NotchMixerRowLayout.track)
                    .frame(height: NotchMixerRowLayout.height)
                NotchEditablePercent(percent: MixerRoutingSupport.displayPercent(forVolume: level), maximum: 100,
                                     editorID: "notch-system-output", editingID: $editingVolumeID,
                                     label: l10n.s.mixerSystemOutputTitle,
                                     width: NotchMixerRowLayout.percent, height: 22) {
                    adjustOutput(volume: $0)
                }
                .frame(width: NotchMixerRowLayout.percent)
            } else {
                Text(l10n.s.mixerOutputUnavailable).font(.system(size: 10)).foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            Color.clear.frame(width: NotchMixerRowLayout.trailing, height: 1)
        }
        .frame(height: NotchMixerRowLayout.height)
    }
}

/// The microphone under the output: the same row, its mute and level.
private struct NotchMicrophoneRow: View {
    @Binding var editingVolumeID: String?
    @ObservedObject private var input = AudioInputDeviceManager.shared
    @ObservedObject private var micMute = MicMuteService.shared
    @ObservedObject private var l10n = L10n.shared
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(spacing: NotchMixerRowLayout.gap) {
            // The mute is its own feature; without it the row keeps the
            // plain icon the options row shows.
            if AppFeature.micMute.isAvailable {
                Button(action: micMute.toggle) {
                    icon(muted: micMute.isMuted).foregroundStyle(micMute.isMuted ? Color.red : Color.white)
                }
                .buttonStyle(NotchButtonStyle(cornerRadius: 9))
                .accessibilityLabel(micMute.isMuted ? l10n.s.micUnmuteName : l10n.s.micMuteName)
            } else {
                icon(muted: (input.inputVolume ?? 0) <= 0.001).foregroundStyle(.secondary)
                    .accessibilityHidden(true)
            }
            NotchMixerRowName(text: l10n.s.mixerInputTitle)
            if let volume = input.inputVolume {
                NotchLevelSlider(value: Binding(get: { volume }, set: { input.setInputVolume($0) }),
                                 label: l10n.s.mixerInputTitle, trackThickness: NotchMixerRowLayout.track)
                    .frame(height: NotchMixerRowLayout.height)
                    .disabled(micMute.isMuted)
                NotchEditablePercent(percent: MixerRoutingSupport.displayPercent(forVolume: volume), maximum: 100,
                                     editorID: "notch-microphone-fader", editingID: $editingVolumeID,
                                     label: l10n.s.mixerInputTitle,
                                     width: NotchMixerRowLayout.percent, height: 22) {
                    input.setInputVolume($0)
                }
                .frame(width: NotchMixerRowLayout.percent)
                .disabled(micMute.isMuted)
            }
            Color.clear.frame(width: NotchMixerRowLayout.trailing, height: 1)
        }
        .frame(height: NotchMixerRowLayout.height)
    }

    private func icon(muted: Bool) -> some View {
        Image(systemName: muted ? "mic.slash.fill" : "mic.fill")
            .font(.system(size: 13, weight: .medium))
            .contentTransition(.symbolEffect(.replace))
            .animation(reduceMotion ? nil : .smooth(duration: 0.24), value: muted)
            .frame(width: NotchMixerRowLayout.leading, height: NotchMixerRowLayout.height)
            .contentShape(Rectangle())
    }
}

private struct NotchOutputDeviceMenu: View {
    var width: CGFloat = 150
    var lines = 1
    /// In the island's top row: one line, as wide as the row leaves it, cut
    /// short beside the camera and whole across a full row.
    var inBand = false
    @ObservedObject private var mixer = AppVolumeMixer.shared
    @ObservedObject private var l10n = L10n.shared
    private var deviceName: String {
        mixer.outputDevices.first(where: { $0.uid == mixer.currentOutputDeviceUID })?.name ?? l10n.s.mixerOutputUnavailable
    }

    private var current: String { mixer.outputSwitchError ?? deviceName }
    private var items: [NotchMenuItem] {
        mixer.outputDevices.filter(\.canBeDefaultOutput).map { device in
            NotchMenuItem(title: device.name, checked: device.uid == mixer.currentOutputDeviceUID) {
                _ = mixer.setUniversalOutputDeviceUID(device.uid)
            }
        }
    }

    var body: some View {
        if inBand {
            NotchMenuButton(title: l10n.s.mixerSystemOutputTitle, items: items, cornerRadius: 9) {
                NotchBandMenuLabel(title: current)
            }
            .help(current)
            .accessibilityValue(current)
        } else {
            NotchDeviceMenu(title: l10n.s.mixerSystemOutputTitle, current: current,
                            width: width, lines: lines, alignment: lines > 1 ? .center : .trailing,
                            items: items)
        }
    }
}

/// Everything the desk leaves out, in one list that scrolls down: where the
/// output, sound effects and the microphone go, the microphone's level, and
/// the panel's options under them.
private struct NotchMixerOptions: View {
    @Binding var editingVolumeID: String?
    @ObservedObject private var mixer = AppVolumeMixer.shared
    @ObservedObject private var input = AudioInputDeviceManager.shared
    @ObservedObject private var audioPriority = AudioPriorityService.shared
    @ObservedObject private var micMute = MicMuteService.shared
    @ObservedObject private var l10n = L10n.shared
    private var outputDevices: [MixerOutputDevice] { mixer.outputDevices.filter(\.canBeDefaultOutput) }
    private var soundEffectsDevices: [MixerOutputDevice] { mixer.outputDevices.filter(\.canBeDefaultSystemOutput) }
    private var soundEffectsName: String {
        mixer.outputDevices.first(where: { $0.uid == mixer.currentSystemSoundOutputDeviceUID })?.name ?? l10n.s.mixerOutputUnavailable
    }
    private var microphoneName: String {
        guard let uid = selectedMicrophoneUID else { return l10n.s.mixerOutputDefault }
        return input.inputDevices.first(where: { $0.uid == uid })?.name ?? l10n.s.mixerInputUnavailable
    }
    private var selectedMicrophoneUID: String? {
        MixerRoutingSupport.selectedInputDeviceUID(
            preferredUID: input.preferredInputDeviceUID,
            currentUID: input.currentInputDeviceUID,
            priorityIsActive: audioPriority.inputPriorityEnabled)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                VStack(alignment: .leading, spacing: 6) {
                    row(l10n.s.mixerSystemOutputTitle, symbol: "speaker.wave.2") { NotchOutputDeviceMenu(width: 200) }
                    if outputDevices.isEmpty {
                        message(l10n.s.mixerSystemOutputNoDevices, systemImage: "speaker.slash")
                    }
                    if let error = mixer.outputSwitchError {
                        message(String(format: l10n.s.mixerSystemOutputErrorFormat, error),
                                systemImage: "exclamationmark.triangle")
                    }
                    row(l10n.s.mixerSoundEffectsOutputTitle, symbol: "bell") {
                        NotchDeviceMenu(title: l10n.s.mixerSoundEffectsOutputTitle, current: soundEffectsName,
                                        width: 200, lines: 1, alignment: .trailing,
                                        items: soundEffectsDevices.map { device in
                                            NotchMenuItem(title: device.name,
                                                          checked: device.uid == mixer.currentSystemSoundOutputDeviceUID) {
                                                _ = mixer.setSystemSoundOutputDeviceUID(device.uid)
                                            }
                                        })
                    }
                    if soundEffectsDevices.isEmpty {
                        message(l10n.s.mixerSystemOutputNoDevices, systemImage: "bell.slash")
                    }
                    microphone
                }
                Divider().overlay(.white.opacity(0.12))
                MixerOptionsControls()
            }
            .padding(.trailing, 4)
            .padding(.bottom, 4)
        }
        .scrollIndicators(.automatic)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    @ViewBuilder private var microphone: some View {
        row(l10n.s.mixerInputTitle, symbol: micMute.isMuted ? "mic.slash" : "mic") {
            NotchDeviceMenu(title: l10n.s.mixerInputTooltip, current: microphoneName, width: 200, lines: 1, alignment: .trailing,
                            items: [NotchMenuItem(title: l10n.s.mixerOutputDefault, checked: selectedMicrophoneUID == nil) {
                                guard !audioPriority.inputPriorityEnabled else { return }
                                input.setPreferredInputDeviceUID(nil)
                            }] + input.inputDevices.map { device in
                                NotchMenuItem(title: device.name, checked: device.uid == selectedMicrophoneUID) {
                                    if audioPriority.inputPriorityEnabled {
                                        input.setCurrentInputDeviceUID(device.uid)
                                    } else {
                                        input.setPreferredInputDeviceUID(device.uid)
                                    }
                                }
                            } + (!audioPriority.inputPriorityEnabled
                                 && input.preferredUnavailable && input.preferredInputDeviceUID != nil
                                 ? [NotchMenuItem(title: l10n.s.mixerInputUnavailable, checked: true)] : []))
        }
        if let volume = input.inputVolume {
            HStack(spacing: 8) {
                // The mute is its own feature; without it the row keeps the
                // plain icon the panel's row shows.
                if AppFeature.micMute.isAvailable {
                    Button(action: micMute.toggle) {
                        Image(systemName: micMute.isMuted ? "mic.slash.fill" : "mic.fill")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(micMute.isMuted ? Color.red : Color.white)
                            .frame(width: 18, height: 18)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(NotchButtonStyle(cornerRadius: 6))
                    .accessibilityLabel(micMute.isMuted ? l10n.s.micUnmuteName : l10n.s.micMuteName)
                } else {
                    Image(systemName: volume <= 0.001 ? "mic.slash.fill" : "mic.fill")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.secondary)
                        .frame(width: 18, height: 18)
                        .accessibilityHidden(true)
                }
                NotchLevelSlider(value: Binding(get: { volume }, set: { input.setInputVolume($0) }),
                                 label: l10n.s.mixerInputTitle)
                    .frame(height: 22)
                    .disabled(micMute.isMuted)
                NotchEditablePercent(percent: MixerRoutingSupport.displayPercent(forVolume: volume), maximum: 100,
                                     editorID: "notch-microphone-input", editingID: $editingVolumeID,
                                     label: l10n.s.mixerInputTitle) {
                    input.setInputVolume($0)
                }
                .disabled(micMute.isMuted)
            }
            .frame(height: 22)
        }
        if input.inputDevices.isEmpty {
            message(l10n.s.mixerInputNoDevices, systemImage: "mic.slash")
        } else if !audioPriority.inputPriorityEnabled, input.preferredUnavailable {
            message(l10n.s.mixerInputFallback, systemImage: "mic.badge.xmark")
        } else if let lastError = input.lastError {
            message(String(format: l10n.s.mixerInputErrorFormat, lastError), systemImage: "exclamationmark.triangle")
        }
    }

    private func row<Menu: View>(_ title: String, symbol: String, @ViewBuilder menu: () -> Menu) -> some View {
        HStack(spacing: 8) {
            Image(systemName: symbol).font(.system(size: 11, weight: .medium)).foregroundStyle(.secondary).frame(width: 18)
            Text(title).font(.system(size: 11)).foregroundStyle(.secondary).lineLimit(1)
            Spacer(minLength: 4)
            menu()
        }
        .frame(height: 22)
    }

    private func message(_ text: String, systemImage: String) -> some View {
        Label(text, systemImage: systemImage)
            .font(.system(size: 9.5))
            .foregroundStyle(.secondary)
            .lineLimit(2)
            .fixedSize(horizontal: false, vertical: true)
    }
}

/// One app: its icon and name, a level that slides left to right and its
/// typed level, then reset, mute and the app's menu. The track ticks at
/// unity, and the slider turns amber in the boost range the way the panel's
/// does. The panel row's output picker and context menu fold into the row's
/// own menu, with the route shown as a badge on the icon.
private struct NotchAppRow: View {
    let app: MixerApp
    @Binding var editingVolumeID: String?
    let isPinned: Bool
    let togglePin: () -> Void
    let moveUp: (() -> Void)?
    let moveDown: (() -> Void)?
    @ObservedObject private var mixer = AppVolumeMixer.shared
    @ObservedObject private var l10n = L10n.shared
    private var strings: MixerFeatureStrings { FeatureStrings.mixer(l10n.language) }
    private var percent: Int { MixerRoutingSupport.displayPercent(forVolume: app.volume) }
    private var sharingStrings: MixerScreenSharingStrings { .localized(l10n.language) }
    private var boosting: Bool { percent > 100 }
    private var muted: Bool { app.volume <= 0.001 }
    private var routed: Bool { !app.isBypassed && app.selectedOutputDeviceUID != nil }
    private var routeDescription: String {
        if app.outputDeviceUnavailable { return l10n.s.mixerOutputFallback }
        return mixer.outputDevices.first(where: { $0.uid == app.selectedOutputDeviceUID })?.name
            ?? l10n.s.mixerOutputUnavailable
    }

    var body: some View {
        HStack(spacing: NotchMixerRowLayout.gap) {
            icon
                .frame(width: NotchMixerRowLayout.leading, height: NotchMixerRowLayout.height)
                .help(app.supportsVolumeOverride && !app.isBypassed ? sharingStrings.sharingWarning : app.name)
            NotchMixerRowName(text: app.name, pinned: isPinned)
            if app.isBypassed {
                Text(app.supportsVolumeOverride ? sharingStrings.protectedCaption : l10n.s.mixerBypassedCaption)
                    .font(.system(size: 9.5)).foregroundStyle(.secondary)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                NotchLevelSlider(value: Binding(get: { app.volume }, set: { mixer.setVolume($0, for: app) }),
                                 label: app.name, range: 0...AppVolumeMixer.maxVolume,
                                 tint: boosting ? .orange : .white, trackThickness: NotchMixerRowLayout.track, marker: 1,
                                 valueLabel: "\(percent)%")
                    .frame(height: NotchMixerRowLayout.height)
                NotchEditablePercent(percent: percent, maximum: Int(AppVolumeMixer.maxVolume * 100),
                                     editorID: "notch-app:\(app.id)", editingID: $editingVolumeID,
                                     label: app.name, tint: boosting ? .orange : .secondary,
                                     boosting: boosting, width: NotchMixerRowLayout.percent, height: 22) {
                    mixer.setVolume($0, for: app)
                }
                .frame(width: NotchMixerRowLayout.percent)
            }
            trailing
        }
        .frame(height: NotchMixerRowLayout.height)
        .contentShape(Rectangle())
        .contextMenu { actions }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(app.name)
        .accessibilityValue("\(percent)%")
        .accessibilityAction(named: Text(strings.moveUp)) { moveUp?() }
        .accessibilityAction(named: Text(strings.moveDown)) { moveDown?() }
    }

    /// Reset, mute and the menu keep fixed places, so a row that hides its
    /// reset at 100% does not shift its neighbors.
    private var trailing: some View {
        HStack(spacing: 2) {
            if !app.isBypassed {
                Button { mixer.setVolume(1, for: app) } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(boosting ? Color.orange : Color.secondary)
                        .frame(width: 24, height: 26)
                        .contentShape(Rectangle())
                }
                .buttonStyle(NotchButtonStyle(cornerRadius: 5))
                .opacity(percent == 100 ? 0 : 1)
                .disabled(percent == 100)
                .help(l10n.s.mixerResetTooltip)
                .accessibilityLabel(l10n.s.mixerResetTooltip)
                Button { mixer.toggleMute(app) } label: {
                    Image(systemName: muted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(muted ? Color.red : Color.secondary)
                        .frame(width: 24, height: 26)
                        .contentShape(Rectangle())
                }
                .buttonStyle(NotchButtonStyle(cornerRadius: 5))
                .accessibilityLabel(muted ? l10n.s.actionUnmute : l10n.s.actionMute)
            }
            if app.persistenceID != nil || !app.isBypassed { actionsMenu }
        }
        .frame(width: NotchMixerRowLayout.trailing, alignment: .trailing)
    }

    private var icon: some View {
        ZStack(alignment: .bottomTrailing) {
            Image(nsImage: ResponsibleProcess.icon(for: app.ownerPid, pointSize: 32))
                .resizable()
                .frame(width: 24, height: 24)
            if app.isPlaying {
                Circle().fill(.green).frame(width: 7, height: 7)
                    .overlay(Circle().stroke(.black, lineWidth: 1.2))
                    .offset(x: 1, y: 1)
                    .accessibilityHidden(true)
            }
        }
        .overlay(alignment: .bottomLeading) {
            // An app sent to its own device wears the route on its icon; the
            // panel's row shows the picker itself, which this row has no
            // room for.
            if routed {
                Image(systemName: app.outputDeviceUnavailable ? "exclamationmark.triangle.fill" : "arrow.triangle.branch")
                    .font(.system(size: 7, weight: .bold))
                    .foregroundStyle(app.outputDeviceUnavailable ? Color.orange : Color.white)
                    .frame(width: 12, height: 12)
                    .background(.black, in: Circle())
                    .offset(x: -2, y: 1)
                    .help(routeDescription)
                    .accessibilityLabel(routeDescription)
            }
        }
    }

    private var actionsMenu: some View {
        Menu { actions } label: {
            Image(systemName: "ellipsis")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.white.opacity(0.7))
                .frame(width: 24, height: 26)
                .contentShape(Rectangle())
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
        .fixedSize()
        .help(strings.actions)
        .accessibilityLabel("\(strings.actions): \(app.name)")
    }

    @ViewBuilder private var actions: some View {
        if app.persistenceID != nil {
            Button(action: togglePin) {
                Label(isPinned ? strings.unpin : strings.pinFirst, systemImage: isPinned ? "pin.slash" : "pin")
            }
            Button { moveUp?() } label: { Label(strings.moveUp, systemImage: "arrow.up") }
                .disabled(moveUp == nil)
            Button { moveDown?() } label: { Label(strings.moveDown, systemImage: "arrow.down") }
                .disabled(moveDown == nil)
        }
        if app.supportsVolumeOverride {
            Divider()
            Toggle(sharingStrings.allowVolumeControl, isOn: Binding(
                get: { !app.isBypassed },
                set: { mixer.setCallAppVolumeControl($0, for: app) }))
                .help(sharingStrings.sharingWarning)
        }
        if !app.isBypassed {
            if app.persistenceID != nil { Divider() }
            Picker(l10n.s.mixerOutputTooltip, selection: outputSelection) {
                Text(l10n.s.mixerOutputDefault).tag(MixerRoutingSupport.systemDefaultSelectionID)
                ForEach(mixer.outputDevices) { device in
                    Text(device.isDefault ? "\(device.name) (\(l10n.s.mixerOutputCurrent))" : device.name).tag(device.uid)
                }
                if let selected = app.selectedOutputDeviceUID,
                   MixerRoutingSupport.needsUnavailableOutputRow(selectedUID: selected,
                                                                 isUnavailable: app.outputDeviceUnavailable,
                                                                 listedUIDs: mixer.outputDevices.map(\.uid)) {
                    Text(l10n.s.mixerOutputUnavailable).tag(selected)
                }
                if mixer.outputDevices.contains(where: { MixerRoutingSupport.isAirPlaySentinel($0.uid) }) {
                    Divider()
                    Text(l10n.s.mixerAirPlayChooseSpeaker).tag(MixerRoutingSupport.airPlaySpeakerChoiceID)
                }
            }
            .pickerStyle(.menu)
            Divider()
            Button(l10n.s.mixerResetTooltip) { mixer.setVolume(1, for: app) }
                .disabled(percent == 100)
        }
        if app.persistenceID != nil {
            Divider()
            Button(l10n.s.mixerHideFromList) { mixer.hideFromList(app) }
        }
    }

    private var outputSelection: Binding<String> {
        Binding(
            get: { app.selectedOutputDeviceUID ?? MixerRoutingSupport.systemDefaultSelectionID },
            set: { selection in
                mixer.setOutputDeviceUID(selection == MixerRoutingSupport.systemDefaultSelectionID ? nil : selection,
                                         for: app)
            }
        )
    }
}

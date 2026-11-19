// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Foundation

struct MonitorLayoutFeatureStrings {
    /// Heading for the settings shared by the menu bar and the panel.
    let shared: String
    /// Names the bytes or bits choice for live network speeds, as its
    /// settings row and as the panel button that flips it.
    let networkSpeedUnit: String
    /// Names the RPM or percentage choice for fan speed readouts.
    let fanSpeedUnit: String
}

extension FeatureStrings {
    static func monitorLayout(_ language: AppLanguage) -> MonitorLayoutFeatureStrings {
        switch language {
        case .enUS: return .enUS
        case .ptBR: return .ptBR
        case .tr: return .tr
        case .ru: return .ru
        case .es: return .es
        case .sk: return .sk
        case .de: return .de
        case .fr: return .fr
        case .it: return .it
        case .ja: return .ja
        case .ko: return .ko
        case .zhHans: return .zhHans
        case .zhTW: return .zhTW
        case .zhHK: return .zhHK
        case .uk: return .uk
        }
    }
}

extension MonitorLayoutFeatureStrings {
    static let enUS = MonitorLayoutFeatureStrings(
        shared: "Readings and alerts",
        networkSpeedUnit: "Network speed unit",
        fanSpeedUnit: "Fan speed unit"
    )

    static let ptBR = MonitorLayoutFeatureStrings(
        shared: "Leituras e alertas",
        networkSpeedUnit: "Unidade de velocidade da rede",
        fanSpeedUnit: "Unidade de velocidade da ventoinha"
    )

    static let tr = MonitorLayoutFeatureStrings(
        shared: "Ölçümler ve uyarılar",
        networkSpeedUnit: "Ağ hızı birimi",
        fanSpeedUnit: "Fan hızı birimi"
    )

    static let ru = MonitorLayoutFeatureStrings(
        shared: "Показания и оповещения",
        networkSpeedUnit: "Единица скорости сети",
        fanSpeedUnit: "Единица скорости вентилятора"
    )

    static let es = MonitorLayoutFeatureStrings(
        shared: "Lecturas y alertas",
        networkSpeedUnit: "Unidad de velocidad de red",
        fanSpeedUnit: "Unidad de velocidad del ventilador"
    )

    static let sk = MonitorLayoutFeatureStrings(
        shared: "Hodnoty a hlásenia",
        networkSpeedUnit: "Jednotka rýchlosti siete",
        fanSpeedUnit: "Jednotka rýchlosti ventilátora"
    )

    static let de = MonitorLayoutFeatureStrings(
        shared: "Messwerte und Warnungen",
        networkSpeedUnit: "Einheit der Netzwerkgeschwindigkeit",
        fanSpeedUnit: "Einheit der Lüftergeschwindigkeit"
    )

    static let fr = MonitorLayoutFeatureStrings(
        shared: "Mesures et alertes",
        networkSpeedUnit: "Unité de débit réseau",
        fanSpeedUnit: "Unité de vitesse du ventilateur"
    )

    static let it = MonitorLayoutFeatureStrings(
        shared: "Letture e avvisi",
        networkSpeedUnit: "Unità di velocità di rete",
        fanSpeedUnit: "Unità di velocità della ventola"
    )

    static let ja = MonitorLayoutFeatureStrings(
        shared: "計測と通知",
        networkSpeedUnit: "ネットワーク速度の単位",
        fanSpeedUnit: "ファン速度の単位"
    )

    static let ko = MonitorLayoutFeatureStrings(
        shared: "측정값 및 알림",
        networkSpeedUnit: "네트워크 속도 단위",
        fanSpeedUnit: "팬 속도 단위"
    )

    static let zhHans = MonitorLayoutFeatureStrings(
        shared: "读数与提醒",
        networkSpeedUnit: "网络速度单位",
        fanSpeedUnit: "风扇转速单位"
    )

    static let zhTW = MonitorLayoutFeatureStrings(
        shared: "讀數與提醒",
        networkSpeedUnit: "網路速度單位",
        fanSpeedUnit: "風扇轉速單位"
    )

    static let zhHK = MonitorLayoutFeatureStrings(
        shared: "讀數與提醒",
        networkSpeedUnit: "網絡速度單位",
        fanSpeedUnit: "風扇轉速單位"
    )

    static let uk = MonitorLayoutFeatureStrings(
        shared: "Показники та сповіщення",
        networkSpeedUnit: "Одиниця швидкості мережі",
        fanSpeedUnit: "Одиниця швидкості вентилятора"
    )
}

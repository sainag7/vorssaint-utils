// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

/// The setting for the space between menu bar metrics.
struct MenuBarGapStrings {
    let title: String
    let automatic: String
    let caption: String

    static func localized(_ language: AppLanguage) -> MenuBarGapStrings {
        switch language {
        case .enUS: return .init(title: "Space between metrics", automatic: "Automatic",
                                 caption: "Turn off Automatic to set the gap yourself, from touching to wide.")
        case .ptBR: return .init(title: "Espaço entre as métricas", automatic: "Automático",
                                 caption: "Desative Automático para definir o espaço você mesmo, de colado a largo.")
        case .tr: return .init(title: "Ölçümler arasındaki boşluk", automatic: "Otomatik",
                               caption: "Boşluğu kendiniz ayarlamak için Otomatik’i kapatın; bitişikten genişe.")
        case .ru: return .init(title: "Расстояние между показателями", automatic: "Автоматически",
                               caption: "Выключите «Автоматически», чтобы задать расстояние самому — от вплотную до широкого.")
        case .es: return .init(title: "Espacio entre métricas", automatic: "Automático",
                               caption: "Desactiva Automático para elegir el espacio tú mismo, de juntas a amplias.")
        case .sk: return .init(title: "Medzera medzi metrikami", automatic: "Automaticky",
                               caption: "Vypnite Automaticky a nastavte medzeru sami, od tesnej po širokú.")
        case .de: return .init(title: "Abstand zwischen Messwerten", automatic: "Automatisch",
                               caption: "Schalte Automatisch aus, um den Abstand selbst festzulegen – von eng bis weit.")
        case .fr: return .init(title: "Espace entre les mesures", automatic: "Automatique",
                               caption: "Désactivez Automatique pour régler l’espace vous‑même, de serré à large.")
        case .it: return .init(title: "Spazio tra le metriche", automatic: "Automatico",
                               caption: "Disattiva Automatico per scegliere tu lo spazio, da attaccate a larghe.")
        case .ja: return .init(title: "項目の間隔", automatic: "自動",
                               caption: "「自動」をオフにすると、ぴったりから広めまで間隔を自分で設定できます。")
        case .ko: return .init(title: "항목 사이 간격", automatic: "자동",
                               caption: "자동을 끄면 붙어 있는 정도부터 넓은 정도까지 간격을 직접 정할 수 있습니다.")
        case .uk: return .init(title: "Відстань між показниками", automatic: "Автоматично",
                               caption: "Вимкніть «Автоматично», щоб задати відстань самостійно — від впритул до широкої.")
        case .zhHans: return .init(title: "指标间距", automatic: "自动",
                                   caption: "关闭“自动”即可自行设置间距，从紧贴到宽松。")
        case .zhTW: return .init(title: "指標間距", automatic: "自動",
                                 caption: "關閉「自動」即可自行設定間距，從緊貼到寬鬆。")
        case .zhHK: return .init(title: "指標間距", automatic: "自動",
                                 caption: "關閉「自動」即可自行設定間距，從緊貼到寬鬆。")
        }
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

/// The Power page's Low Power Mode switch and its one-time password prompt.
struct LowPowerModeStrings {
    let title: String
    /// Shown in the macOS password dialog the first time the switch is used.
    let prompt: String

    static func localized(_ language: AppLanguage) -> LowPowerModeStrings {
        switch language {
        case .enUS: return .init(title: "Low Power Mode",
                                 prompt: "Vorssaint will create a restricted rule (pmset lowpowermode only) so Low Power Mode can be switched without a password. This is the only time the password is needed.")
        case .ptBR: return .init(title: "Modo de Pouca Energia",
                                 prompt: "O Vorssaint vai criar uma regra restrita (somente pmset lowpowermode) para alternar o Modo de Pouca Energia sem pedir senha. Esta é a única vez que a senha será necessária.")
        case .tr: return .init(title: "Düşük Güç Modu",
                               prompt: "Vorssaint, Düşük Güç Modu’nun parola sorulmadan değiştirilebilmesi için kısıtlı bir kural (yalnızca pmset lowpowermode) oluşturacak. Parola yalnızca bu sefer gerekir.")
        case .ru: return .init(title: "Режим энергосбережения",
                               prompt: "Vorssaint создаст ограниченное правило (только pmset lowpowermode), чтобы режим энергосбережения переключался без пароля. Пароль нужен только сейчас.")
        case .es: return .init(title: "Modo de bajo consumo",
                               prompt: "Vorssaint creará una regla restringida (solo pmset lowpowermode) para cambiar el modo de bajo consumo sin contraseña. Es la única vez que se necesita la contraseña.")
        case .sk: return .init(title: "Režim nízkej spotreby",
                               prompt: "Vorssaint vytvorí obmedzené pravidlo (iba pmset lowpowermode), aby sa režim nízkej spotreby dal prepínať bez hesla. Heslo je potrebné iba teraz.")
        case .de: return .init(title: "Stromsparmodus",
                               prompt: "Vorssaint erstellt eine eingeschränkte Regel (nur pmset lowpowermode), damit der Stromsparmodus ohne Passwort umgeschaltet werden kann. Das Passwort wird nur dieses eine Mal benötigt.")
        case .fr: return .init(title: "Mode économie d’énergie",
                               prompt: "Vorssaint va créer une règle restreinte (pmset lowpowermode uniquement) pour changer le mode économie d’énergie sans mot de passe. C’est la seule fois où le mot de passe est nécessaire.")
        case .it: return .init(title: "Modalità risparmio energetico",
                               prompt: "Vorssaint creerà una regola limitata (solo pmset lowpowermode) per cambiare la modalità risparmio energetico senza password. È l’unica volta in cui serve la password.")
        case .ja: return .init(title: "低電力モード",
                               prompt: "Vorssaint は、パスワードなしで低電力モードを切り替えられるよう、制限付きのルール（pmset lowpowermode のみ）を作成します。パスワードが必要なのは今回だけです。")
        case .ko: return .init(title: "저전력 모드",
                               prompt: "Vorssaint가 암호 없이 저전력 모드를 전환할 수 있도록 제한된 규칙(pmset lowpowermode 전용)을 만듭니다. 암호는 이번 한 번만 필요합니다.")
        case .uk: return .init(title: "Режим низького енергоспоживання",
                               prompt: "Vorssaint створить обмежене правило (лише pmset lowpowermode), щоб режим низького енергоспоживання перемикався без пароля. Пароль потрібен лише цього разу.")
        case .zhHans: return .init(title: "低电量模式",
                                   prompt: "Vorssaint 将创建一条受限规则（仅限 pmset lowpowermode），以便无需密码即可切换低电量模式。只有这一次需要密码。")
        case .zhTW: return .init(title: "低耗電模式",
                                 prompt: "Vorssaint 將建立一條受限規則（僅限 pmset lowpowermode），讓低耗電模式不需密碼即可切換。只有這一次需要密碼。")
        case .zhHK: return .init(title: "低耗電模式",
                                 prompt: "Vorssaint 將建立一條受限規則（只限 pmset lowpowermode），讓低耗電模式毋須密碼即可切換。只有這一次需要密碼。")
        }
    }
}

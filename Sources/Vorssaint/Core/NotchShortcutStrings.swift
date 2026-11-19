// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

/// The island tile that runs a shortcut from Apple's Shortcuts app, named the
/// way each language's Shortcuts app names its own Run Shortcut action.
struct NotchShortcutStrings {
    let title: String
    let pick: String
    let caption: String
    let none: String
    let icon: String
    let automatic: String
    let openApp: String

    static func localized(_ language: AppLanguage) -> NotchShortcutStrings {
        switch language {
        case .enUS: return .init(title: "Run Shortcut", pick: "Shortcut to run",
                                 caption: "Runs one of your shortcuts from the Shortcuts app, like starting a FaceTime call.",
                                 none: "None", icon: "Tile icon", automatic: "Automatic", openApp: "Open Shortcuts")
        case .ptBR: return .init(title: "Executar Atalho", pick: "Atalho a executar",
                                 caption: "Executa um dos seus atalhos do app Atalhos, como iniciar uma ligação do FaceTime.",
                                 none: "Nenhum", icon: "Ícone do bloco", automatic: "Automático", openApp: "Abrir Atalhos")
        case .tr: return .init(title: "Kestirmeyi Çalıştır", pick: "Çalıştırılacak kestirme",
                               caption: "Kestirmeler uygulamasındaki kestirmelerinizden birini çalıştırır; örneğin bir FaceTime araması başlatır.",
                               none: "Yok", icon: "Kutucuk simgesi", automatic: "Otomatik", openApp: "Kestirmeler’i Aç")
        case .ru: return .init(title: "Запустить быструю команду", pick: "Быстрая команда",
                               caption: "Запускает одну из ваших быстрых команд из приложения «Быстрые команды», например звонок FaceTime.",
                               none: "Нет", icon: "Значок плитки", automatic: "Автоматически", openApp: "Открыть «Быстрые команды»")
        case .es: return .init(title: "Ejecutar atajo", pick: "Atajo que se ejecuta",
                               caption: "Ejecuta uno de tus atajos de la app Atajos, como iniciar una llamada de FaceTime.",
                               none: "Ninguno", icon: "Icono del botón", automatic: "Automático", openApp: "Abrir Atajos")
        case .sk: return .init(title: "Spustiť skratku", pick: "Skratka na spustenie",
                               caption: "Spustí jednu z vašich skratiek z aplikácie Skratky, napríklad hovor FaceTime.",
                               none: "Žiadna", icon: "Ikona dlaždice", automatic: "Automaticky", openApp: "Otvoriť Skratky")
        case .de: return .init(title: "Kurzbefehl ausführen", pick: "Auszuführender Kurzbefehl",
                               caption: "Führt einen deiner Kurzbefehle aus der App „Kurzbefehle“ aus, etwa einen FaceTime-Anruf.",
                               none: "Keiner", icon: "Kachelsymbol", automatic: "Automatisch", openApp: "Kurzbefehle öffnen")
        case .fr: return .init(title: "Exécuter le raccourci", pick: "Raccourci à exécuter",
                               caption: "Exécute l’un de vos raccourcis de l’app Raccourcis, comme un appel FaceTime.",
                               none: "Aucun", icon: "Icône de la tuile", automatic: "Automatique", openApp: "Ouvrir Raccourcis")
        case .it: return .init(title: "Esegui comando rapido", pick: "Comando rapido da eseguire",
                               caption: "Esegue uno dei tuoi comandi rapidi dall’app Comandi Rapidi, come avviare una chiamata FaceTime.",
                               none: "Nessuno", icon: "Icona del riquadro", automatic: "Automatica", openApp: "Apri Comandi Rapidi")
        case .ja: return .init(title: "ショートカットを実行", pick: "実行するショートカット",
                               caption: "ショートカットAppのショートカットを実行します。FaceTime通話の開始などに使えます。",
                               none: "なし", icon: "タイルのアイコン", automatic: "自動", openApp: "ショートカットを開く")
        case .ko: return .init(title: "단축어 실행", pick: "실행할 단축어",
                               caption: "단축어 앱의 단축어를 실행합니다. 예를 들어 FaceTime 통화를 시작할 수 있습니다.",
                               none: "없음", icon: "타일 아이콘", automatic: "자동", openApp: "단축어 열기")
        case .uk: return .init(title: "Запустити швидку команду", pick: "Швидка команда",
                               caption: "Запускає одну з ваших швидких команд із програми «Швидкі команди», наприклад дзвінок FaceTime.",
                               none: "Немає", icon: "Значок плитки", automatic: "Автоматично", openApp: "Відкрити «Швидкі команди»")
        case .zhHans: return .init(title: "运行快捷指令", pick: "要运行的快捷指令",
                                   caption: "运行“快捷指令”App 中的快捷指令，例如发起 FaceTime 通话。",
                                   none: "无", icon: "按钮图标", automatic: "自动", openApp: "打开“快捷指令”")
        case .zhTW: return .init(title: "執行捷徑", pick: "要執行的捷徑",
                                 caption: "執行「捷徑」App 中的捷徑，例如開始 FaceTime 通話。",
                                 none: "無", icon: "按鈕圖像", automatic: "自動", openApp: "打開「捷徑」")
        case .zhHK: return .init(title: "執行捷徑", pick: "要執行的捷徑",
                                 caption: "執行「捷徑」App 中的捷徑，例如開始 FaceTime 通話。",
                                 none: "無", icon: "按鈕圖像", automatic: "自動", openApp: "打開「捷徑」")
        }
    }
}

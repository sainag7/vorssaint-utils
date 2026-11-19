// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

/// The menu bar battery's look and the power split in its details.
struct BatteryDisplayStrings {
    let styleLabel: String
    let styleInside: String
    let styleIconAndPercent: String
    let systemTotal: String
    /// Power coming in from the charger.
    let dcIn: String
    /// Heading of the hourly battery-use chart.
    let usedPerHour: String
    /// Shown before any hour has a recorded drop.
    let noUseYet: String

    static func localized(_ language: AppLanguage) -> BatteryDisplayStrings {
        switch language {
        case .enUS: return .init(styleLabel: "Battery style", styleInside: "Percentage inside icon",
                                 styleIconAndPercent: "Icon and percentage", systemTotal: "System total",
                                 dcIn: "DC In", usedPerHour: "Battery used per hour",
                                 noUseYet: "No battery use recorded yet")
        case .ptBR: return .init(styleLabel: "Estilo da bateria", styleInside: "Porcentagem dentro do ícone",
                                 styleIconAndPercent: "Ícone e porcentagem", systemTotal: "Total do sistema",
                                 dcIn: "Entrada CC", usedPerHour: "Bateria usada por hora",
                                 noUseYet: "Nenhum uso de bateria registrado ainda")
        case .tr: return .init(styleLabel: "Pil stili", styleInside: "Yüzde simgenin içinde",
                               styleIconAndPercent: "Simge ve yüzde", systemTotal: "Sistem toplamı",
                               dcIn: "DC girişi", usedPerHour: "Saat başına kullanılan pil",
                               noUseYet: "Henüz kaydedilmiş pil kullanımı yok")
        case .ru: return .init(styleLabel: "Вид батареи", styleInside: "Процент внутри значка",
                               styleIconAndPercent: "Значок и процент", systemTotal: "Вся система",
                               dcIn: "Вход DC", usedPerHour: "Расход батареи по часам",
                               noUseYet: "Расход батареи ещё не записан")
        case .es: return .init(styleLabel: "Estilo de la batería", styleInside: "Porcentaje dentro del icono",
                               styleIconAndPercent: "Icono y porcentaje", systemTotal: "Total del sistema",
                               dcIn: "Entrada CC", usedPerHour: "Batería usada por hora",
                               noUseYet: "Aún no hay uso de batería registrado")
        case .sk: return .init(styleLabel: "Štýl batérie", styleInside: "Percentá v ikone",
                               styleIconAndPercent: "Ikona a percentá", systemTotal: "Celý systém",
                               dcIn: "Vstup DC", usedPerHour: "Spotreba batérie za hodinu",
                               noUseYet: "Zatiaľ nie je zaznamenaná spotreba batérie")
        case .de: return .init(styleLabel: "Batteriestil", styleInside: "Prozent im Symbol",
                               styleIconAndPercent: "Symbol und Prozent", systemTotal: "Gesamtsystem",
                               dcIn: "DC-Eingang", usedPerHour: "Akkuverbrauch pro Stunde",
                               noUseYet: "Noch kein Akkuverbrauch erfasst")
        case .fr: return .init(styleLabel: "Style de la batterie", styleInside: "Pourcentage dans l’icône",
                               styleIconAndPercent: "Icône et pourcentage", systemTotal: "Total du système",
                               dcIn: "Entrée CC", usedPerHour: "Batterie utilisée par heure",
                               noUseYet: "Aucune utilisation de la batterie enregistrée")
        case .it: return .init(styleLabel: "Stile della batteria", styleInside: "Percentuale nell’icona",
                               styleIconAndPercent: "Icona e percentuale", systemTotal: "Totale del sistema",
                               dcIn: "Ingresso CC", usedPerHour: "Batteria usata per ora",
                               noUseYet: "Nessun uso della batteria registrato")
        case .ja: return .init(styleLabel: "バッテリーの表示", styleInside: "アイコン内にパーセント",
                               styleIconAndPercent: "アイコンとパーセント", systemTotal: "システム全体",
                               dcIn: "DC入力", usedPerHour: "1時間ごとのバッテリー使用量",
                               noUseYet: "バッテリー使用の記録はまだありません")
        case .ko: return .init(styleLabel: "배터리 표시", styleInside: "아이콘 안에 퍼센트",
                               styleIconAndPercent: "아이콘과 퍼센트", systemTotal: "시스템 전체",
                               dcIn: "DC 입력", usedPerHour: "시간당 배터리 사용량",
                               noUseYet: "아직 기록된 배터리 사용량이 없습니다")
        case .uk: return .init(styleLabel: "Вигляд батареї", styleInside: "Відсоток усередині значка",
                               styleIconAndPercent: "Значок і відсоток", systemTotal: "Уся система",
                               dcIn: "Вхід DC", usedPerHour: "Витрата батареї за годину",
                               noUseYet: "Витрату батареї ще не записано")
        case .zhHans: return .init(styleLabel: "电池样式", styleInside: "百分比在图标内",
                                   styleIconAndPercent: "图标和百分比", systemTotal: "系统总计",
                                   dcIn: "直流输入", usedPerHour: "每小时电池用量",
                                   noUseYet: "尚未记录电池用量")
        case .zhTW: return .init(styleLabel: "電池樣式", styleInside: "百分比在圖像內",
                                 styleIconAndPercent: "圖像和百分比", systemTotal: "系統總計",
                                 dcIn: "直流輸入", usedPerHour: "每小時電池用量",
                                 noUseYet: "尚未記錄電池用量")
        case .zhHK: return .init(styleLabel: "電池樣式", styleInside: "百分比在圖像內",
                                 styleIconAndPercent: "圖像和百分比", systemTotal: "系統總計",
                                 dcIn: "直流輸入", usedPerHour: "每小時電池用量",
                                 noUseYet: "尚未記錄電池用量")
        }
    }
}

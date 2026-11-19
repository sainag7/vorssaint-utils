// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

/// The mixer option that lets the wheel or trackpad change level sliders.
struct SliderScrollStrings {
    let title: String
    let caption: String

    static func localized(_ language: AppLanguage) -> SliderScrollStrings {
        switch language {
        case .enUS: return .init(title: "Adjust sliders with the scroll wheel",
                                 caption: "When off, scrolling moves the list and sliders change only by dragging.")
        case .ptBR: return .init(title: "Ajustar controles com a roda de rolagem",
                                 caption: "Desativado, a rolagem move a lista e os controles só mudam ao arrastar.")
        case .tr: return .init(title: "Kaydırıcıları kaydırma tekerleğiyle ayarla",
                               caption: "Kapalıyken kaydırma listeyi hareket ettirir; kaydırıcılar yalnızca sürükleyerek değişir.")
        case .ru: return .init(title: "Менять ползунки колесом прокрутки",
                               caption: "Если выключено, прокрутка двигает список, а ползунки меняются только перетаскиванием.")
        case .es: return .init(title: "Ajustar controles con la rueda de desplazamiento",
                               caption: "Desactivado, el desplazamiento mueve la lista y los controles solo cambian al arrastrar.")
        case .sk: return .init(title: "Upravovať posuvníky kolieskom",
                               caption: "Keď je vypnuté, posúvanie posúva zoznam a posuvníky sa menia len ťahaním.")
        case .de: return .init(title: "Regler mit dem Scrollrad ändern",
                               caption: "Wenn aus, scrollt das Rad die Liste und Regler ändern sich nur durch Ziehen.")
        case .fr: return .init(title: "Régler les curseurs avec la molette",
                               caption: "Désactivé, la molette fait défiler la liste et les curseurs ne changent qu’en les faisant glisser.")
        case .it: return .init(title: "Regola i cursori con la rotella",
                               caption: "Se disattivato, lo scorrimento muove l’elenco e i cursori cambiano solo trascinandoli.")
        case .ja: return .init(title: "スクロールホイールでスライダーを調整",
                               caption: "オフのときはスクロールでリストが動き、スライダーはドラッグでのみ変わります。")
        case .ko: return .init(title: "스크롤 휠로 슬라이더 조절",
                               caption: "끄면 스크롤은 목록을 움직이고 슬라이더는 드래그로만 바뀝니다.")
        case .uk: return .init(title: "Змінювати повзунки коліщатком",
                               caption: "Якщо вимкнено, прокручування рухає список, а повзунки змінюються лише перетягуванням.")
        case .zhHans: return .init(title: "用滚轮调节滑块",
                                   caption: "关闭时，滚动会移动列表，滑块只能通过拖动调节。")
        case .zhTW: return .init(title: "用滾輪調整滑桿",
                                 caption: "關閉時，捲動會移動列表，滑桿只能透過拖曳調整。")
        case .zhHK: return .init(title: "用滾輪調整滑桿",
                                 caption: "關閉時，捲動會移動列表，滑桿只能透過拖曳調整。")
        }
    }
}

enum MenuItem {
    case feedback
    case terms
    case twitter
    case schedule
    case timetable

    var pageName: String {
        switch self {
        case .feedback:
            return "フィードバックを送信"
        case .terms:
            return "利用規約"
        case .twitter:
            return "最新情報【X】"
        case .schedule:
            return "運行スケジュール"
        case .timetable:
            return "時刻表"
        }
    }

    var pageURL: String {
        switch self {
        case .feedback:
            return "https://forms.gle/wpq6MYUeWfisKDKQA"
        case .terms:
            return "https://ryota2425.github.io/"
        case .twitter:
            return "https://twitter.com/busdes_rits"
        case .schedule:
            return "https://mercy34mercy.github.io/bustimer_kic/shuttle/schedule.jpg"
        case .timetable:
            return "https://mercy34mercy.github.io/bustimer_kic/shuttle/timetable.jpg"
        }
    }
}

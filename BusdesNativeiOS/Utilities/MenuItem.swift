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
            return Constants.ExternalLinks.feedback
        case .terms:
            return Constants.ExternalLinks.terms
        case .twitter:
            return Constants.ExternalLinks.twitter
        case .schedule:
            return Constants.ExternalLinks.schedule
        case .timetable:
            return Constants.ExternalLinks.timetable
        }
    }
}

// Constants.swift
import Foundation

struct Constants {
    struct API {
        static let baseURL = "https://busdesrits.com/bus" // ベースURL
        static let nextBusEndpoint = "/time/v3"           // V3接近情報
        static let timeTableEndpoint = "/timetable"       // 時刻表
        // 例: "https://busdesrits.com/bus/time/v3?fr=\(from)&to=\(to)"

        static func nextBusURL(from: String, to: String) -> URL? {
            guard let encodedFr = from.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                  let encodedTo = to.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                return nil
            }
            let urlString = baseURL + nextBusEndpoint + "?fr=\(encodedFr)&to=\(encodedTo)"
            return URL(string: urlString)
        }

         static func timeTableURL(from: String, to: String) -> URL? {
            guard let encodedFr = from.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                  let encodedTo = to.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                return nil
            }
             let urlString = baseURL + timeTableEndpoint + "?fr=\(encodedFr)&to=\(encodedTo)"
             return URL(string: urlString)
         }
    }

    struct ExternalLinks {
        static let feedback = "https://forms.gle/wpq6MYUeWfisKDKQA"
        static let terms = "https://ryota2425.github.io/"
        static let twitter = "https://twitter.com/busdes_rits"
        static let schedule = "https://mercy34mercy.github.io/bustimer_kic/shuttle/schedule.jpg"
        static let timetable = "https://mercy34mercy.github.io/bustimer_kic/shuttle/timetable.jpg"
    }
}
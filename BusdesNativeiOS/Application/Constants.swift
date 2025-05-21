import Foundation

struct Constants {
    struct API {
        static let baseURL = "https://busdesrits.com/bus"
        static let nextBusEndpoint = "/time/v3"
        static let timeTableEndpoint = "/timetable"

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
        static let terms =  "https://busdesrits.com/static"
        static let twitter = "https://twitter.com/busdes_rits"
        static let schedule = "https://busdesrits.com/static/schedule.jpg"
        static let timetable = "https://busdesrits.com/static/daiya.jpg"
    }
}

import Foundation

struct TimeTable: Codable {
    var weekdays: TimeList
    var saturdays: TimeList
    var holidays: TimeList
}

struct TimeTableInfo: Codable {
    let via: String
    let min: String
    let busStop: String
}

struct TimeList: Codable {
    let five: [TimeTableInfo]
    let six: [TimeTableInfo]
    let seven: [TimeTableInfo]
    let eight: [TimeTableInfo]
    let nine: [TimeTableInfo]
    let ten: [TimeTableInfo]
    let eleven: [TimeTableInfo]
    let twelve: [TimeTableInfo]
    let thirteen: [TimeTableInfo]
    let fourteen: [TimeTableInfo]
    let fifteen: [TimeTableInfo]
    let sixteen: [TimeTableInfo]
    let seventeen: [TimeTableInfo]
    let eighteen: [TimeTableInfo]
    let nineteen: [TimeTableInfo]
    let twenty: [TimeTableInfo]
    let twentyone: [TimeTableInfo]
    let twentytwo: [TimeTableInfo]
    let twentythree: [TimeTableInfo]
    let twentyfour: [TimeTableInfo]

    enum CodingKeys: String, CodingKey {
        case five = "5"
        case six = "6"
        case seven = "7"
        case eight = "8"
        case nine = "9"
        case ten = "10"
        case eleven = "11"
        case twelve = "12"
        case thirteen = "13"
        case fourteen = "14"
        case fifteen = "15"
        case sixteen = "16"
        case seventeen = "17"
        case eighteen = "18"
        case nineteen = "19"
        case twenty = "20"
        case twentyone = "21"
        case twentytwo = "22"
        case twentythree = "23"
        case twentyfour = "24"
    }

    func timesForHour(_ hour: Int) -> [TimeTableInfo] {
        switch hour {
        case 5:
            return five

        case 6:
            return six

        case 7:
            return seven

        case 8:
            return eight

        case 9:
            return nine

        case 10:
            return ten

        case 11:
            return eleven

        case 12:
            return twelve

        case 13:
            return thirteen

        case 14:
            return fourteen

        case 15:
            return fifteen

        case 16:
            return sixteen

        case 17:
            return seventeen

        case 18:
            return eighteen

        case 19:
            return nineteen

        case 20:
            return twenty

        case 21:
            return twentyone

        case 22:
            return twentytwo

        case 23:
            return twentythree

        case 24:
            return twentyfour

        default:
            return []
        }
    }
}

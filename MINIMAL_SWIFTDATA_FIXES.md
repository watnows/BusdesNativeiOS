# 最小限修正案 - バックエンド構造維持でSwiftData対応

## 🎯 方針
- **データ構造は一切変更しない**
- **バックエンドAPIとの互換性100%維持**
- **SwiftDataの最小限要件のみ追加**

## 1. BusStop.swift（最小限修正）
```swift
import Foundation
import SwiftData

@Model
final class BusStop {
    // 🆕 SwiftData用のID（自動生成、APIには送信しない）
    @Attribute(.unique) var persistentID: UUID = UUID()

    // ✅ 既存構造そのまま維持
    var name: String
    var kana: String

    init(name: String, kana: String) {
        self.name = name
        self.kana = kana
        // persistentIDは自動生成される
    }
}

// ✅ Codable対応でバックエンドとの互換性維持
extension BusStop: Codable {
    enum CodingKeys: String, CodingKey {
        case name, kana
        // persistentIDはエンコード/デコードしない
    }
}
```

## 2. Route.swift（最小限修正）
```swift
import SwiftData

@Model
final class Route {
    // 🆕 SwiftData用のID
    @Attribute(.unique) var persistentID: UUID = UUID()

    // ✅ 既存構造そのまま維持
    var to: String
    var from: String

    // 🆕 最小限のメタデータ（ユーザー保存路線管理用）
    var savedAt: Date = Date()
    var isActive: Bool = true

    init(to: String, from: String) {
        self.to = to
        self.from = from
    }
}

// ✅ バックエンド互換性
extension Route: Codable {
    enum CodingKeys: String, CodingKey {
        case to, from
        // savedAt, isActive, persistentIDはエンコードしない
    }
}
```

## 3. TimeTable.swift（構造維持、SwiftData対応）
```swift
import Foundation
import SwiftData

@Model
final class TimeTable {
    // 🆕 SwiftData用のID
    @Attribute(.unique) var persistentID: UUID = UUID()

    // ⚠️ 複雑structはSwiftDataで直接サポートされないため、
    // Codableのまま保持し、必要時にエンコード/デコード
    @Attribute(.externalStorage) var weekdaysData: Data
    @Attribute(.externalStorage) var saturdaysData: Data
    @Attribute(.externalStorage) var holidaysData: Data

    init(weekdays: TimeList, saturdays: TimeList, holidays: TimeList) {
        // TimeListをData型にエンコードして保存
        self.weekdaysData = (try? JSONEncoder().encode(weekdays)) ?? Data()
        self.saturdaysData = (try? JSONEncoder().encode(saturdays)) ?? Data()
        self.holidaysData = (try? JSONEncoder().encode(holidays)) ?? Data()
    }

    // ✅ 既存のAPI構造を再現するcomputed properties
    var weekdays: TimeList {
        get {
            (try? JSONDecoder().decode(TimeList.self, from: weekdaysData)) ?? TimeList.empty
        }
        set {
            weekdaysData = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }

    var saturdays: TimeList {
        get {
            (try? JSONDecoder().decode(TimeList.self, from: saturdaysData)) ?? TimeList.empty
        }
        set {
            saturdaysData = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }

    var holidays: TimeList {
        get {
            (try? JSONDecoder().decode(TimeList.self, from: holidaysData)) ?? TimeList.empty
        }
        set {
            holidaysData = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }
}

// ✅ TimeList構造は完全にそのまま維持
struct TimeList: Codable {
    let five: [TimeTableInfo]
    let six: [TimeTableInfo]
    // ... 既存の全プロパティそのまま

    static let empty = TimeList(
        five: [], six: [], seven: [], eight: [], nine: [], ten: [],
        eleven: [], twelve: [], thirteen: [], fourteen: [], fifteen: [],
        sixteen: [], seventeen: [], eighteen: [], nineteen: [], twenty: [],
        twentyone: [], twentytwo: [], twentythree: [], twentyfour: []
    )
}

// ✅ TimeTableInfo構造もそのまま
struct TimeTableInfo: Codable {
    let via: String
    let min: String
    let busStop: String
}
```

## 4. NextBus.swift（最小限修正）
```swift
import Foundation
import SwiftData

@Model
final class NextBus {
    // 🆕 SwiftData用のID（既存のUUIDとは別）
    @Attribute(.unique) var persistentID: UUID = UUID()

    // ✅ 既存構造完全維持
    var id: UUID = UUID()  // バックエンド用ID
    var moreMin: String
    var realArrivalTime: String
    var direction: String
    var via: String
    var scheduledTime: String
    var delay: String
    var busStop: String
    var requiredTime: Int

    // 既存のCodingKeysもそのまま維持
    enum CodingKeys: String, CodingKey {
        case moreMin, realArrivalTime, direction, via,
             scheduledTime, delay, busStop, requiredTime
    }

    init(id: UUID, moreMin: String, realArrivalTime: String, direction: String,
         via: String, scheduledTime: String, delay: String, busStop: String, requiredTime: Int) {
        self.id = id
        self.moreMin = moreMin
        self.realArrivalTime = realArrivalTime
        self.direction = direction
        self.via = via
        self.scheduledTime = scheduledTime
        self.delay = delay
        self.busStop = busStop
        self.requiredTime = requiredTime
    }
}
```

## 5. ApproachInfo.swift（最小限修正）
```swift
import Foundation
import SwiftData

@Model
final class ApproachInfo {
    // 🆕 SwiftData用のID
    @Attribute(.unique) var persistentID: UUID = UUID()

    // ✅ 既存構造そのまま維持
    @Relationship(deleteRule: .cascade) var approachInfos: [NextBus]

    init(approachInfos: [NextBus]) {
        self.approachInfos = approachInfos
    }
}
```

## 6. App.swift（変更なし）
```swift
// ✅ 既存のmodelContainer設定そのまま使用可能
.modelContainer(for: [BusStop.self, Route.self, TimeTable.self, NextBus.self, ApproachInfo.self])
```

## 🔄 バックエンドとの互換性維持方法

### API Response → SwiftData
```swift
// 例：バックエンドからのTimeTable取得
let apiResponse: TimeTableAPIResponse = try await fetchFromAPI()

// 既存構造そのまま使用
let timeTable = TimeTable(
    weekdays: apiResponse.weekdays,
    saturdays: apiResponse.saturdays,
    holidays: apiResponse.holidays
)

// SwiftDataに保存
modelContext.insert(timeTable)
```

### SwiftData → API Request
```swift
// SwiftDataから取得
let timeTable = try modelContext.fetch(FetchDescriptor<TimeTable>()).first

// 既存構造そのまま使用してAPIに送信
let apiRequest = TimeTableAPIRequest(
    weekdays: timeTable?.weekdays,
    saturdays: timeTable?.saturdays,
    holidays: timeTable?.holidays
)
```

## ✅ この修正のメリット

1. **🔒 API互換性**: バックエンド構造100%維持
2. **⚡ 最小限変更**: persistentIDとData保存のみ追加
3. **🔧 SwiftData対応**: @Query、リレーションシップが使用可能
4. **📱 既存コード**: ViewModelやAPIコードの変更最小限

## ⚠️ 注意事項

1. **複雑struct**: TimeListは内部的にData保存、使用時は透過的に変換
2. **パフォーマンス**: 大きなTimeTableのエンコード/デコードに若干のオーバーヘッド
3. **マイグレーション**: 既存データの移行方法検討必要
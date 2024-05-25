import SwiftUI

struct TimeTableParts: View{
    let hour: Int
    let timeTableInfo: [TimeTableInfo]
    var body: some View{
        VStack {
            Text("\(hour)時")
                .frame(maxWidth: .infinity, alignment: .leading)
            VStack {
                ForEach(0 ..< timeTableInfo.count, id: \.self) { index in
                    HStack {
                        Text(timeTableInfo[index].min)
                            .padding(.trailing, 15)
                            .font(.system(.caption, design: .monospaced))
                        Text(timeTableInfo[index].via)
                            .font(.system(.caption, design: .rounded))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 45)
                }
                .listRowSeparatorTint(Color.white)
            }
        }
    }
}

#Preview {
    TimeTableParts(hour: 10, timeTableInfo: TimeTableInfo.demo)
}

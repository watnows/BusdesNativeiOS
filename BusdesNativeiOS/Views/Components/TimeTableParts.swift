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
                        Text("\(hour):\(timeTableInfo[index].min)")
                            .padding(.trailing, 10)
                            .font(.callout)
                        Text(timeTableInfo[index].via)
                            .font(.callout)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 45)
                }
                .listRowSeparatorTint(Color.appGray)
            }
        }
        .foregroundColor(.black)
    }
}

//
//  SetGoalView.swift
//  BusdesNativeiOS
//
//  Created by 黒川龍之介 on 2024/04/30.
//

import SwiftUI

struct SetGoalView: View {
    var body: some View {
        VStack {
            Text("どちらでバスを降りますか？")
            HStack {
                Button {
                    MenuView()
                } label: {
                    Text("南草津駅")
                }
                Button {
                    MenuView()
                } label: {
                    Text("立命館大学")
                }
            }
            Button {
                MenuView()
            } label: {
                Text("決定")
            }
            Button {
                MenuView()
            } label: {
                Text("戻る")
            }
        }
    }
}

#Preview {
    SetGoalView()
}

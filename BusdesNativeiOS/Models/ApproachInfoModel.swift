//
//  ApproachInfo.swift
//  BusdesNativeiOS
//
//  Created by Ryunosuke Kurokawa on 2025/09/15.
//


import Foundation
import SwiftData

@Model
final class ApproachInfo {
    var approachInfos: [NextBusModel]
    
    init(approachInfos: [NextBusModel]) {
        self.approachInfos = approachInfos
    }
}
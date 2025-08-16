//
//  TotalActivityReport.swift
//  Device Activity Report
//
//  Created by Daniel Ye on 2025-08-02.
//

import DeviceActivity
import SwiftUI

extension DeviceActivityReport.Context {
    // If your app initializes a DeviceActivityReport with this context, then the system will use
    // your extension's corresponding DeviceActivityReportScene to render the contents of the
    // report.
    static let totalActivity = Self("Total Activity")
}

struct TotalActivityReport: DeviceActivityReportScene {
    // Define which context your scene will represent.
    let context: DeviceActivityReport.Context = .totalActivity
    
    // Define the custom configuration and the resulting view for this report.
    let content: (String) -> TotalActivityView
    
    static let userDefaultsKey = "app-group-test"
    static let suiteName = "group.notifications.io.kd.shutuptimer.shared"
    
    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> String {
        // Reformat the data into a configuration that can be used to create
        // the report's view.
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .dropAll
        
        let totalActivityDuration = await data.flatMap { $0.activitySegments }.reduce(0, {
            $0 + $1.totalActivityDuration
        })

        if let sharedDefault = UserDefaults(suiteName: TotalActivityReport.suiteName) {
            sharedDefault.set(formatter.string(from: totalActivityDuration) ?? "No activity data", forKey: TotalActivityReport.userDefaultsKey)
        }
        return formatter.string(from: totalActivityDuration) ?? "No activity data"
    }
}

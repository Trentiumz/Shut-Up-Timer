//
//  Device_Activity_Report.swift
//  Device Activity Report
//
//  Created by Daniel Ye on 2025-08-02.
//

import DeviceActivity
import SwiftUI

@main
struct Device_Activity_Report: DeviceActivityReportExtension {
    var body: some DeviceActivityReportScene {
        // Create a report for each DeviceActivityReport.Context that your app supports.
        TotalActivityReport { totalActivity in
            TotalActivityView(totalActivity: totalActivity)
        }
        // Add more reports here...
    }
}

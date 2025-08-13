//
//  Procrastination_Countdown_ActivityLiveActivity.swift
//  Procrastination Countdown Activity
//
//  Created by Daniel Ye on 2025-08-12.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct Procrastination_Countdown_ActivityLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: Procrastination_Countdown_ActivityAttributes.self) { context in
            // Timing and progress
            let start = context.attributes.startTime
            let end = context.attributes.startTime.addingTimeInterval(context.attributes.duration)
            let now = Date()
            let duration = max(context.attributes.duration, 1)
            let progress = max(0, min(1, now.timeIntervalSince(start) / duration))
            
            // UI constants (kept small to suit lock screen height, scale via Dynamic Type if needed)
            let barHeight: CGFloat = 8
            let titleSize: CGFloat = 36
            let roastSize: CGFloat = 18
            
            ZStack {
                // Background card
                RoundedRectangle(cornerRadius: 2)
                    .fill(ColorTokens.gray1000)
                
                VStack(spacing: 8) {
                    // Header row
                    HStack() {
                        Image(uiImage: FormattedImages.Image164)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        
                        Spacer()
                        
                        VStack {
                            Text("Patience Level")
                                .font(FontTokens.architectsDaughter(size: titleSize))
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                                .padding(.horizontal)
                            Text(context.state.curRoast)
                                .font(FontTokens.architectsDaughter(size: roastSize))
                                .foregroundColor(.white)
                                .lineLimit(3)
                                .minimumScaleFactor(0.7)
                                .padding(.horizontal)
                        }
                        
                        Spacer()
                    }
                    
                    // Progress bar
                    HStack {
                        Text(timeString(from: start))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.white.opacity(0.25))
                                .frame(height: barHeight)
                            
                            // Fill scaled by progress without GeometryReader
                            Capsule()
                                .fill(Color(red: 0.48, green: 0.12, blue: 0.12))
                                .frame(height: barHeight)
                                .scaleEffect(x: progress, y: 1, anchor: .leading)
                                .animation(.easeInOut(duration: 0.2), value: progress)
                            
                            // Subtle indicator cap
                            Capsule()
                                .fill(Color.white.opacity(0.7))
                                .frame(width: 4, height: barHeight)
                                .overlay(Color.clear)
                                .scaleEffect(x: 1, y: 1, anchor: .leading)
                                .overlay(
                                    Capsule().fill(Color.clear)
                                )
                                .mask(
                                    HStack { Spacer(); Rectangle().frame(width: 4) }
                                )
                                .scaleEffect(x: progress, y: 1, anchor: .leading)
                        }
                        Text(timeString(from: end))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            }
            .activityBackgroundTint(Color.clear)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded
                DynamicIslandExpandedRegion(.center) {
                    VStack(spacing: 6) {
                        Text("Patience Level")
                            .font(FontTokens.architectsDaughter(size: 22))
                            .foregroundColor(.white)
                        Text(context.state.curRoast)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.85))
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                    }
                }
            } compactLeading: {
                Image(systemName: "hourglass")
            } compactTrailing: {
                Text(timeString(from: context.attributes.startTime.addingTimeInterval(context.attributes.duration)))
                    .font(.caption2)
            } minimal: {
                Image(systemName: "timer")
            }
        }
    }
}

// Helper functions
private func timeString(from date: Date) -> String {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    return formatter.string(from: date)
}

extension Procrastination_Countdown_ActivityAttributes {
    fileprivate static var preview: Procrastination_Countdown_ActivityAttributes {
        Procrastination_Countdown_ActivityAttributes(
            startTime: Date(),
            duration: 3600 // 1 hour
        )
    }
}

extension Procrastination_Countdown_ActivityAttributes.ContentState {
    fileprivate static var sampleRoast: Procrastination_Countdown_ActivityAttributes.ContentState {
        Procrastination_Countdown_ActivityAttributes.ContentState(curRoast: "Your procrastination skills are so advanced, you could write a thesis on avoiding work!")
    }
    
    fileprivate static var anotherRoast: Procrastination_Countdown_ActivityAttributes.ContentState {
        Procrastination_Countdown_ActivityAttributes.ContentState(curRoast: "Breaking news: You've discovered a new way to waste time!")
    }
}

@available(iOS 16.1, *)
struct Procrastination_Countdown_ActivityLiveActivity_Previews: PreviewProvider {
    static let attributes = Procrastination_Countdown_ActivityAttributes(
        startTime: Date(),
        duration: 1800 // 30 minutes
    )
    
    static let contentState = Procrastination_Countdown_ActivityAttributes.ContentState(
        curRoast: "Your procrastination skills are so advanced, you could write a thesis on avoiding work!"
    )
    
    static var previews: some View {
        attributes
            .previewContext(contentState, viewKind: .content)
            .previewDisplayName("Notification")
        
        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.compact))
            .previewDisplayName("Compact")
        
        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.expanded))
            .previewDisplayName("Expanded")
        
        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.minimal))
            .previewDisplayName("Minimal")
    }
}

//
//  FFIPWidget.swift
//  FFIPWidget
//
//  Created by mini on 7/17/25.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let entry = SimpleEntry(date: Date())
        completion(Timeline(entries: [entry], policy: .never))
//        var entries: [SimpleEntry] = []
//        
//        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
//        let currentDate = Date()
//        for hourOffset in 0 ..< 5 {
//            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
//            let entry = SimpleEntry(date: entryDate)
//            entries.append(entry)
//        }
//        
//        let timeline = Timeline(entries: entries, policy: .atEnd)
//        completion(timeline)
    }
    
    //    func relevances() async -> WidgetRelevances<Void> {
    //        // Generate a list containing the contexts this widget is relevant in.
    //    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

enum FfipWidgetType: String {
    case designated = "지정탐색"
    case related = "연관탐색"
}

struct FFIPWidgetEntryView: View {
    let widgetType: FfipWidgetType
    
    var body: some View {
        VStack(spacing: 13) {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 100)
                    .fill(.ffipGrayscale5)
                    .frame(height: 55)
                
                Image(.ffipWidgetLogo)
                    .padding(.leading, 16)
            }
            
            HStack(spacing: 14) {
                VStack(alignment: .leading) {
                    HStack(spacing: 4) {
                        Text(.appName)
                        Image(.icnAImark)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 12)
                            .opacity(widgetType == .related ? 1 : 0)
                    }
                    Text(widgetType.rawValue)
                }
                .font(.widgetSemiBold16)
                .foregroundStyle(.ffipGrayscale2)
                
                Image(.icnSettingsVoice)
                    .tint(.ffipGrayscale1)
                    .frame(width: 55, height: 55)
                    .background(Circle().fill(.ffipGrayscale5))
            }
            .containerRelativeFrame([.horizontal])
        }
        .padding(.horizontal, 10)
        .containerRelativeFrame(.horizontal)
        .containerBackground(.ffipBackground1Main, for: .widget)
    }
}

struct FFIPDesignatedSearchWidget: Widget {
    let kind: String = "FFIPDesignatedSearchWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                FFIPWidgetEntryView(widgetType: .designated)
            } else {
                FFIPWidgetEntryView(widgetType: .designated)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName(String(localized: .designatedSearchWidgetConfigurationDisplayName))
        .description(String(localized: .designatedSearchWidgetDescription))
        .supportedFamilies([.systemSmall])
    }
}

struct FFIPRelatedSearchWidget: Widget {
    let kind: String = "FFIPRelatedSearchWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            FFIPWidgetEntryView(widgetType: .related)
        }
        .configurationDisplayName(String(localized: .relatedSearchWidgetConfigurationDisplayName))
        .description(String(localized: .relatedSearchWidgetDescription))
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    FFIPDesignatedSearchWidget()
} timeline: {
    SimpleEntry(date: .now)
}

#Preview(as: .systemSmall) {
    FFIPRelatedSearchWidget()
} timeline: {
    SimpleEntry(date: .now)
}

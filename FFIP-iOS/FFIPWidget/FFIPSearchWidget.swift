//
//  FFIPWidget.swift
//  FFIPWidget
//
//  Created by mini on 7/17/25.
//

import SwiftUI
import WidgetKit

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(
        in context: Context,
        completion: @escaping (SimpleEntry) -> Void
    ) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<Entry>) -> Void
    ) {
        let entry = SimpleEntry(date: Date())
        completion(Timeline(entries: [entry], policy: .never))
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

enum FfipWidgetType: String {
    case exactSearch = "지정탐색"
    case semanticSearch = "연관탐색"
}

struct FFIPWidgetEntryView: View {
    let widgetType: FfipWidgetType

    var body: some View {
        VStack(spacing: 13) {
            Link(
                destination: URL(
                    string:
                        widgetType == .exactSearch
                        ? URLLiterals.DeepLink.searchExact
                        : URLLiterals.DeepLink.searchSemantic
                )!
            ) {
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 100)
                        .fill(.ffipGrayscale5)
                        .frame(height: 55)

                    Image(.ffipWidgetLogo)
                        .padding(.leading, 16)
                }
            }

            HStack(spacing: 14) {
                VStack(alignment: .leading) {
                    HStack(spacing: 4) {
                        Text(.appName)
                        Image(.icnAImark)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 12)
                            .opacity(widgetType == .semanticSearch ? 1 : 0)
                    }
                    Text(widgetType.rawValue)
                }
                .font(.widgetSemiBold16)
                .foregroundStyle(.ffipGrayscale2)

                Link(
                    destination: URL(
                        string: widgetType == .exactSearch
                            ? URLLiterals.DeepLink.voiceSearchExact
                            : URLLiterals.DeepLink.voiceSearchSemantic
                    )!
                ) {
                    Image(.icnSettingsVoice)
                        .tint(.ffipGrayscale1)
                        .frame(width: 55, height: 55)
                        .background(Circle().fill(.ffipGrayscale5))
                }
            }
            .containerRelativeFrame([.horizontal])
        }
        .padding(.horizontal, 10)
        .containerRelativeFrame(.horizontal)
        .containerBackground(.ffipBackground1Main, for: .widget)
    }
}

struct FFIPExactSearchWidget: Widget {
    let kind: String = "FFIPExactSearchWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { _ in
            FFIPWidgetEntryView(widgetType: .exactSearch)
        }
        .configurationDisplayName(
            String(localized: .designatedSearchWidgetConfigurationDisplayName)
        )
        .description(String(localized: .designatedSearchWidgetDescription))
        .supportedFamilies([.systemSmall])
    }
}

struct FFIPSemanticSearchWidget: Widget {
    let kind: String = "FFIPRelatedSearchWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { _ in
            FFIPWidgetEntryView(widgetType: .semanticSearch)
        }
        .configurationDisplayName(
            String(localized: .relatedSearchWidgetConfigurationDisplayName)
        )
        .description(String(localized: .relatedSearchWidgetDescription))
        .supportedFamilies([.systemSmall])
    }
}

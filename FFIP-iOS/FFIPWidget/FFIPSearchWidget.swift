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

struct FFIPWidgetEntryView: View {
    var body: some View {
        VStack(spacing: 13) {
            Link(destination: URL(string: URLLiterals.DeepLink.searchExact)!) {
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
                    Text("FF!p")
                    Text("지정탐색")
                }
                .font(.widgetSemiBold16)
                .foregroundStyle(.ffipGrayscale2)

                Link(destination: URL(string: URLLiterals.DeepLink.voiceSearchExact)!) {
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
            FFIPWidgetEntryView()
        }
        .configurationDisplayName("지정탐색")
        .description("탐색어가 주변에 있는지 빠르게 찾아보세요.")
        .supportedFamilies([.systemSmall])
    }
}

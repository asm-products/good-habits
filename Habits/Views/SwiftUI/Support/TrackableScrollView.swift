//
//  ScrollView.swift
//  Habits
//
//  Created by Michael Forrest on 07/01/2021.
//  Copyright © 2021 Good To Hear. All rights reserved.
//

import SwiftUI
// https://swiftwithmajid.com/2020/09/24/mastering-scrollview-in-swiftui/
private struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero

    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
        value = nextValue()
    }
}
struct TrackableScrollView<Content: View>: View {
    let axes: Axis.Set
    let showsIndicators: Bool
    let offsetChanged: (CGPoint) -> Void
    let content: Content

    init(
        axes: Axis.Set = .vertical,
        showsIndicators: Bool = true,
        offsetChanged: @escaping (CGPoint) -> Void = { _ in },
        @ViewBuilder content: () -> Content
    ) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        self.offsetChanged = offsetChanged
        self.content = content()
    }
    
    var body: some View {
            SwiftUI.ScrollView(axes, showsIndicators: showsIndicators) {
                GeometryReader { geometry in
                    Color.clear.preference(
                        key: ScrollOffsetPreferenceKey.self,
                        value: geometry.frame(in: .named("scrollView")).origin
                    )
                }.frame(width: 0, height: 0)
                content
            }
            .coordinateSpace(name: "scrollView")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self, perform: offsetChanged)
        }
    
}
struct ScrollView_Previews: PreviewProvider {
    static var previews: some View {
        var offset = CGPoint.zero
        let binding = Binding(get: { offset }, set: { value in
            offset = value
        })
        TrackableScrollView(offsetChanged: { value in
            offset = value
        }){
            Text("\(offset.y ?? 0)")
                .frame(width: 200, height: 1000)
                .background(Color.green)
        }
    }
}

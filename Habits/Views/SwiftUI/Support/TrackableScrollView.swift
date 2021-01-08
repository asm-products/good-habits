//
//  ScrollView.swift
//  Habits
//
//  Created by Michael Forrest on 07/01/2021.
//  Copyright © 2021 Good To Hear. All rights reserved.
//

import SwiftUI

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
}
struct ScrollView_Previews: PreviewProvider {
    static var previews: some View {
        TrackableScrollView()
    }
}

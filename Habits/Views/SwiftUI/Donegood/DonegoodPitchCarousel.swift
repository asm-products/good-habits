//
//  DonegoodPitchCarousel.swift
//  Habits
//
//  Created by Michael Forrest on 17/02/2021.
//  Copyright © 2021 Good To Hear. All rights reserved.
//

import SwiftUI


struct DonegoodPitch:Identifiable{
    var id = UUID()
    let headline: String
    let body: String
}

fileprivate struct PitchCard: View{
    var pitch: DonegoodPitch
    var body: some View{
        HStack(spacing: 20){
            Image(systemName: "checkmark.square").font(.largeTitle)
            VStack(alignment: .leading, spacing: 5){
                Text(pitch.headline).font(.headline)
                Text(pitch.body).fontWeight(.light)
            }
        }
        .padding()
        .foregroundColor(Color(UIColor.darkText))
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2, x: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/, y: 1)
    }
}

@available(iOS 14.0, *)
struct DonegoodPitchCarousel: View {
    let pitches:[DonegoodPitch] = [DonegoodPitch](repeating:
        DonegoodPitch(headline: "Focus", body: "One thing at a time")
                                                  , count: 6)
    var body: some View {
        TabView{
            ForEach(pitches){ pitch in
                PitchCard(pitch: pitch)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        .frame(height: 180)
    }
}

@available(iOS 14.0, *)
struct DonegoodPitchCarousel_Previews: PreviewProvider {
    static var previews: some View {
        DonegoodPitchCarousel()
        PitchCard(pitch: DonegoodPitch(headline: "This is a test pitch", body: "This is test body"))
    }
}

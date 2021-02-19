//
//  YouTubeVideo.swift
//  Habits
//
//  Created by Michael Forrest on 17/02/2021.
//  Copyright © 2021 Good To Hear. All rights reserved.
//

import SwiftUI
import YouTubePlayer

struct YouTubeVideo: UIViewRepresentable {
    typealias UIViewType = YouTubePlayerView
    
    var videoID: String
    
    class Coordinator:NSObject, YouTubePlayerDelegate{
        func playerReady(_ videoPlayer: YouTubePlayerView) {
            videoPlayer.play()
        }
    }
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    func makeUIView(context: Context) -> YouTubePlayerView {
        let view = YouTubePlayerView()
        view.delegate = context.coordinator
        view.loadVideoID(videoID)
        return view
    }
    func updateUIView(_ uiView: YouTubePlayerView, context: Context) {
        
    }
}

struct YouTubeVideo_Previews: PreviewProvider {
    static var previews: some View {
        YouTubeVideo(videoID: "nfWlot6h_JM")
    }
}

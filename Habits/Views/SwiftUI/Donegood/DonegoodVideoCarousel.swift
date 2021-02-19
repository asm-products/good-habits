//
//  DonegoodVideoCarousel.swift
//  Habits
//
//  Created by Michael Forrest on 17/02/2021.
//  Copyright © 2021 Good To Hear. All rights reserved.
//

import SwiftUI

fileprivate struct VideoItem:Identifiable{
    let id: String
    let title: String
    let youtube: String
}

fileprivate struct RowItems:Identifiable{
    let id = UUID()
    let videos: [VideoItem]
}

@available(iOS 14.0, *)
fileprivate struct VideoCard:View{
    var item: VideoItem
    var width: CGFloat
    @State var playingVideo = false
    
    func showVideo(){
        playingVideo = true
    }
    
    var body: some View{
        Button(action: showVideo){
            VStack(spacing: 10){
                Image(systemName: "play.rectangle.fill")
                Text(item.title)
                    .lineLimit(10)
                    .multilineTextAlignment(.center)
                    .font(.caption)
                    .fixedSize(horizontal: false, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                    
            }
            .padding(10)
            .frame(width: max(0,width - 20), height: 76)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white, style: /*@START_MENU_TOKEN@*/StrokeStyle()/*@END_MENU_TOKEN@*/))
            .padding(10)
        }.sheet(isPresented: $playingVideo, content: {
            YouTubeVideo(videoID: item.youtube)
        })
    }
}


@available(iOS 14.0, *)
fileprivate struct VideosRow: View{
    var row: RowItems
    var body: some View{
        GeometryReader{ geom in
            HStack(spacing: 0){
                ForEach(row.videos){ item in
                    VideoCard(item: item, width: geom.size.width / 3)
                }
            }.frame(height: 200)
        }
    }
}

@available(iOS 14.0, *)
struct DonegoodVideoCarousel: View {
    private let rows: [RowItems] = [
        RowItems(videos: [
            VideoItem(id: "coders",title: "Coders", youtube: "qy85CgG4nl0"),
            VideoItem(id: "parents",title: "Parents", youtube: "fZ2N_ubzQ_s"),
            VideoItem(id: "vloggers",title: "vloggers", youtube: "QgALVoch1X4"),
        ]),RowItems(videos: [
            VideoItem(id: "writers",title: "writers", youtube: "wPkpO4H5lqE"),
            VideoItem(id: "selfish",title: "Forgetful People", youtube: "TAmgcLYAR6c"),
            VideoItem(id: "forget",title: "forget", youtube: "Nahyf4mPagY"),
        ]),RowItems(videos: [
            VideoItem(id: "clutter",title: "clutter", youtube: "gid7rG14-Yc"),
            VideoItem(id: "power",title: "power", youtube: "mPlP-9P1mr4"),
        ])
    ]
    var body: some View {
            TabView{
                ForEach(rows){ row in
                    VideosRow(row: row)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .frame(height: 200)
            .overlay(Text("Donegood for...").padding(), alignment: .top)
    }
}
@available(iOS 14.0, *)
struct DonegoodVideoCarousel_Previews: PreviewProvider {
    static var previews: some View {
        DonegoodVideoCarousel()
    }
}

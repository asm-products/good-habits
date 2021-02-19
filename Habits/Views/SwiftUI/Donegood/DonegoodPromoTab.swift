//
//  DonegoodPromoTab.swift
//  Habits
//
//  Created by Michael Forrest on 17/02/2021.
//  Copyright © 2021 Good To Hear. All rights reserved.
//

import SwiftUI

struct DonegoodColors{
    static let green = Color(hex: "51A387")
}


@available(iOS 14.0, *)
fileprivate struct TopBanner: View{
    func launchDonegood(){
        UIApplication.shared.open(URL(string: "https://donegood.app?ct=habits")!, options: [:], completionHandler: nil)
        UserDefaults.standard.setValue(true, forKey: DonegoodRegisterButtonHasBeenPressedKey)
        NotificationCenter.default.post(name: DonegoodRegisterButtonHasBeenPressedNotificationName, object: nil)
    }
    var body: some View{
        HStack{
            Text("Donegood").font(.system(.largeTitle, design: .rounded)).bold()
            Spacer()
            Button(action: launchDonegood){
                Text("REGISTER FREE")
                    .font(.system(.body, design: .rounded))
                    .bold()
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

@available(iOS 14.0, *)
struct DonegoodPromoTab: View {
    var body: some View {
        VStack{
            TopBanner()
            Spacer()
            DonegoodPitchCarousel()
            Spacer()
            DonegoodVideoCarousel()
        }
        .foregroundColor(.white)
        .font(.system(.body, design: .rounded))
        .background(DonegoodColors.green.edgesIgnoringSafeArea(.all))
    }
}


@available(iOS 14.0, *)
struct DonegoodPromoTab_Previews: PreviewProvider {
    static var previews: some View {
        DonegoodPromoTab()
    }
}

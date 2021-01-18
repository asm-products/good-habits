//
//  StatsAndTrendsPurchaseView.swift
//  Habits
//
//  Created by Michael Forrest on 14/01/2021.
//  Copyright © 2021 Good To Hear. All rights reserved.
//

import SwiftUI
import StoreKit
import AVKit

struct VideoPlayer: UIViewControllerRepresentable{
    typealias UIViewControllerType = AVPlayerViewController
    
    var filename: String
    class Coordinator: NSObject{
        var looper: AVPlayerLooper?
    }
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let url = Bundle.main.url(forResource: filename, withExtension: "")!
        let result = AVPlayerViewController()
        let asset = AVAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        let player = AVQueuePlayer(playerItem: item)
        context.coordinator.looper = AVPlayerLooper(player: player, templateItem: item)
        result.player = player
        player.play()
        result.showsPlaybackControls = false
        result.view.backgroundColor = .systemBackground
        return result
    }
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
    }
}

class PriceFetcher: NSObject, SKProductsRequestDelegate{
    @Binding var product: SKProduct?
    @Binding var buyButtonText: String?
    let request = SKProductsRequest(productIdentifiers: ["statistics"])
    init(product: Binding<SKProduct?>, price: Binding<String?>){
        _product = product
        _buyButtonText = price
        super.init()
        request.delegate = self
        request.start()
    }
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async { [self] in
            if let product = response.products.first{
                updatePrice(product: product)
            }
        }
    }
    func request(_ request: SKRequest, didFailWithError error: Error) {
        DispatchQueue.main.async { [self] in
            buyButtonText = error.localizedDescription
        }
    }
    func updatePrice(product: SKProduct){
        self.product = product
        let formatter = NumberFormatter()
        formatter.formatterBehavior = .behavior10_4
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale
        if let priceString = formatter.string(from: product.price){
            buyButtonText = "Unlock Now (\(priceString))"
        }
    }
}

struct BigButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}

@available(iOS 14.0, *)
public struct StatsAndTrendsPurchaseView: View {
    @State var currentPage: Int = 1
    @State var buyButtonText: String?
    @State var product: SKProduct?
    @State var priceFetcher: PriceFetcher?
    var dismiss: (()->Void)?
    
    func fetchPrice(){
        guard AppFeatures.statsEnabled() != true else {
            buyButtonText = "Done"
            return
        }
        priceFetcher = PriceFetcher(product: $product, price: $buyButtonText)
    }
    func startPurchase(){
        if AppFeatures.statsEnabled(){
            dismiss?()
            return;
        }
        guard let product = product else { return }
        let payment = SKMutablePayment(product: product)
        payment.quantity = 1
        SKPaymentQueue.default().add(payment)
        dismiss?()
    }
    func restorePurchase(){
        SKPaymentQueue.default().restoreCompletedTransactions()
        dismiss?()
    }
    public var body: some View {
        VStack{
            Text("Premium Features").font(.headline).padding(.top)
            TabView(selection: $currentPage){
                VStack(alignment: .leading, spacing: 20){
                    VideoPlayer(filename: "Habits-Trends.mp4")
                        .aspectRatio(1, contentMode: .fit)
                    Text("The Trends tab lets you see how well you did each month.")
                    Text("See your percentage success rate for each habit, and when you broke the chain.")
                    Spacer()
                }
                .padding()
                .tag(1)
                VStack(alignment: .leading, spacing: 20){
                    VideoPlayer(filename: "Habits-What Happened.mov").aspectRatio(1, contentMode: .fit)
                    Text("No Excuses.").font(.headline)
                    Text("What's keeping you from staying on track?")
                    Text("If something unexpected made you break your chain, get better-prepared for next time.")
                    Spacer()
                }
                .padding()
                .tag(2)
                VStack(alignment: .leading, spacing: 20){
                    HStack{
                        Spacer()
                        Image("michael-circle")
                        Spacer()
                    }
                    Text("Hi!").font(.largeTitle)
                    Text("I'm Michael and I built this app.")
                    Text("I'd like to be able to keep working on my own apps full-time.")
                    Text("Your purchase would really help!")
                }
                .padding()
                .tag(3)
                if AppFeatures.statsEnabled() == false {
                    VStack{
                        Text("Good Habits Premium").italic()
                        Text("One-Off Purchase").font(.largeTitle).padding()
                        Text("No subscription. Use forever.").padding()

                        Button(action: startPurchase){
                            Text(buyButtonText ?? "Fetching price...")
                                .bold()
                        }
                        .disabled(buyButtonText == nil)
                       
                        Button(action: restorePurchase){ Text("Restore Purchase") }.buttonStyle(PlainButtonStyle()).padding().opacity(0.6)
                        
                    }.tag(4)
                }
            }
            
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            Spacer()
            
            Divider()
            if(currentPage < 4){
                Button(action: {
                    withAnimation {
                        currentPage = min(4, currentPage + 1)
                    }
                }){
                    Text("Next").bold()
                }
            }
        }
        .buttonStyle(BigButton())
        .overlay(dismiss == nil ? nil : Button(action: dismiss!){
            Image(systemName: "xmark").padding()
        },alignment: .topTrailing)
        .accentColor(.gray)
        .onAppear(perform: fetchPrice)
    }
}

@available(iOS 14.0, *)
final class StatsAndTrendsPurchaseViewControllerWrapper: UIHostingController<StatsAndTrendsPurchaseView>{
    required init() {
        super.init(rootView: StatsAndTrendsPurchaseView())
        rootView.dismiss = dismiss
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func dismiss(){
        dismiss(animated: true, completion: nil)
    }
}

@available(iOS 14.0, *)
@objc class StatsAndTrendsPurchaseInterface: NSObject{
    @objc static func createAlert()->UIViewController{
       StatsAndTrendsPurchaseViewControllerWrapper()
    }
}

@available(iOS 14.0, *)
struct StatsAndTrendsPurchaseView_Previews: PreviewProvider {
    static var previews: some View {
//        VStack{
//            Spacer()
//            HStack{
//                Spacer()
//            }
//        }
//        .background(Color.blue)
//        .sheet(isPresented: Binding.constant(true) ){
        StatsAndTrendsPurchaseView(dismiss: {})
//        }
    }
}

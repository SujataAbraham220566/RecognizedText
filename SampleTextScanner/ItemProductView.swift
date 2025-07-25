//
//  ItemProductView.swift
//  SampleTextScanner
//
//  Created by Sujata Abraham on 23/06/25.
//  Copyright © 2025 Apple. All rights reserved.
//

import Foundation
import SwiftUI
import AVKit
import AVFoundation
//import CloudKit
//import CoreData
import StoreKit
import OSLog

private let logger = Logger.init(subsystem: "SampleTextScanner", category: "HomeView")

extension ItemProductView.ItemViewModel: Identifiable {
    public var id: String { product.displayName }
}

struct ItemProductView: View {
    //let id: String
    //let name: String
    @State var name = ""
    
    struct ItemViewModel {
        let product: Product
        //let imageName: String
        let isPurchased: Bool
    }
    
    @StateObject var storeKitManager = StoreKitManager()
    @State var items: [ItemViewModel]?
    @State var purchase = 0
    @State private var isPurchasing = false
    @State private var purchaseError: String?
    @State var imagePic = UIImage()
    @State var speed = 50.0
    @State var pitch = 50.0
    @State var volume = 50.0
    @State var webUrl = ""
    //let moc: ManagedObjectContext
    //var storeKitManager = StoreKitManager()
    
    let productImageMap: [String: String] =
    ["com.RecognizeTextToAudio.OnePageOneWeek": "camera",
     "com.RecognizeTextToAudio.OnePageOneYear": "camera",
     "com.RecognizeTextToAudio.RecognizeTextOneWeek": "file",
     "com.RecognizeTextToAudio.RecognizeTextOneYear": "file",
     "com.RecognizeTextToAudio.TextToAudioOneWeek": "speaker",
     "com.RecognizeTextToAudio.TextToAudioOneYear": "speaker",
     "com.RecognizeTextToAudio.Mp4ToTextOneWeek": "file",
     "com.RecognizeTextToAudio.Mp4ToTextOneYear": "file",
     "com.RecognizeTextToAudio.WebToTextOneWeek": "file",
     "com.RecognizeTextToAudio.WebToTextOneYear": "file"
    ]
    //@Environment(\.colorScheme) var colorScheme
    //@Environment(\.dismiss) var dismiss
    //@Environment(\.scenePhase) private var scenePhase
    
    
    var body: some View {
        Group {
            ScrollView {
                NavigationStack {
                    if let items = items {
                        ForEach(items.sorted(by: {$0.id > $1.id})) { item in
                            //print(item.product.displayName, "22")
                            if item.isPurchased {
                                //NavigationLink {
                                NavigationLink(destination: destinationView(for: item)) {
                                    VStack{
                                        Image(productImageMap[item.product.id] ?? "")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                            .scaledToFit()
                                        Text(item.product.displayName)
                                            .foregroundColor(.green)
                                        //Spacer()
                                    }
                                    .frame(width: 250, height: 70)
                                    .border(.black)
                                    .background(.blue)
                                    .cornerRadius(20)
                                }
                                
                            } else {
                                VStack {
                                    Image(productImageMap[item.product.id] ?? "")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .scaledToFit()
                                    Text(item.product.displayName)
                                        .foregroundColor(.white)
                                    //Spacer()
                                    Button {
                                        Task {
                                            let _ = try await storeKitManager.purchase(item.product.id)
                                        }
                                    } label: {
                                        Text(item.product.displayPrice)
                                            .foregroundColor(.red)
                                    }
                                }
                                .frame(width: 250, height: 70)
                                .border(.black)
                                .background(.blue)
                                .cornerRadius(20)
                            }
                        }
                    } else {
                        Text("Loading...")
                    }
                }
                .onChange(of: storeKitManager.productsById) {
                    update()
                }
                .onAppear(){
                    update()
                }
                .onChange(of: storeKitManager.purchasedProducts) {
                    update()
                }
                .cornerRadius(20)
                //.background(.blue)
            }
        }
        //.foreground(.blue)
    }
    func update() {
        //print(storeKitManager.productsById as Any, "1")
        items = storeKitManager.productsById?.values.map {
            ItemViewModel(product: $0, isPurchased: storeKitManager.purchasedProducts?.contains($0) ?? false)
        }
    }
    @ViewBuilder
    func destinationView(for item: ItemViewModel) -> some View {
        switch item.product.displayName {
        case "ScanPage Weekly", "ScanPage Yearly":
            PhotoView()
        case "Import PdfToText Weekly", "Import PdfToText Yearly":
            PdfView()
        case "Import TextToAudio Weekly", "Import TextToAudio Yearly":
            TextAudioView(speed: speed, pitch: pitch, volume: volume)
        case "Import Mp4ToText Weekly", "Import Mp4ToText Yearly":
            Mp3TextView()
        case "Import WebToText Weekly", "Import WebToText Yearly":
            WebTextView(webUrl: $webUrl)
        default:
            EmptyView()
        }
    }
}


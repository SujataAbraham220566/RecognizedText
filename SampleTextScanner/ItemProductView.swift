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
        let isPurchased: Bool
    }
    
    @StateObject var storeKitManager = StoreKitManager()
    @State var items: [ItemViewModel]?
    @State var purchase = 0
    @State private var isPurchasing = false
    @State private var purchaseError: String?
    @State var imagePic = UIImage()
    
    //@State var nextView = PhotoView.self
    //let moc: ManagedObjectContext
    //var storeKitManager = StoreKitManager()
    enum ProductName: String {
        case scanPagePerWeek
        case scanPagePerYear
        case ImportFilesToTextPerWeek
        case ImportFilesToTextPerYear
        case ImportFilesToSpeechPerWeek
        case ImportFilesToSpeechPerYear
    }
    //@Environment(\.colorScheme) var colorScheme
    //@Environment(\.dismiss) var dismiss
    //@Environment(\.scenePhase) private var scenePhase
    
    
    var body: some View {
        Group {
            //ScrollView {
            NavigationStack {
                if let items = items {
                    ForEach(items.sorted(by: {$0.id < $1.id})) { item in
                        //print(item.product.displayName, "22")
                        if item.isPurchased {
                            //NavigationLink {
                            NavigationLink(destination: destinationView(for: item)) {
                                //
                                Text(item.product.displayName)
                            }
                            
                        } else {
                            HStack {
                                Text(item.product.displayName)
                                Spacer()
                                Button {
                                    Task {
                                        let _ = try await storeKitManager.purchase(item.product.id)
                                    }
                                } label: {
                                    Text(item.product.displayPrice)
                                        .padding(10)
                                }
                            }
                        }
                        //}
                        //}
                        /*Text("Course is available for 2 months from purchase")
                         .font(.custom("Borel-Regular", size: 20))    //(Font.headline)
                         .bold()
                         .foregroundColor(Color.red)
                         */
                        /*} else {
                         Text("Loading...")*/
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
            //}
            //.background(.blue)
        }
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
        case "1. ScanPage / Week", "2. ScanPage / Year":
            //var imagePic = Image(systemName: camera.fill)
            PhotoView()
        case "3. ImportFilesToText / Week", "4. ImportFilesToText / Year":
            //var imagePic = Image(systemName: doc.fill)
            PdfView()
        case "5. ImportFilesToSpeech / Week", "6. ImportFilesToSpeech / Year":
            //var imagePic = Image(systemName: speaker.fill)
            TextAudioView()
        default:
            EmptyView()
        }
    }
}

        /*Group {
         VStack {
         NavigationLink(destination: PhotoView()) {
         Text("Take Photo")
         }
         }
         .foregroundColor(.red)
         .font(.title)
         
         Spacer(minLength: 1)
         
         VStack {
         NavigationLink(destination: PdfView()){
         Text("Upload PDF")
         }
         }
         .foregroundColor(.red)
         .font(.title)
         
         Spacer(minLength: 1)
         
         VStack {
         NavigationLink(destination: TextAudioView()) {
         Text("TextToAudio")
         }
         }
         .foregroundColor(.red)
         .font(.title)
         
         Spacer(minLength: 30)
         //let _ = print("courses: \(courses)")
         //let _ = print("chapters: \(chapters)")
         //let _ = print("id: \(id) course: \(String(describing: courses.first?.id))")
         /*if let course = courses.first {
          let chapters = course.chapters as? Set<Chapter> ?? []
          let _ = print("chapters: \(chapters)")
          List {
          ForEach(chapters.sorted { $0.name! < $1.name! }) { chapter in
          
          let chapterName = chapter.name!
          let _ = print(chapterName)
          NavigationLink {
          ChapterView(name: chapterName)
          
          } label: {
          Text(chapterName)
          }
          }
          }
          .navigationTitle(name)
          
          } else {
          Text("Loading...")
          }*/
         }
         task {
         courses.nsPredicate = .init(format: "id == %@", id)
         }*/
        //.navigationBarTitle(name)
    //}
//}

/*enum LoadingState<T> {
    case error(Error)
    case loading(Double)
    case loaded(T)
}

extension LoadingState {
    func map<U>(_ f: (T) -> U) -> LoadingState<U> {
        switch self {
        case .error(let error): .error(error)
        case .loading(let loading): .loading(loading)
        case .loaded(let item): .loaded(f(item))
        }
    }
}*/

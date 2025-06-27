//
//  StoreKitManager.swift
//  SampleTextScanner
//
//  Created by Sujata Abraham on 22/06/25.
//  Copyright © 2025 Apple. All rights reserved.
//

import Foundation
import StoreKit
import OSLog

private let logger = Logger.init(subsystem: "RecognizeTextToAudio", category: "StoreKitManager")

class StoreKitManager: ObservableObject {
    private var updateTask: Task<Void, Error>? = nil
    private var purchase = false
    
    init() {
        Task { @MainActor in
            productsById = await {
                let products = try! await Product.products(for: Self.productIds())
                return Dictionary(grouping: products) { $0.id }.mapValues { $0.first! }
            }()
            
            await self.updatePurchasedProducts()
            
            updateTask = Task.detached { [weak self] in
                for await _ in Transaction.updates {
                    
                    //guard case .verified(_) = verificationResult else { continue }
                    await self?.updatePurchasedProducts()
                }
            }
        }
    }
    
    // TODO: get this from the public CloudKit
    private static func productIds() async -> [String] {
             ["com.RecognizeTextToAudio.OnePageOneWeek",
              "com.RecognizeTextToAudio.OnePageOneYear",
              "com.RecognizeTextToAudio.RecognizeTextOneWeek",
              "com.RecognizeTextToAudio.RecognizeTextOneYear",
              "com.RecognizeTextToAudio.TextToAudioOneWeek",
              "com.RecognizeTextToAudio.TextToAudioOneYear"]
        }
      
        @MainActor @Published var productsById: [String: Product]?
        @MainActor @Published var purchasedProducts: Set<Product>?
    //        didSet {
    //            purchasedCourses = if let purchasedProducts {
    //                purchasedProducts.map {
    //                }
    //            } else {
    //                nil
    //            }
    //        }
    //    }
       
        @MainActor
        private func updatePurchasedProducts() async {
            var purchasedProducts = Set<Product>()
            
            for await verificationResult in Transaction.currentEntitlements {
                guard case .verified(let transaction) = verificationResult else { continue }
                
                let expiryDate1 = Calendar.current.date(byAdding: .day, value: 7, to: transaction.purchaseDate)
                let expiryDate2 = Calendar.current.date(byAdding: .day, value: 365, to: transaction.purchaseDate)

                //guard Date() < expiryDate! else { continue }
            guard let product = productsById![transaction.productID] else { continue }
            /*guard let purchase = [productsById[transaction.productID]] = 1//"com.RecognizeText.onePageOneWeek" //|| //productsById![transaction.productID] == //"com.RecognizeText.RecognizeTextOneWeek" || //productsById![transaction.productID] == //"com.TextToAudio.TextToAudioOneWeek")
                //&& (Date() < expiryDate1)
                 else { continue }
            if (product == "com.RecognizeText.onePageOneYear" || product == "com.RecognizeText.RecognizeTextOneYear" || product == "com.TextToAudio.TextToAudioOneYear") && (Date() < expiryDate2){
                purchase = true }*/

            //print(product, "Hi")
            purchasedProducts.insert(product)
            await transaction.finish()
        }
        
        self.purchasedProducts = purchasedProducts
    }
    
    deinit {
        updateTask?.cancel()
    }
    
    @MainActor
    func purchase(_ productId: String) async throws -> Transaction? {
        guard let product = productsById![productId] else {
            throw NSError(domain: "bad productId", code: 0xDEAD)
        }
        
        guard case .success(let verificationResult) = try await product.purchase() else {
            return nil
        }
        
        guard case .verified(let transaction) = verificationResult else {
            return nil
        }
        
        return transaction
    }
}

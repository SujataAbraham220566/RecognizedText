//
//  HomeView.swift
//  SampleTextScanner
//
//  Created by Sujata Abraham on 17/06/25.
//  Copyright © 2025 Apple. All rights reserved.
//
import Foundation
import SwiftUI
import AuthenticationServices
import MessageUI
import StoreKit
import OSLog

private let logger = Logger.init(subsystem: "SampleTextScanner", category: "HomeView")

extension HomeView.ItemViewModel: Identifiable {
    public var id: String { product.displayName }
}

struct HomeView: View {
    struct ItemViewModel {
        let product: Product
        let isPurchased: Bool
    }
    
    //@StateObject var storeKitManager = StoreKitManager()
    //@State var items: [ItemViewModel]?
    //@State var purchase = 0
    //@State private var isPurchasing = false
    //@State private var purchaseError: String?

    //@State var nextView = PhotoView.self
    //let moc: ManagedObjectContext
    //var storeKitManager = StoreKitManager()
    enum ProductName: String {
        case onePageOneWeek
        case onePageOneYear
        case recognizeTextOneWeek
        case recognizeTextOneYear
        case textToAudioOneWeek
        case textToAudioOneYear
    }
    
    //@State var email: String = ""
    //@State var firstName: String = ""
    //@State var lastName: String = ""
    //@State var userId: String = ""
    @AppStorage("firstName") var firstName: String = ""
    @AppStorage("lastName") var lastName: String = ""
    @AppStorage("userId") var userId: String = ""
    @AppStorage("email") var email: String = ""
    
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack{
                    Text("Handwriting to Text To Audio")
                        .font(.custom("Borel-Regular", size: 20))    //(Font.headline)
                        .bold()
                        .foregroundColor(Color.purple)
                    //Spacer(minLength: 20)
                    
                    VStack {
                        Spacer(minLength: 5)
                        Text("      Files or Scan              ")
                            .font(.custom("Rubic Doodle shadow", size: 30))
                            .bold()
                            .font(.title)
                        Spacer(minLength: 1)
                        Text("Convert your penned notes to text")
                            .font(.custom("Rubic Doodle shadow", size: 20))
                            //.frame(width: 30, height: 10, alignment: .leading)
                            .background(.white)
                            //.border(.red)
                            //.cornerRadius(10)
                            //.foreground(.red)
                        Spacer(minLength: 5)
                        Text("Convert a pdf file to text       ")
                            .font(.custom("Rubic Doodle shadow", size: 20))
                            //.frame(width: 30, height: 10, alignment: .leading)
                            .background(.white)
                            //.border(.red)
                            //.cornerRadius(10)
                            //.foreground(.blue)
                        Spacer(minLength: 5)
                        Text("  Convert a pdf file to speech   ")
                            .font(.custom("Rubic Doodle shadow", size: 20))
                            //.frame(width: 30, height: 10, alignment: .leading)
                            .background(.white)
                            //.border(.red)
                            //.cornerRadius(10)
                            //.foreground(.blue)
                        Spacer(minLength: 5)
                        Text("  Convert a mp4 file to text     ")
                            .font(.custom("Rubic Doodle shadow", size: 20))
                            //.frame(width: 30, height: 10, alignment: .leading)
                            .background(.white)
                        /*Spacer(minLength: 5)
                        Text("  Convert a web source to text   ")
                            .font(.custom("Rubic Doodle shadow", size: 20))
                            //.frame(width: 30, height: 10, alignment: .leading)
                            .background(.white)
                        */
                        Spacer(minLength: 1)
                    }
                    .frame(width: 300, height: 500, alignment: .leading)
                    .foregroundColor(.purple)
                    //.background(.white)
                    //.Spacer(minLength: 1)
                    .border(Color.purple)
                    //.cornerRadius(10)
                }
                
                Spacer(minLength: 5)
                
                //Spacer(minLength: 1)
                
                //Spacer(minLength: 1)
                VStack{
                    if userId.isEmpty{
                        SignInWithAppleButton(.continue){ request in
                            request.requestedScopes = [.email, .fullName]
                        } onCompletion: { result in
                            logger.log("sign in completion: \(String(describing: result))")
                            switch(result){
                            case .success(let auth):
                                switch auth.credential{
                                case let credential as ASAuthorizationAppleIDCredential:
                                    
                                    let userId = credential.user
                                    let email = credential.email
                                    logger.log("userId \(userId)")
                                    //let email = tempemail!.replacingOccurrences(of: " ", with: "")
                                    let firstName = credential.fullName?.givenName
                                    let lastName = credential.fullName?.familyName
                                    //userAuth.email = email!
                                    self.email = email ?? ""
                                    self.userId = userId
                                    self.firstName = firstName ?? ""
                                    self.lastName = lastName ?? ""
                                    //backupyourdetails()
                                    //self.userId = ""
                                    //self.firstName = ""
                                    //self.lastName = ""
                                    //self.email = ""
                                    //userAuth.email = ""
                                    //userAuth.login()
                                    break
                                default:
                                    exit(0)
                                }
                            case .failure( _):
                                break
                            }
                        }
                        
                    }
                }
                .frame(height: 50)
                .padding()
                .cornerRadius(8)
                .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                Spacer(minLength: 1)
                VStack{
                    NavigationLink(destination: ItemProductView()){
                        Text("Get Started")
                    }
                }
                .foregroundColor(.purple)
                .font(.title)
                Spacer(minLength: 30)
            }
        }
        .background(.white)
    }
    /*func update() {
        //print(storeKitManager.productsById as Any, "1")
        items = storeKitManager.productsById?.values.map {
            ItemViewModel(product: $0, isPurchased: storeKitManager.purchasedProducts?.contains($0) ?? false)
        }
    }*/
}

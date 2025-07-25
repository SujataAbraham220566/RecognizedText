//
//  WebText.swift
//  SampleTextScanner
//
//  Created by Sujata Abraham on 19/07/25.
//  Copyright © 2025 Apple. All rights reserved.
//

import AVFoundation
import SwiftUI
import PDFKit
import Vision
import UniformTypeIdentifiers
import Speech

struct WebTextView: View {
    //@State private var isFileImporterPresented = false
    @State private var plainText: String = ""
    @State private var imageURL: [URL?] = []
    @Binding var webUrl: String
    
    var body: some View {
        VStack(spacing: 20) {
            /*if importedFileContent.isEmpty {
             Text("Imported File Content:")
             .foregroundColor(.gray)
             } else {*/
            TextField("Enter Web Source", text: $webUrl)
            Text("Web File Content")
                .font(.headline)
            // .multilineTextAlignment(.leading)
            ScrollView {
                //TextEditor(text: $importedFileContent)
                Text(plainText.isEmpty ? "no files from web yet." : plainText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
            .frame(height: 300)
            //.border(Color.gray, width: 1)
            
            Button("Convert Web Source to Text") {
                fetchWebSourceAsText(from: webUrl) { plainText in
                    if let plainText = plainText {
                        //plainTextFull += plainText
                        //print("Plain Text:\n\(plainText)")
                    } else {
                        print("Failed to fetch or convert web source.")
                    }
                }
                // isFileImporterPresented = true
                
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
    }
    func fetchWebSourceAsText(from urlString: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data, let htmlString = String(data: data, encoding: .utf8) else {
                print("Failed to decode data")
                completion(nil)
                return
            }
            
            // Convert HTML to plain text
            let plainText = htmlToPlainText(htmlString)
            completion(plainText)
        }
        
        task.resume()
    }

    func htmlToPlainText(_ html: String) -> String? {
        guard let data = html.data(using: .utf8) else { return nil }
        
        do {
            let attributedString = try NSAttributedString(
                data: data,
                options: [.documentType: NSAttributedString.DocumentType.html,
                          .characterEncoding: String.Encoding.utf8.rawValue],
                documentAttributes: nil
            )
            return attributedString.string
        } catch {
            print("Error converting HTML to plain text: \(error.localizedDescription)")
            return nil
        }
    }
}




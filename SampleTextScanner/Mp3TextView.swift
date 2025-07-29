//
//  Mp4Text.swift
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

struct Mp3TextView: View {
    @State private var isFileImporterPresented = false
    @State private var importedFileContent: String = ""
    @State private var imageURL: [URL?] = []
    
    var body: some View {
        VStack(spacing: 20) {
            /*if importedFileContent.isEmpty {
             Text("Imported File Content:")
             .foregroundColor(.gray)
             } else {*/
            Text("Imported File Content")
                .font(.headline)
            // .multilineTextAlignment(.leading)
            ScrollView {
                //TextEditor(text: $importedFileContent)
                Text(importedFileContent.isEmpty ? "no files imported yet." : importedFileContent)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
            .frame(height: 300)
            //.border(Color.gray, width: 1)
            
            Button("Import File") {
                isFileImporterPresented = true
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
        .fileImporter(
            isPresented: $isFileImporterPresented,
            allowedContentTypes: [.audio, .video],
            allowsMultipleSelection: false
        ) { result in
            print("hey z")
                /*do {
                guard let selectedFile = try result.get().first else { return }

                if selectedFile.startAccessingSecurityScopedResource() {
                    defer { selectedFile.stopAccessingSecurityScopedResource() }

                    let coordinator = NSFileCoordinator()
                    var coordError: NSError?

                    coordinator.coordinate(readingItemAt: selectedFile, options: [], error: &coordError) { result in
                            // ✅ Now safe to read
                        transcribeAudio(result: result)
                    }
                }
            } catch {
                print("File import failed: \(error)")
            }*/

            transcribeAudio(result: result)
            //let images = convertPDFToImages(result: result)
            //handleFileImport(imageURL: images!)
            //handleFileImport(result: result)
            //print(importedFileContent, "9", result, "8", "result")
        }
    }
    
    func transcribeAudio(result: Result<[URL], Error>){
        do {
            print("1 hi")
            guard let mp3URL = try! result.get().first else {
            importedFileContent = "Could not open the file."
            return
            }
        //print(pdfURL, "331")
            /*guard
                let mp3Document = PDFDocument(url: mp3URL)
                  else {
                importedFileContent = "Could not open the file."
                //return nil
            }*/
            let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
            let recognitionRequest = SFSpeechURLRecognitionRequest(url: mp3URL)
            guard let recognizer = speechRecognizer, recognizer.isAvailable else {
                print("Speech recognizer is not available")
                return
            }
            print("2 hi")
            recognizer.supportsOnDeviceRecognition = true
            recognitionRequest.requiresOnDeviceRecognition = true

            let request = SFSpeechURLRecognitionRequest(url: mp3URL)
            recognizer.recognitionTask(with: request){ result, error in
                if let error = error {
                    print("Error during transcription : \(error.localizedDescription)")
                } else if let result = result {
                    importedFileContent += result.bestTranscription.formattedString
                }
            }
            print("3 hi")
        } catch {
        importedFileContent = "Error reading mp3: \(error.localizedDescription)"
        //return nil
    }


    }
    func handleFileImport(imageURL: [UIImage?]) {
        //private func handleFileImport(result: Result<[URL], Error>){
        //do {
        //let imageURL = try! result.get()
        //let image = UIImage(named: "quote")
        
        //if let cgImage = imageURL.first??.cgImage{
        //if let cgImage = imageURL.first??.cgImage{
        // Request handler
        for (i, imageOpt) in imageURL.enumerated() {
            //Image(uiImage: imageURL[i])
            //  .resizable()
            //.scaledToFit()
            //.padding()
            guard let uiImage = imageOpt, let cgImage = uiImage.cgImage else {
                print("Skipping nil image at index \(i)")
                continue
            }
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            let recognizeRequest = VNRecognizeTextRequest { (request, error) in
                if let error = error {
                    print("Recognition error: \(i): ", error.localizedDescription)
                    return
                }
                // Parse the results as text
                guard let result = request.results as? [VNRecognizedTextObservation] else {
                    print("No text found in image at index \(i)")
                    return
                }
                
                // Extract the data
                let stringArray = result.compactMap { result in
                    result.topCandidates(1).first?.string
                }
                
                // Update the UI
                DispatchQueue.main.async {
                    importedFileContent += stringArray.joined(separator: "\n")
                }
            }
            
            // Process the request
            recognizeRequest.recognitionLevel = .accurate
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try handler.perform([recognizeRequest])
                } catch {
                    print(error)
                }
            }
        }
    }
    
    
    //PDF to Image
    
    func convertPDFToImages(result: Result<[URL], Error>) -> [UIImage]?{
        do {/*
             guard let pdfURL = try result.get().first,
             let pdfDocument = PDFDocument(url: pdfURL) else {
             importedFileContent = "Could not open the file."
             return nil
             }*/
            guard let pdfURL = try result.get().first else {
                importedFileContent = "Could not open the file."
                return nil
            }
            //print(pdfURL, "331")
            guard let pdfDocument = PDFDocument(url: pdfURL) else {
                importedFileContent = "Could not open the file."
                return nil
            }
            //print(pdfDocument, "332")
            var images: [UIImage] = []
            
            for pageNum in 0..<pdfDocument.pageCount {
                if let pdfPage = pdfDocument.page(at: pageNum) {
                    let pdfPageSize = pdfPage.bounds(for: .mediaBox)
                    let renderer = UIGraphicsImageRenderer(size: pdfPageSize.size)
                    
                    let image = renderer.image { ctx in
                        UIColor.white.set()
                        ctx.fill(pdfPageSize)
                        ctx.cgContext.translateBy(x: 0.0, y: pdfPageSize.size.height)
                        ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
                        
                        pdfPage.draw(with: .mediaBox, to: ctx.cgContext)
                    }
                    
                    images.append(image)
                }
            }
            
            return images
        } catch {
            importedFileContent = "Error reading PDF: \(error.localizedDescription)"
            return nil
        }
    }
    
}

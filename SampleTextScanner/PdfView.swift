//
//  PdfView.swift
//  SampleTextScanner
//
//  Created by Sujata Abraham on 17/06/25.
//  Copyright © 2025 Apple. All rights reserved.
//


import AVFoundation
import SwiftUI
import PDFKit
import Vision
import UniformTypeIdentifiers

struct PdfView: View {
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
            allowedContentTypes: [.image, .plainText, .pdf],
            allowsMultipleSelection: false
        ) { result in
            let imageURL = convertPDFToImages(result: result)
            handleFileImport(imageURL: imageURL!)
            //handleFileImport(result: result)
            print(importedFileContent, "9", result, "8", "result")
        }
    }
    
    func handleFileImport(imageURL: [UIImage?]) {
    //private func handleFileImport(result: Result<[URL], Error>){
        //do {
        //let imageURL = try! result.get()
        //let image = UIImage(named: "quote")
        
            //if let cgImage = imageURL.first??.cgImage{
        if let cgImage = imageURL.first??.cgImage{
            // Request handler
            let handler = VNImageRequestHandler(cgImage: cgImage)
            
            let recognizeRequest = VNRecognizeTextRequest { (request, error) in
                
                // Parse the results as text
                guard let result = request.results as? [VNRecognizedTextObservation] else {
                    return
                }
                
                // Extract the data
                let stringArray = result.compactMap { result in
                    result.topCandidates(1).first?.string
                }
                
                // Update the UI
                DispatchQueue.main.async {
                    importedFileContent = stringArray.joined(separator: "\n")
                }
            }
            
            // Process the request
            recognizeRequest.recognitionLevel = .accurate
            do {
                try handler.perform([recognizeRequest])
            } catch {
                print(error)
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


//
//  TextAudio.swift
//  SampleTextScanner
//
//  Created by Sujata Abraham on 22/06/25.
//  Copyright © 2025 Apple. All rights reserved.
//

import SwiftUI
import AVFoundation
import PDFKit
import Vision
import UniformTypeIdentifiers

struct TextAudioView: View {
    @State private var inputText: String = ""
    //private let speechSynthesizer = AVSpeechSynthesizer()
    @State private var isFileImporterPresented = false
    @State private var showVoiceSheet = false
    @StateObject private var speechManager = SpeechManager()
    @State private var importedFileContent: String = ""
    @State private var imageURL: [URL?] = []
    @State var speed: Double
    @State var pitch : Double
    @State var volume : Double

    var body: some View {
        VStack(spacing: 20) {
            /*Text("Text to Audio")
             .font(.largeTitle)
             .bold()
             */
            /*if importedFileContent.isEmpty {
             Text("Imported File Content:")
             .foregroundColor(.gray)
             } else {*/
            ScrollView{
                Text(speechManager.highlightedText)
                    .font(.title2)
                    .padding()
            }
            Text("Imported File Content")
                .font(.headline)
            // .multilineTextAlignment(.leading)
            ScrollView {
                //TextEditor(text: $importedFileContent)
                Text(importedFileContent.isEmpty ? "no files imported yet." :     importedFileContent)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
            .frame(height: 300)
            //.border(Color.gray, width: 1)
            /*Text(speechManager.highlightedText)
                .font(.title2)
                .foregroundColor(.yellow)*/
            Button{
                speechManager.speakText(text: importedFileContent)
            } label: {
                HStack{
                    Image(systemName: "microphone.fill")
                        .imageScale(.large)
                        .foregroundStyle(.tint)
                    Text("Play Audio")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .padding()
            
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
            let imageURLs = convertPDFToImages(result: result)
            handleFileImport(imageURLs: imageURLs!)
            
            //print(importedFileContent, "9", result, "8", "result")
        }
        .navigationTitle("Text to Speech")
        //fontWeight(.bold)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button{
                    showVoiceSheet = true
                    //SetVoiceAndSpeed(speed: speed, pitch: pitch, volume: volume)
                } label: {
                    Image(systemName: "ellipsis")
                        .imageScale(.large)
                        .foregroundColor(.gray)
                }
            }
        }
        .sheet(isPresented: $showVoiceSheet) {
            NavigationStack{
                SetSpeedPitchVolume(selectedPercentSpeed: $speed, selectedPercentPitch: $pitch, selectedPercentVolume: $volume)
                    .navigationTitle("Voice Settings")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Done") {
                                showVoiceSheet = false
                            }
                        }
                    }
            }
        }
    }

    func handleFileImport(imageURLs: [UIImage?]) {
        var allRecognizedText: [String] = []
        //let image = UIImage(named: "quote")
        
        //if let cgImage = imageURL.first??.cgImage{
        for image in imageURLs {
            //if let image = UIImage(contentsOfFile: url.path),
            guard let cgImage = image?.cgImage else { continue }
                // Request handler
            let handler = VNImageRequestHandler(cgImage: cgImage)
            let recognizeRequest = VNRecognizeTextRequest { (request, error) in
                    
                    // Parse the results as text
                guard let results = request.results as? [VNRecognizedTextObservation] else {
                        return
                }
                    
                    // Extract the data
                let stringArray = results.compactMap { result in
                        result.topCandidates(1).first?.string
                }
                allRecognizedText.append(stringArray.joined(separator: "\n"))
            }
                
                // Update the UI
                
                // Process the request
            recognizeRequest.recognitionLevel = .accurate
            do {
                try handler.perform([recognizeRequest])
            } catch {
                print(error)
            }
        }
        DispatchQueue.main.async {
            importedFileContent = allRecognizedText.joined(separator: "\n\n")
        }
    }
        
            
    func convertPDFToImages(result: Result<[URL], Error>) -> [UIImage]?{
        guard let pdfURL = try! result.get().first,
            let pdfDocument = PDFDocument(url: pdfURL) else {
            importedFileContent = "Could not open the file."
            return nil
        }
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
    }
    func SetVoiceAndSpeed(){
        
    }
    
}

class SpeechManager: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    private var synthesizer = AVSpeechSynthesizer()
    private var originalText: String = ""
    private var wordRanges: [NSRange] = []
    @State var importedFileContent = ""
    @State private var imageURL: [URL?] = []
    var speed: Double = 50.0
    var pitch : Double = 50.0
    var volume : Double = 50.0


    @Published var highlightedText: AttributedString = ""

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    /*func speak(text: String) {
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = Float(speed / 100) // e.g. 0.5 = normal
        utterance.pitchMultiplier = Float(pitch / 100)
        utterance.volume = Float(volume / 100)
        utterance.postUtteranceDelay = 0.1


        synthesizer.speak(utterance)
    }*/
    /*func speakImportedText(_ text: String) {
            //guard !importedFileContent.isEmpty else { return }
            speak(text: importedFileContent)
        }*/

     

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        let full = utterance.speechString as NSString
        //let word = full.substring(with: characterRange)
        DispatchQueue.main.async {
            guard !self.originalText.isEmpty else { return }
            var attributed = AttributedString(full as String)
            if let range = Range(characterRange, in: attributed) {
                attributed[range].backgroundColor = .yellow
            }
            self.highlightedText = attributed
        }
    }
    func speakText(text: String){
        
        self.originalText = text
        self.highlightedText = AttributedString(text)
            //func speakText(_ text: String? = nil, completion: @escaping() -> Void) throws {
            /* let audioSession = AVAudioSession.sharedInstance()
             
             do {
             try audioSession.setCategory(.playback, mode: .voicePrompt, options: [.duckOthers])
             try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
             } catch {
             throw TextToSpeechError.audioSessionSetupFailed
             }*/
        //guard !importedFileContent.isEmpty else { return }
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US") // Change language if needed
            //speechSynthesizer.speak(utterance)
        utterance.rate = Float(speed) / 100.0  //0.8
        utterance.pitchMultiplier = Float(pitch) / 100.0 //0.8  pitch
        utterance.postUtteranceDelay = 0.2
        utterance.volume = Float(volume) / 100.0 // 0.8 //volume
        synthesizer.speak(utterance)

    }

    
}

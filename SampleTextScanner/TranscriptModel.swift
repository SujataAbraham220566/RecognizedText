//
//  TranscriptModel.swift
//  SampleTextScanner
//
//  Created by Sujata Abraham on 14/06/25.
//  Copyright © 2025 Apple. All rights reserved.
//
import Foundation
import Observation
import SwiftUI

class TranscriptModel{
    @Binding var imageOCR: OCR
    init(imageOCR: Binding<OCR>){
        self._imageOCR = imageOCR
    }
    @Published var pdfURL: URL?
    func createTXT(){
        let fileManager = FileManager.default
        if let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first{
            let filePath = documentsDirectory.appendingPathComponent("example.txt")
            if !fileManager.fileExists(atPath: filePath.path){
                fileManager.createFile(atPath: filePath.path, contents: nil, attributes: nil)
            }
            do {
                let fileHandle = try FileHandle(forWritingTo: filePath)
                /*defer{
                    fileHandle.closeFile()
                }*/
                for observation in imageOCR.observations{
                    let padd = Int(observation.topLeft.x * UIScreen.main.bounds.width)
                    let spaces = String(repeating: " ", count: padd)
                    let text = observation.topCandidates(1).first?.string ?? "no text"
                    let content = spaces + text + "\n"
                    if let data = content.data(using: .utf8){
                        fileHandle.seekToEndOfFile()
                        try fileHandle.write(contentsOf: data)
                        print(content)
                        //try content.write(to: filePath, atomically: true, encoding: .utf8)
                    }
                }
                do {
                    let fileContents = try String(contentsOf: filePath, encoding: .utf8)
                    print(fileContents) // This prints the entire file content to the Xcode console
                } catch {
                    print("Failed to read file: \(error)")
                }
                fileHandle.closeFile()
            } catch {
                print("error writing to file: \(error)")
            }
        } else {
            print("Could not locate the documents directory.")
        }
    }
    func deleteTXT(){
        let fileManager = FileManager.default
        if let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first{
            let filePath = documentsDirectory.appendingPathComponent("example.txt")
            do {
                try FileManager.default.removeItem(at: filePath)
            } catch {
                print("error deleting pdf: \(error)")
            }
        }
    }
    func viewTXT() -> String{
        do {
            let fileManager = FileManager.default
            let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
            let filePath = documentsDirectory!.appendingPathComponent("example.txt")
            if !fileManager.fileExists(atPath: filePath.path){
                fileManager.createFile(atPath: filePath.path, contents: nil, attributes: nil)
            } else {
                try fileManager.removeItem(at: filePath)
                fileManager.createFile(atPath: filePath.path, contents: nil, attributes: nil)
            }
            
                let fileHandle = try FileHandle(forWritingTo: filePath)
                defer{
                    fileHandle.closeFile()
                }
                for observation in imageOCR.observations{
                    let content = (observation.topCandidates(1).first?.string ?? "No text recognized")
                    fileHandle.seekToEndOfFile()
                    if let data = content.data(using: .utf8){
                        try fileHandle.write(contentsOf: data)
                    }
                    //try content.write(to: filePath, atomically: true, encoding: .utf8)
                }
                fileHandle.closeFile()
                let content = try String(contentsOf: filePath, encoding: .utf8)
                return String(content)
            } catch {
                return String("error viewing pdf: \(error)")
            }
    }
}

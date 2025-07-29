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
                var positionedLines: [(x: CGFloat, y: CGFloat, text: String)] = []
            
            for observation in imageOCR.observations {
                guard let text = observation.topCandidates(1).first?.string else { continue }
                let box = observation.boundingBox
                positionedLines.append((x: box.origin.x, y: box.origin.y, text: text))
            }
            
            // 2. Sort by Y (top to bottom), then X (left to right)
            let sorted = positionedLines.sorted {
                if abs($0.y - $1.y) > 0.01 {
                    return $0.y > $1.y // top to bottom
                } else {
                    return $0.x < $1.x // left to right
                }
            }

            // 3. Convert to rows by grouping close Y values
            var lines: [[(y:CGFloat, x: CGFloat, text: String)]] = []
            var currentLine: [(y: CGFloat, x: CGFloat, text: String)] = []
            var lastY: CGFloat?

            for item in sorted {
                if let last = lastY, abs(item.y - last) > 0.02 {
                    lines.append(currentLine)
                    currentLine = []
                }
                currentLine.append((y: item.y, x: item.x, text: item.text))
                lastY = item.y
            }
            if !currentLine.isEmpty { lines.append(currentLine) }

            // 4. Generate line text with spacing based on X
            var finalText = ""
            for line in lines {
                let sortedLine = line.sorted(by: { $0.x < $1.x })
                var lineText = ""
                var lastX: CGFloat = 1.0 * 0.18
                print(lastX)
                //var lastY: CGFloat = 1.0
                for word in sortedLine {
                    print(word.x, "hi")
                        let gap = Int((word.x - lastX) * 50) // scale x to space
                        lineText += String(repeating: " ", count: max(gap, 1)) + word.text
                    print(gap, "bye")
                    lastX = word.x
                }
                finalText += lineText + "\n"
            }

            // 5. Write to file
            try finalText.write(to: filePath, atomically: true, encoding: .utf8)

                /*let sortedObservations = imageOCR.observations.sorted {
                    $0.boundingBox.origin.y > $1.boundingBox.origin.y
                }
                for observation in sortedObservations {
                    let content = (observation.topCandidates(1).first?.string ?? "No text recognized")
                    fileHandle.seekToEndOfFile()
                    let formattedLine = content + "\n"
                    if let data = formattedLine.data(using: .utf8) {
                        try fileHandle.write(contentsOf: data)
                    }
                }*/
                /*let textLines = imageOCR.observations
                .sorted { $0.boundingBox.origin.y > $1.boundingBox.origin.y }
                .map { $0.topCandidates(1).first?.string ?? "No text recognized" }

                let finalText = textLines.joined(separator: "\n")
                try finalText.write(to: filePath, atomically: true, encoding: .utf8)*/
                /*for observation in imageOCR.observations{
                    let content = (observation.topCandidates(1).first?.string ?? "No text recognized")
                    fileHandle.seekToEndOfFile()
                    if let data = content.data(using: .utf8){
                        try fileHandle.write(contentsOf: data)
                    }*/
                //try data.write(to: filePath, atomically: true, encoding: .utf8)
        
                fileHandle.closeFile()
                let content = try String(contentsOf: filePath, encoding: .utf8)
                return String(content)
            } catch {
                return String("error viewing pdf: \(error)")
            }
    }
}

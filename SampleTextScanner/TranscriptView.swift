/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Displays the captured image's text.
*/
import SwiftUI
import Vision

struct TranscriptView: View {
    @Binding var imageOCR: OCR
    @State private var transcriptModel: TranscriptModel!
    @State private var ttt : String = ""
    
    init(imageOCR: Binding<OCR>){
        self._imageOCR = imageOCR
        self._transcriptModel = State(initialValue: TranscriptModel(imageOCR: $imageOCR))
    }
    
    var body: some View {
        VStack {
            ScrollView{
                if imageOCR.observations.isEmpty {
                    Text("No text found")
                        .foregroundStyle(.gray)
                } else {
                    Text("Text extracted from the image:")
                        .font(.title2)
                }
                Section ("View TXT") {
                    Text(transcriptModel.viewTXT())
                }
            }
            .toolbar {
                Button {
                    transcriptModel.deleteTXT()
                    imageOCR.observations.removeAll()
                    transcriptModel.createTXT()
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                
            }
        }
        .onAppear {
            transcriptModel.deleteTXT()
        }
    }
}


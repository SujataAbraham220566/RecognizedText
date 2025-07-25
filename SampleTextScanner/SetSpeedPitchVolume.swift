//
//  SetPitchVolumeSpeed.swift
//  SampleTextScanner
//
//  Created by Sujata Abraham on 18/07/25.
//  Copyright © 2025 Apple. All rights reserved.
//
import SwiftUI

struct SetSpeedPitchVolume: View{
    @Binding var selectedPercentSpeed: Double
    @Binding var selectedPercentPitch: Double
    @Binding var selectedPercentVolume: Double
    @Environment(\.dismiss) var dismiss

        var body: some View {
            VStack(spacing: 20) {
                Text("Select Speed: \(Int(selectedPercentSpeed))%")
                    .font(.title2)
                Slider(value: $selectedPercentSpeed, in: 0...100)
                Text("Select Pitch: \(Int(selectedPercentPitch))%")
                    .font(.title2)
                Slider(value: $selectedPercentPitch, in: 0...100)
                Text("Select Volume: \(Int(selectedPercentVolume))%")
                    .font(.title2)
                Slider(value: $selectedPercentVolume, in: 0...100)

            }
        }
}
/*struct PercentPickerView_Previews: PreviewProvider {   static var previews: some View {
    SetSpeedPitchVolume(selectedPercentSpeed: $selectedPercentSpeed, selectedPercentPitch: $selectedPercentPitch, selectedPercentVolume: $selectedPercentVolume)
    }
}*/

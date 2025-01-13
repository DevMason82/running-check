//
//  ContentView.swift
//  DailyHope
//
//  Created by mason on 1/10/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = SpeechViewModel()
        
        var body: some View {
            VStack(spacing: 20) {
                TextField("소망을 입력하세요", text: $viewModel.inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button(action: {
                    viewModel.speakText()
                }) {
                    Text("소망 읽어주기")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
}

#Preview {
    ContentView()
}

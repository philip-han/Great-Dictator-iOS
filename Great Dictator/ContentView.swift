//
//  ContentView.swift
//  Great Dictator
//
//  Created by Philip Han on 10/2/22.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var speechCoreWrapper: SpeechCoreWrapper = SpeechCoreWrapper()
    @State var indicatorColor = Color.black
    @State var indicatorText = "Sleeping"
    @State var errorAlert = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                ScrollViewReader { proxy in
                    List(speechCoreWrapper.publishedList) { item in
                        Text(item.speech).id(item.id)
                    }.onReceive(speechCoreWrapper.$publishedList) { list in
                        let lastItem = speechCoreWrapper.publishedList.last
                        proxy.scrollTo(lastItem?.id, anchor: .bottom)
                    }.frame(width: geometry.size.width * 0.9, height: geometry.size.height * 0.8)
                }
                Spacer().frame(height: 10)
                Text(indicatorText).foregroundColor(indicatorColor)
                    .onReceive(speechCoreWrapper.$speechRecognizerState) { state in
                        if let isListening = state {
                            print("state: \(isListening)")
                            self.indicatorText = isListening.text
                            self.indicatorColor = isListening.color
                        }
                    }
                Spacer().frame(height: 10)
                Button(action: {
                    speechCoreWrapper.toggle()
                }) {
                    Text("Dictate").fontWeight(.bold)
                        .font(.subheadline)
                        .foregroundColor(.purple)
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.purple, lineWidth: 5))
                }
                Spacer().frame(height: 10)
            }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        }.onReceive(speechCoreWrapper.$errorMessageState) { message in
            errorAlert = message.count > 0
        }.alert("Error", isPresented: $errorAlert,
                actions: {
                    Button("Ok", role: .cancel, action: { errorAlert = false })
                },
                message: { Text(speechCoreWrapper.errorMessageState) }
        )
            
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

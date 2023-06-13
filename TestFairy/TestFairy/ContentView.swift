//
//  ContentView.swift
//  TestFairy
//
//  Created by Charles Edge on 05/06/23.
//

import SwiftUI

struct ContentView: View {
    @State var token: String = ""
    let tokenManager = TokenManager()
    @State var buttonLabel = ""
    @State var iconSystemName = "key"
    var body: some View {
        VStack {
            Image(systemName: iconSystemName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .padding()
                        Text("Insert your OpenAI token").font(.headline)
                        TextField("Token", text: $token)
            Button(buttonLabel) {
                            saveToken()
                        }.buttonStyle(.bordered)
        }.padding().frame(maxWidth: 300)
            .onAppear {
            guard let token = tokenManager.getToken() else {
                buttonLabel = "Save"
                return
            }
            self.token = token
            buttonLabel = "Update"
            iconSystemName = "checkmark.circle"
        }.navigationTitle("Test Fairy")
        
    }
    
    private func saveToken() {
        tokenManager.set(token: token)
        buttonLabel = "Update"
        iconSystemName = "checkmark.circle"
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

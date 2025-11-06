//
//  ContentView.swift
//  SwiftConcurrencyDemo
//
//  Created by Nishchal Visavadiya on 13/10/24.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var viewModel = ViewModel()
    
    var body: some View {
        Button("Example") {
            viewModel.run()
        }
    }
}

#Preview {
    ContentView()
}

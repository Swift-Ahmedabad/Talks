
import SwiftUI
import Combine

class LLDBDemoModel: ObservableObject {
    @Published var count = 0
    
    func updateUI() { print("UI updated: count = \(count)") }
}
struct Demo03_LLDBModify: View {
    @StateObject private var model = LLDBDemoModel()
    var body: some View {
        VStack(spacing: 12) {
            Text("Count = \(model.count)")
            Button("Set count = 5 (then use lldb expr to change)") {
                model.count = 5
                model.count = 10
                model.updateUI()
            }
            // Move the execution pointer
            // Use lldb: po model.count  and  expr model.count = 100
        }.padding()
    }
}

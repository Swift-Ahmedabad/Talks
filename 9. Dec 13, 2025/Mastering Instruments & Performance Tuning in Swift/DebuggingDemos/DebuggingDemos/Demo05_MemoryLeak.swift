
import SwiftUI
import Foundation
import Combine

struct Demo05_MemoryLeak: View {
    
    @State private var show = false

    var body: some View {
        VStack(spacing: 16) {

            Button("Open Leaky View") {
                show.toggle()
            }

            Text("Dismiss view → deinit should NOT be called")
                .font(.caption)

        }
        .sheet(isPresented: $show) {
            LeakyChildView()
        }
        .padding()
    }
}

struct LeakyChildView: View {

    @StateObject private var vm = LeakyViewModel()

    var body: some View {
        VStack(spacing: 12) {
            Text("Counter: \(vm.counter)")
            Button("Close") {
                dismiss()
            }
        }
        .padding()
    }

    @Environment(\.dismiss) private var dismiss
}

final class LeakyViewModel: ObservableObject {

    @Published var counter = 0
    private var timer: Timer?

    init() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.counter += 1   // ❌ strong self capture
            print("Tick:", self.counter)
        }
    }

    deinit {
        print("❌ LeakyViewModel deinit")
    }
}

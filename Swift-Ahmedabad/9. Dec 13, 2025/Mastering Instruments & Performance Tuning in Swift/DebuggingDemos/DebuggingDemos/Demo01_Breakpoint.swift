
import SwiftUI
struct User { let name: String? }
struct Demo01_Breakpoint: View {
//    var body: some View {
//        Button("Run Crash (Exception Breakpoint demo)") {
//            let users = [User(name: "Sneha"), User(name: nil), User(name: "Amit")]
//            for user in users {
//                print(user.name!) // 💥 expected crash here
//            }
//        }.padding()
//    }
//}
//
//import SwiftUI
//
//struct DebuggingBreakpointsDemo: View {
    @State private var counter = 0
    @State private var numbers = [1, 2, 3]
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Breakpoint Examples")) {
                    
                    Button("LLDB demo") {
                        LLDBDemo()
                    }
                    
                    Button(" Conditional Breakpoint (trigger at 5)") {
                        conditionalBreakpointDemo()
                    }
                    
                    Button(" Action Breakpoint (log only)") {
                        actionBreakpointDemo()
                    }
                    
                    Button(" Exception Breakpoint (crash)") {
                        exceptionBreakpointDemo()
                    }
                    
                    Button(" Swift Error Breakpoint (throws)") {
                        do {
                            try errorBreakpointDemo()
                        } catch {
                            print("Caught error: \(error.localizedDescription)")
                        }
                    }
                }
            }
            .navigationTitle("Breakpoint Demo")
        }
    }
}

// MARK: - Breakpoint Examples
extension Demo01_Breakpoint {
    
    // 2️⃣ Conditional Breakpoint Demo
    func LLDBDemo() {
        struct User {
                var name: String
                var score: Int
            }

            var user = User(name: "Sneha", score: 10)
            let multiplier = 2

            // 🔴 Breakpoint 1 — Object & Value inspection
            let finalScore = user.score * multiplier

            // 🔴 Breakpoint 2 — Runtime modification
            user.score += finalScore

            // 🔴 Breakpoint 3 — Track unexpected changes
            user.score += 5

            // 🔴 Breakpoint 4 — Call stack & crash
            triggerCrash(user: user)
    }
    
    private func triggerCrash(user: Any) {
        fatalError("Intentional crash for LLDB backtrace demo")
    }
    
    // 2️⃣ Conditional Breakpoint Demo
    func conditionalBreakpointDemo() {
        for i in 0..<10 {
            print("Loop index:", i)  // <-- Add Conditional Breakpoint: i == 5
        }
    }
    
    
    // 3️⃣ Action Breakpoint Demo (e.g., Print message automatically)
    func actionBreakpointDemo() {
        let time = Date()
        print("Action breakpoint triggered at \(time)")
        // Add Action Breakpoint → Print a custom log without stopping execution
    }
    
    
    // 4️⃣ Exception Breakpoint Demo
    func exceptionBreakpointDemo() {
        let array = [1, 2, 3]
        let value = array[5]   // <-- Will crash: index out of range
        print(value)
    }
    
    
    // 6️⃣ Swift Error Breakpoint Demo
    func errorBreakpointDemo() throws {
        enum LoginError: Error {
            case invalidCredentials
        }
        
        throw LoginError.invalidCredentials   // <-- Swift Error Breakpoint triggers here
    }
}

// MARK: - Helper Class for Symbolic Breakpoint Demo
class UIKitSymbolClass {
    func triggerUIKitEvent() {
        // Call UIKit API → You can attach a symbolic breakpoint like viewDidAppear:
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

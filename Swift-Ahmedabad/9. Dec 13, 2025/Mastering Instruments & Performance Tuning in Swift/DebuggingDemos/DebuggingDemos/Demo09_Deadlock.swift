
import SwiftUI
struct Demo09_Deadlock: View {
    var body: some View {
        Button("Cause Main Thread Deadlock") {
            DispatchQueue.main.sync {
                print("Blocked!") // deadlock
            }
        }.padding()
    }
}

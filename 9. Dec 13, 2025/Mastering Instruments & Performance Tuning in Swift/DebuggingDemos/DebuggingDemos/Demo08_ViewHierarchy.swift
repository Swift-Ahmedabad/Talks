
import SwiftUI
import UIKit
struct Demo08_ViewHierarchy: View {
    var body: some View {
        VStack(spacing: 12) {
            Button("Add Transparent Blocker Over Button") {
                guard let root = UIApplication.shared.windows.first?.rootViewController else { return }
                let vc = UIViewController()
                root.present(vc, animated: true) {
                    let button = UIButton(type: .system)
                    button.setTitle("Tap me", for: .normal)
                    button.frame = CGRect(x: 50, y: 200, width: 200, height: 44)
                    vc.view.addSubview(button)
                    
                    let blocker = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
                    blocker.backgroundColor = .clear
                    vc.view.addSubview(blocker)
                }
            }
            Text("Open Debug View Hierarchy to see the invisible blocker")
        }.padding()
    }
}

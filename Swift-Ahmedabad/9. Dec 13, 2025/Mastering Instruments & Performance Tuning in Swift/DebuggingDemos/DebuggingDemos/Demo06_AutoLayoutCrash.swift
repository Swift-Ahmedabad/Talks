
import SwiftUI
import UIKit
struct Demo06_AutoLayoutCrash: View {
    var body: some View {
        VStack(spacing: 12) {
            Button("Run AutoLayout Invalid Constraint") {
                let vc = UIViewController()
                let window = UIApplication.shared.windows.first
                window?.rootViewController?.present(vc, animated: true)
                let label = UILabel()
                label.translatesAutoresizingMaskIntoConstraints = false
                vc.view.addSubview(label)
                NSLayoutConstraint.activate([
                    label.widthAnchor.constraint(equalToConstant: -50) // invalid constraint -> AutoLayout log
                ])
            }
        }.padding()
    }
}


// Add symbolic breakpoint for UIViewAlertForUnsatisfiableConstraints

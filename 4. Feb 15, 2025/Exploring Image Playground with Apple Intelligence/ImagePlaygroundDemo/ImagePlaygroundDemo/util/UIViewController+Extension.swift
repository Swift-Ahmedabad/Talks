
import UIKit

extension UIViewController {
    func enableKeyboardHandling() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardHeight = keyboardFrame.height
        
        if self.view.frame.origin.y == 0 {
            UIView.animate(withDuration: 0.3) {
                self.view.frame.origin.y = -keyboardHeight / 2
            }
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.view.frame.origin.y = 0
        }
    }

    func disableKeyboardHandling() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}


extension UIViewController {
    func enableTapToDismissKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}


// MARK: - UIView Extension -

extension UIView{
    
    @discardableResult
    func addBlurBorder(borderWidth: CGFloat, blurViewAlpha: CGFloat = 0.5) -> UIVisualEffectView{
        let blurEffect = UIBlurEffect(style: .regular) // Can use .dark or .extraLight
        let blurView = UIVisualEffectView(effect: blurEffect)
        
        let blurFrame = CGRect(
            x: self.frame.origin.x - borderWidth,
            y: self.frame.origin.y - borderWidth,
            width: self.frame.size.width + (2 * borderWidth),
            height: self.frame.size.height + (2 * borderWidth)
        )
        blurView.alpha = 0.5
        blurView.frame = blurFrame
        blurView.layer.cornerRadius = self.layer.cornerRadius + borderWidth
        blurView.layer.masksToBounds = true
        
        self.superview?.insertSubview(blurView, belowSubview: self)
        return blurView
    }
}

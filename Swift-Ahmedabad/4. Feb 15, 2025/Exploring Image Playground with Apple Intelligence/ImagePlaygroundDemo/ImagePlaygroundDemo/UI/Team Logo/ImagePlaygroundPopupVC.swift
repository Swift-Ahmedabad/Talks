//
//  ImagePlaygroundPopupVC.swift
//  ImagePlaygroundDemo
//
//  Created by Rahul Chandnani on 15/02/25.
//


import UIKit
import ImagePlayground

@available(iOS 18.1, *)
class ImagePlaygroundPopupVC: UIViewController {
    
    
    // MARK: - OUTLETS -

    @IBOutlet weak var viewData: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var viewImageBubble: UIView!
    @IBOutlet weak var imgProfile: RCMorphingBubbleImageView!
    @IBOutlet weak var imgBubbleRing: RCMorphingBubbleImageView!
    
    @IBOutlet weak var viewImageDescription: UIView!
    @IBOutlet weak var imgAILogo: UIImageView!
    @IBOutlet weak var txtImageDescription: UITextField!
    
    @IBOutlet weak var btnNotNow: UIButton!
    @IBOutlet weak var btnTryNow: UIButton!

    

    
    // MARK: - VARIABLES -
    
    private weak var parentVc:UIViewController?
    private lazy var sourceImage: UIImage = UIImage()
    private var didDismiss: ((_ image:UIImage?) -> Void)?
    
    private var aiImage:UIImage?
    
    // MARK: - VIEW - LIFE CYCLE -
    @discardableResult
    static func open(fromVc: UIViewController, sourceImage:UIImage, didDismiss: ((_ aiImage:UIImage?) -> Void)?) -> ImagePlaygroundPopupVC{
        let popup = ImagePlaygroundPopupVC.instantiate()
        popup.parentVc          = fromVc
        popup.sourceImage       = sourceImage
        popup.didDismiss        = didDismiss
        
        fromVc.present(popup, animated: true)
        return popup
    }
    
    static func instantiate() -> ImagePlaygroundPopupVC {
        let controller = SystemUtil.getViewController(storyboardIdentifier: "Main", controllerIdentifier: "ImagePlaygroundPopupVC") as! ImagePlaygroundPopupVC
        return controller
    }
    
    deinit {
        debugPrint("‼️‼️‼️ deinit of \(self.classForCoder) ‼️‼️‼️")
        disableKeyboardHandling()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.imgProfile.startMorphingAnimation(with: self.sourceImage, isAllowedRotating: false)
        self.imgBubbleRing.startMorphingAnimation(with: UIImage(named: "ai_bubble_ring") ?? UIImage(), isAllowedRotating: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
    }
    
    override func didReceiveMemoryWarning() {
    }
    
    
    
    // MARK: - VIEW - LAYOUT -
    
    private func setUpView() {
        self.txtImageDescription.delegate = self
        applyTheme()
        enableKeyboardHandling()
        enableTapToDismissKeyboard()
    }
    
    private func applyTheme() {
        self.view.backgroundColor = .black

        self.imgProfile.image = self.sourceImage
        self.viewImageDescription.layer.cornerRadius = self.viewImageDescription.frame.height / 2
        self.imgProfile.layer.cornerRadius = self.imgProfile.frame.height / 2
        self.imgProfile.addBlurBorder(borderWidth: 6, blurViewAlpha: 0.5)

        
    }
    
    override func viewDidLayoutSubviews() {
    }
    override func viewWillLayoutSubviews() {
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            print("Landscape")
        } else {
            print("Portrait")
        }
    }

    // MARK: - NAVIGATION -
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
    
    // MARK: - IBActions -
    @IBAction func btnNotNowClicked(_ sender: UIButton) {
        self.didDismiss?(aiImage)
        self.dismiss(animated: true)
    }
    
    @IBAction func btnTryNowClicked(_ sender: UIButton) {
        openImagePlaygroundIfAvailable(with: txtImageDescription.text ?? "Cricket", selectedImage: self.sourceImage)
    }
    
    
    private func openImagePlaygroundIfAvailable(with story: String, selectedImage: UIImage) {
        if ImagePlaygroundViewController.isAvailable {
            let playground = ImagePlaygroundViewController()
            playground.delegate = self
            playground.sourceImage = selectedImage
            // Set extracted concepts from the story in the playground
            playground.concepts = [.extracted(from: story, title: "Cricket")]
            (self.navigationController ?? self).present(playground, animated: true, completion: nil)
        } else {
            // Fallback on earlier versions
            let alert = UIAlertController(title: "Feature Unavailable",
                                          message: "This feature isn't available.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
    
}

// MARK: - ImagePlaygroundViewController Delegate -


@available(iOS 18.1, *)
extension ImagePlaygroundPopupVC: ImagePlaygroundViewController.Delegate{
    func imagePlaygroundViewController(_ imagePlaygroundViewController: ImagePlaygroundViewController, didCreateImageAt imageURL: URL) {
        // Add the image to the image view
        guard let image = UIImage(contentsOfFile: imageURL.path) else {
            print("Error loading image from URL: \(imageURL)")
            return
        }
        self.sourceImage = image
        self.imgProfile.image = image
        self.aiImage = image
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        imagePlaygroundViewController.dismiss(animated: true)
        
        let alert = UIAlertController(title: "Image Saved Successfully",
                                      message: "",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Great!", style: .default, handler: { [weak self] action in guard let self else { return }
            self.didDismiss?(aiImage)
            self.dismiss(animated: true)
        }))
        self.present(alert, animated: true)

    }
    
    func imagePlaygroundViewControllerDidCancel(_ imagePlaygroundViewController: ImagePlaygroundViewController) {
        imagePlaygroundViewController.dismiss(animated: true)
        
    }
    
}


// MARK: - ImagePlaygroundViewController Delegate -

@available(iOS 18.1, *)
extension ImagePlaygroundPopupVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.btnTryNowClicked(self.btnNotNow)
        return true
    }
}

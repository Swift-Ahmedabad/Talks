// 
//  TeamLogoSamplesVC.swift
//  ImagePlaygroundDemo
//
//  Created by Rahul Chandnani on 15/02/25.
//

//  

import UIKit

class TeamLogoSamplesVC: UIViewController {

    // MARK: - OUTLETS -
    @IBOutlet weak var cvTeamLogos: UICollectionView!

    // MARK: - VARIABLES -
    let gridLayout = RCFlowLayout(cellsPerRow: 2,
                                  minimumInteritemSpacing: 12,
                                  minimumLineSpacing: 12,
                                  sectionInset: UIEdgeInsets(top: 0, left: 12, bottom: 12, right: 12))
    
    private var arrLogos: [UIImage] = []
    
    
    // MARK: - VIEW - LIFE CYCLE -
    
    static func instantiate() -> TeamLogoSamplesVC {
        let controller = SystemUtil.getViewController(storyboardIdentifier: "Main", controllerIdentifier: "TeamLogoSamplesVC") as! TeamLogoSamplesVC
        return controller
    }

    deinit {
        debugPrint("‼️‼️‼️ deinit of \(self.classForCoder) ‼️‼️‼️")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        arrLogos = (1...10).compactMap { UIImage(named: "logo\($0)") }
        cvTeamLogos.collectionViewLayout = gridLayout

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
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
    
    
}



// MARK: - CollectionView Delegates -

extension TeamLogoSamplesVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // MARK: - DataSource Methods -
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrLogos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TeamLogoCell", for: indexPath) as? TeamLogoCell else {
            return UICollectionViewCell()
        }
        cell.imgTeamLogo.image = arrLogos[indexPath.row]
        return cell
    }
    
    // MARK: - Delegate Methods -
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if #available(iOS 18.1, *) {
            ImagePlaygroundPopupVC.open(fromVc: self, sourceImage: arrLogos[indexPath.row]) { [weak self] aiImage in guard let self = self, let image = aiImage else { return }
                DispatchQueue.main.async {
                    self.arrLogos.insert(image, at: 0)
                    self.cvTeamLogos.reloadData()
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }

}




//
//  TeamLogoCell.swift
//  ImagePlaygroundDemo
//
//  Created by Rahul Chandnani on 15/02/25.
//

import UIKit

class TeamLogoCell: UICollectionViewCell {
    @IBOutlet weak var imgTeamLogo: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imgTeamLogo.layer.cornerRadius = 10
    }

}

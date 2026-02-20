//
//  RCFlowLayout.swift
//  ImagePlaygroundDemo
//
//  Created by Rahul Chandnani on 15/02/25.
//


import Foundation
import UIKit

class RCFlowLayout: UICollectionViewFlowLayout {
    
    let cellsPerRow: Float
    var cellHeight: CGFloat = 0
    var heightRatio:CGFloat?
    override var itemSize: CGSize {
        get {
            guard let collectionView = collectionView else { return super.itemSize }
            let marginsAndInsets = sectionInset.left + sectionInset.right + minimumInteritemSpacing * CGFloat(cellsPerRow - 1)
            let itemWidth = ((collectionView.bounds.size.width - marginsAndInsets) / CGFloat(cellsPerRow)).rounded(.down)
            if let heightRatio = heightRatio{
                self.cellHeight = itemWidth * heightRatio
            }
            return CGSize(width: itemWidth, height: cellHeight == 0 ? itemWidth : cellHeight)
        }
        set {
            super.itemSize = newValue
        }
    }
    
    
    /// Description
    /// - Parameters:
    ///   - cellsPerRow: number of rows in collectionview
    ///   - minimumInteritemSpacing: spacing between items
    ///   - minimumLineSpacing: spacing between rows
    ///   - sectionInset: section padding insets
    ///   - cellHeight: its optional. to give fix height to cells if it is set to 0 colletionview will become grid view
    init(cellsPerRow: Float, minimumInteritemSpacing: CGFloat = 0, minimumLineSpacing: CGFloat = 0, sectionInset: UIEdgeInsets = .zero, cellHeight: CGFloat = 0, heightRatio:CGFloat? = nil) {
        self.heightRatio = heightRatio
        self.cellsPerRow = UIDevice().userInterfaceIdiom == .pad ? (cellsPerRow * 2) : cellsPerRow
        super.init()
        
        self.minimumInteritemSpacing = minimumInteritemSpacing
        self.minimumLineSpacing = minimumLineSpacing
        self.sectionInset = sectionInset
        
        self.cellHeight = cellHeight
        if let heightRatio = heightRatio{
            self.cellHeight = itemSize.width * heightRatio
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds) as! UICollectionViewFlowLayoutInvalidationContext
        context.invalidateFlowLayoutDelegateMetrics = newBounds != collectionView?.bounds
        return context
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect),
              let collectionView = collectionView,
              collectionView.numberOfSections > 0,
              collectionView.numberOfItems(inSection: 0) > 0 else {
            return super.layoutAttributesForElements(in: rect)
        }
        
        let itemCount = collectionView.numberOfItems(inSection: 0)
        if itemCount == 1, let attribute = attributes.first {
            let collectionViewWidth = collectionView.bounds.width
            let cellWidth = attribute.frame.width
            let xOffset = (collectionViewWidth - cellWidth) / 2
            attribute.frame.origin.x = xOffset
        }
        
        return attributes
    }
}


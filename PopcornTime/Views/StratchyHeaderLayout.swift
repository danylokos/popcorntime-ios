//
//  StratchyHeaderLayout.swift
//  PopcornTime
//
//  Created by Andrew  K. on 3/13/15.
//  Copyright (c) 2015 PopcornTime. All rights reserved.
//

import UIKit

class StratchyLayoutAttributes: UICollectionViewLayoutAttributes {
    
    var deltaY: CGFloat = 0
    var maxDelta: CGFloat = CGFloat.greatestFiniteMagnitude
    
    override func copy(with zone: NSZone?) -> Any {
        let copy = super.copy(with: zone) as! StratchyLayoutAttributes
        copy.deltaY = deltaY
        return copy
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let attributes = object as? StratchyLayoutAttributes {
            if attributes.deltaY == deltaY {
                return super.isEqual(object)
            }
        }
        return false
    }
}

class StratchyHeaderLayout: UICollectionViewFlowLayout, StratchyHeaderDelegate {
    
    var headerSize = CGSize.zero
    var maxDelta: CGFloat = CGFloat.greatestFiniteMagnitude
    let minCellWidth: CGFloat = 300
    let cellAspectRatio: CGFloat = 370/46
    
    override class var layoutAttributesClass : AnyClass {
        return StratchyLayoutAttributes.self
    }
    
    override var collectionViewContentSize : CGSize {
        
        sectionInset.bottom = 15.0
        sectionInset.top = 5.0
        
        minimumInteritemSpacing = sectionInset.left
        
        let width = self.collectionView!.bounds.width - sectionInset.left - sectionInset.right
        let numberOfColumns = Int(width / minCellWidth)
        let cellWidth = CGFloat((Int(width) - Int(minimumInteritemSpacing) * (numberOfColumns - 1)) / numberOfColumns)
        let cellHeight = cellWidth / cellAspectRatio
        self.itemSize = CGSize(width: cellWidth, height: cellHeight)
        
        return super.collectionViewContentSize
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        let insets = collectionView!.contentInset
        let offset = collectionView!.contentOffset
        let minY = -insets.top
        
        let attributes = super.layoutAttributesForElements(in: rect)
        
        if let stratchyAttributes = attributes as? [StratchyLayoutAttributes] {
            // Check if we've pulled below past the lowest position
            if (offset.y < minY){
                let deltaY = fabs(offset.y - minY)
                
                for attribute in stratchyAttributes{
                    if (attribute.indexPath.section == 0){
                        if let kind = attribute.representedElementKind{
                            if (kind == UICollectionElementKindSectionHeader) {
                                var headerRect = attribute.frame
                                headerRect.size.height =  min(headerSize.height + maxDelta, max(minY, headerSize.height + deltaY));
                                headerRect.origin.y = headerRect.minY - deltaY;
                                attribute.frame = headerRect
                                attribute.deltaY = deltaY
                                attribute.maxDelta = maxDelta
                            }
                        }
                    }
                }
            }
        }
        
        return attributes
    }
    
    // MARK: - StratchyHeaderDelegate
    func stratchyHeader(_ header: StratchyHeader, didResetMaxStratchValue value: CGFloat) {
        maxDelta = value
    }
    
}

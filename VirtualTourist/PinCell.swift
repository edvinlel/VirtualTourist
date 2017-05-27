//
//  PinCell.swift
//  VirtualTourist
//
//  Created by Edvin Lellhame on 5/17/17.
//  Copyright © 2017 Edvin Lellhame. All rights reserved.
//

import UIKit

class PinCell: UICollectionViewCell {
	@IBOutlet var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = nil
    }
}

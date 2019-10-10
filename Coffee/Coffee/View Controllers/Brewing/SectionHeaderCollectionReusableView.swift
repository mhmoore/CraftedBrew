//
//  SectionHeaderCollectionReusableView.swift
//  Coffee
//
//  Created by Michael Moore on 9/15/19.
//  Copyright © 2019 Michael Moore. All rights reserved.
//

import UIKit

class SectionHeaderCollectionReusableView: UICollectionReusableView {
    // MARK: - Outlets
    @IBOutlet weak var categoryLabel: UILabel!
    
    // MARK: - Properties
    var categoryTitle: String = "" {
        didSet {  // Once the categoryTitle is set from the BrewCollectionViewController, and set it to the label
            categoryLabel.text = categoryTitle
        }
    }
}

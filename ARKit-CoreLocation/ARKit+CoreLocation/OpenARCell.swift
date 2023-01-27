//
//  OpenARCell.swift
//  ARKit+CoreLocation
//
//  Created by Eric Internicola on 2/20/19.
//  Copyright © 2019 Project Dent. All rights reserved.
//

import UIKit

@available(iOS 15.0, *)
class OpenARCell: UITableViewCell {

    weak var parentVC: SettingsViewController?
    @IBOutlet weak var openARButton: UIButton!

    @IBAction
    func tappedOpenARButton(_ sender: Any) {
        guard let vc = parentVC?.createARVC() else {
            return assertionFailure("Failed to create ARVC")
        }
        vc.peakValue = parentVC?.peakValue
        vc.peakValueMap  = parentVC?.peakValueMap
        parentVC?.navigationController?.pushViewController(vc, animated: true)
    }

}

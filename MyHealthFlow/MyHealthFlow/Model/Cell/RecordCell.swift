//
//  RecordCell.swift
//  MyHealthFlow
//
//  Created by MyeongSoo-Linne on 08/08/2019.
//  Copyright © 2019 MyeongSoo-Linne. All rights reserved.
//

import UIKit

class RecordCell: UITableViewCell {

    @IBOutlet var title: UILabel!
    @IBOutlet var Record: UILabel!
    @IBOutlet var lastRecordTime: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

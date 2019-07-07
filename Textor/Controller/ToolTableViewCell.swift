//
//  ToolTableViewCell.swift
//  Textor
//
//  Created by Matteo Bart on 7/4/19.
//  Copyright © 2019 Silver Fox. All rights reserved.
//

import UIKit

class ToolTableViewCell: UITableViewCell {

	@IBOutlet weak var toolImage: UIImageView!
	@IBOutlet weak var toolName: UILabel!
	
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

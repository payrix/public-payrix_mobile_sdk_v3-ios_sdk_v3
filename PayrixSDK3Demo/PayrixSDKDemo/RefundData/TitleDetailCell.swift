//
//  TitleDetailCell.swift
//  PayrixMobile
//
//  Created by Prakash KOtwal on 25/01/2022.
//  Copyright © 2022 Payrix. All rights reserved.
//

import UIKit

class TitleDetailCell: UITableViewCell {
  @IBOutlet weak var labelTitle: UILabel!
  @IBOutlet weak var labelDetail: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}

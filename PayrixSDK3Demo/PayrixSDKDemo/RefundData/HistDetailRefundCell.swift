//
//  HistDetailRefundCell.swift
//  PWLCoreApp
//
//  Created by Steve Sykes on 12/19/18.
//  Copyright © 2018 Payrix. All rights reserved.
//

import UIKit

class HistDetailRefundCell: UITableViewCell
{
  @IBOutlet weak var lblRefundAmt: UILabel!
  @IBOutlet weak var lblRefundDate: UILabel!
  @IBOutlet weak var lblRefundID: UILabel!
  
  override func awakeFromNib()
  {
    super.awakeFromNib()
  }
  
  override func setSelected(_ selected: Bool, animated: Bool)
  {
    super.setSelected(selected, animated: animated)
  }
}

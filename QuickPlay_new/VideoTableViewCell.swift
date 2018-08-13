//
//  VideoTableViewCell.swift
//  QuickPlay_new
//
//  Created by dengjiangzhou on 2018/6/18.
//  Copyright © 2018年 dengjiangzhou. All rights reserved.
//

import UIKit

class VideoTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var clipThumbnail: UIImageView!
    @IBOutlet weak var clipName: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

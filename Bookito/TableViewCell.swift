//
//  TableViewCell.swift
//  Bookito
//
//  Created by Katsu on 17/07/2019.
//  Copyright © 2019 Katsu. All rights reserved.
//

import UIKit

// Implementing delegation
protocol cellDelegate {
    func didClickDownloadButton(cell: UITableViewCell)
    func didClickReadButton(cell: UITableViewCell)
}

class TableViewCell: UITableViewCell {
    
    var delegate: cellDelegate?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var readButton: UIButton!
    
    @IBAction func downloadButtonTapped(_ sender: Any) {
        print("download button tapped")
        delegate?.didClickDownloadButton(cell: self )
    }
    
    @IBAction func readButtonTapped(_ sender: Any) {
        print("read button tapped")
        delegate?.didClickReadButton(cell: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // While our book is now downloaded, read button will be disabled
        readButton.isEnabled = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

//
//  StoryboardFolioReaderContrainer.swift
//  Bookito
//
//  Created by Katsu on 17/07/2019.
//  Copyright © 2019 Katsu. All rights reserved.
//

import UIKit
import FolioReaderKit

class StoryboardFolioReaderContrainer: FolioReaderContainer {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let config = FolioReaderConfig()
        config.scrollDirection = .horizontalWithVerticalContent
        
        guard let bookPath = Bundle.main.path(forResource: "The Silver Chair", ofType: "epub") else { return }
        setupConfig(config, epubPath: bookPath)
    }
}

//
//  FeedModel.swift
//  SwiftReader
//
//  Created by Derek Jensen on 1/25/15.
//  Copyright (c) 2015 Derek Jensen. All rights reserved.
//

import UIKit

class FeedModel: NSObject {
    var title: String = String()
    var url: String = String()
    var articles: [ArticleModel] = [ArticleModel]()
}

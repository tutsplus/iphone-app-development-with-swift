//
//  Article.swift
//  SwiftReader
//
//  Created by Derek Jensen on 1/28/15.
//  Copyright (c) 2015 Derek Jensen. All rights reserved.
//

import Foundation
import CoreData

class Article: NSManagedObject {

    @NSManaged var title: String
    @NSManaged var link: String
    @NSManaged var pubDate: String

}

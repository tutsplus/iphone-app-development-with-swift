//
//  AddFeedViewController.swift
//  SwiftReader
//
//  Created by Derek Jensen on 1/28/15.
//  Copyright (c) 2015 Derek Jensen. All rights reserved.
//

import UIKit

class AddFeedViewController: UIViewController {

    
    @IBOutlet weak var feedUrl: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let feedsViewController = segue.destinationViewController as FeedsTableViewController
        
        feedsViewController.AddNewFeed(feedUrl.text)
    }

}

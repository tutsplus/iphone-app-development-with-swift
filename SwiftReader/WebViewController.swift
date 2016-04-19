//
//  WebViewController.swift
//  SwiftReader
//
//  Created by Derek Jensen on 1/20/15.
//  Copyright (c) 2015 Derek Jensen. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {
    
    var article: ArticleModel = ArticleModel()
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = article.title

        let url: NSURL = NSURL(string: article.link)!
        let request: NSURLRequest = NSURLRequest(URL: url)
        
        webView.loadRequest(request)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

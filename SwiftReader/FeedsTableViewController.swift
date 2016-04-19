//
//  FeedsTableViewController.swift
//  SwiftReader
//
//  Created by Derek Jensen on 1/20/15.
//  Copyright (c) 2015 Derek Jensen. All rights reserved.
//

import UIKit
import CoreData

class FeedsTableViewController: UITableViewController, NSXMLParserDelegate {

    var parser: NSXMLParser = NSXMLParser()
    var feedUrl: String = String()
    
    var feedTitle: String = String()
    var articleTitle: String = String()
    var articleLink: String = String()
    var articlePubDate: String = String()
    var parsingChannel: Bool = false
    var eName: String = String()
    
    var feeds: [FeedModel] = []
    var articles: [ArticleModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector("RefreshFeeds"), forControlEvents: .ValueChanged)
        
        self.refreshControl = refreshControl
        
        feeds = GetFeeds()
    }
    
    func RefreshFeeds() {
        for feed in feeds {
            DeleteFeed(feed.url)
        }
        
        var oldFeeds = feeds;
        
        feeds = []
        
        for oldFeed in oldFeeds {
            AddNewFeed(oldFeed.url)
        }
        
        tableView.reloadData()
        
        refreshControl?.endRefreshing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func DeleteFeed(url: String) {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName: "Feed")
        let predicate = NSPredicate(format: "url == %@", url)
        
        fetchRequest.predicate = predicate
        
        var error: NSError?
        let fetchResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as [Feed]?
        
        if(fetchResults?.count == 1) {
            var feed = fetchResults?.first!
            
            managedContext.deleteObject(feed!)
            
            var error: NSError?
            if !managedContext.save(&error) {
                println("Could not save \(error), \(error?.userInfo)")
            }
        }
        
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        var feedModel = feeds[indexPath.row]
        
        DeleteFeed(feedModel.url)
        
        feeds.removeAtIndex(indexPath.row)
        
        tableView.reloadData()
        
    }
    
    func AddNewFeed(url: String) {
        feedUrl = url
        let url: NSURL = NSURL(string: feedUrl)!
        
        parser = NSXMLParser(contentsOfURL: url)!
        parser.delegate = self
        parser.parse()
    }
    
    @IBAction func retrieveNewFeed(segue: UIStoryboardSegue) {}
    
    func SaveFeed(feedModel: FeedModel) {
        if(FeedExists(feedModel.url)) {
            return
        }
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let entity = NSEntityDescription.entityForName("Feed", inManagedObjectContext: managedContext)
        
        let feed = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext) as Feed
        
        feed.title = feedModel.title
        feed.url = feedModel.url
        
        var articles: NSMutableSet = NSMutableSet()
        
        for articleModel in feedModel.articles {
            let entity = NSEntityDescription.entityForName("Article", inManagedObjectContext: managedContext)
            
            let article = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext) as Article
            article.title = articleModel.title
            article.link = articleModel.link
            article.pubDate = articleModel.pubDate
            
            articles.addObject(article)
        }
        
        feed.articles = articles
        
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
        
        feeds.append(feedModel)
        
    }
    
    func FeedExists(url: String) -> Bool  {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName: "Feed")
        let predicate = NSPredicate(format: "url == %@", url)
        
        fetchRequest.predicate = predicate
        
        var error: NSError?
        let fetchResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
        
        if fetchResults!.count > 0 {
            return true
        }
        
        return false
    }
    
    func GetFeeds() -> [FeedModel] {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName: "Feed")
        
        var error: NSError?
        let fetchResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
        
        var feedModels: [FeedModel] = [FeedModel]()
        
        if let results = fetchResults {
            for feed in results as [Feed] {
                var feedModel = FeedModel()
                feedModel.title = feed.title
                feedModel.url = feed.url
                
                var articleModels: [ArticleModel] = [ArticleModel]()
                for article in feed.articles {
                    var articleModel = ArticleModel()
                    articleModel.title = article.title
                    articleModel.link = article.link
                    articleModel.pubDate = article.pubDate
                    
                    articleModels.append(articleModel)
                }
                
                feedModel.articles = articleModels
                
                feedModels.append(feedModel)
            }
        }else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
        
        return feedModels
    }


    func parser(parser: NSXMLParser!, didStartElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!, attributes attributeDict: [NSObject : AnyObject]!) {
        
        eName = elementName
        if elementName == "channel" {
            feedTitle = String()
            articles = []
            parsingChannel = true
        }else if elementName == "item" {
            articleTitle = String()
            articleLink = String()
            articlePubDate = String()
            parsingChannel = false
        }
        
    }
    
    func parser(parser: NSXMLParser!, foundCharacters string: String!) {
        let data = string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        if(!data.isEmpty) {
            if parsingChannel {
                if eName == "title" {
                    feedTitle += data
                }
            }else {
                if eName == "title" {
                    articleTitle += data
                }else if eName == "link" {
                    articleLink += data
                }else if eName == "pubDate" {
                    articlePubDate += data
                }
            }
        }
    }
    
    func parser(parser: NSXMLParser!, didEndElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!) {
        if elementName == "channel" {
            let feed: FeedModel = FeedModel()
            feed.title = feedTitle
            feed.url = feedUrl
            feed.articles = articles
            //feeds.append(feed)
            
            SaveFeed(feed)
        }else if elementName == "item" {
            let article: ArticleModel = ArticleModel()
            article.title = articleTitle
            article.link = articleLink
            article.pubDate = articlePubDate
            articles.append(article)
        }
    }
    

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return feeds.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("FeedCell", forIndexPath: indexPath) as UITableViewCell

        let feed: FeedModel = feeds[indexPath.row]
        cell.textLabel!.text = feed.title

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowArticles" {
            let viewController: ArticlesTableViewController = segue.destinationViewController as ArticlesTableViewController
            let indexPath = self.tableView.indexPathForSelectedRow()!
            let feed = feeds[indexPath.row]
            
            viewController.articles = feed.articles
        }
    }
    

}

//
//  ViewController.swift
//  HelloWorld
//
//  Created by Jameson Quave on 7/26/14.
//  Copyright (c) 2014 JQ Software. All rights reserved.
//

import UIKit

class SearchResultsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, APIControllerProtocol  {
    
    @IBOutlet var appsTableView : UITableView?
    let kCellIdentifier: String = "SearchResultCell"
    var tableData = []
    var api = APIController()

                            
    override func viewDidLoad() {
        super.viewDidLoad()
        self.api.delegate = self
        api.searchItunesFor("Angry Birds")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // The APIControllerProtocol method
    func didReceiveAPIResults(results: NSDictionary) {
        var resultsArr: NSArray = results["results"] as NSArray
        dispatch_async(dispatch_get_main_queue(), {
            self.tableData = resultsArr
            self.appsTableView!.reloadData()
            })
    }

    
    // The protocol methods for UITableViewDataSource and UITableViewDelegate
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }

    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as UITableViewCell
        
        let rowData: NSDictionary = self.tableData[indexPath.row] as NSDictionary
        
        cell.textLabel.text = rowData["trackName"] as String
        
        // Grab the artworkUrl60 key to get an image URL for the app's thumbnail
        let urlString: NSString = rowData["artworkUrl60"] as NSString
        let imgURL: NSURL = NSURL(string: urlString)
        
        // Download an NSData representation of the image at the URL
        let imgData: NSData = NSData(contentsOfURL: imgURL)
        cell.imageView.image = UIImage(data: imgData)
        
        // Get the formatted price string for display in the subtitle
        let formattedPrice: NSString = rowData["formattedPrice"] as NSString
        
        cell.detailTextLabel.text = formattedPrice
        
        return cell
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        // Get the row data for the selected row
        var rowData: NSDictionary = self.tableData[indexPath.row] as NSDictionary
        
        var name: String = rowData["trackName"] as String
        var formattedPrice: String = rowData["formattedPrice"] as String
        
        var alert: UIAlertView = UIAlertView()
        alert.title = name
        alert.message = formattedPrice
        alert.addButtonWithTitle("Ok")
        alert.show()
    }

}


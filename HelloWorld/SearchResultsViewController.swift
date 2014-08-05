//
//  ViewController.swift
//  HelloWorld
//
//  Created by Jameson Quave on 7/26/14.
//  Copyright (c) 2014 JQ Software. All rights reserved.
//

import UIKit
import QuartzCore
class SearchResultsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, APIControllerProtocol  {
    
    @IBOutlet var appsTableView : UITableView?
    let kCellIdentifier: String = "SearchResultCell"
    var albums = [Album]()
    
    lazy var api : APIController = APIController(delegate: self)
    
    var imageCache = [String : UIImage]()

                            
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        api.searchItunesFor("Bob Dylan");
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // The APIControllerProtocol method
    func didReceiveAPIResults(results: NSDictionary) {
        var resultsArr: NSArray = results["results"] as NSArray
        dispatch_async(dispatch_get_main_queue(), {
            self.albums = Album.albumsWithJSON(resultsArr)
            self.appsTableView!.reloadData()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
    }

    
    // The protocol methods for UITableViewDataSource and UITableViewDelegate
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }

    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as UITableViewCell
        
        let album = self.albums[indexPath.row]
        cell.textLabel.text = album.title
        cell.imageView.image = UIImage(named: "Blank52")
        
        // Get the formatted price string for display in the subtitle
        let formattedPrice = album.price
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            // Jump in to a background thread to get the image for this item
            
            // Grab the artworkUrl60 key to get an image URL for the app's thumbnail
            let urlString = album.thumbnailImageURL
            
            // Check our image cache for the existing key. This is just a dictionary of UIImages
            //var image: UIImage? = self.imageCache.valueForKey(urlString) as? UIImage
            var image = self.imageCache[urlString]
            
            if( image == nil ) {
                // If the image does not exist, we need to download it
                var imgURL: NSURL = NSURL(string: urlString)
                
                // Download an NSData representation of the image at the URL
                let request: NSURLRequest = NSURLRequest(URL: imgURL)
                let urlConnection: NSURLConnection = NSURLConnection(request: request, delegate: self)
                NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                    if error == nil {
                        image = UIImage(data: data)
                        
                        // Store the image in to our cache
                        self.imageCache[urlString] = image
                        
                        if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) {
                            cell.imageView.image = image
                        }
                    }
                    else {
                        println("Error: \(error.localizedDescription)")
                    }
                })
                
            }
            else {
                dispatch_async(dispatch_get_main_queue(), {
                    if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) {
                        cell.imageView.image = image
                    }
                })
            }
        })
        
        cell.detailTextLabel.text = formattedPrice
        
        return cell
    }
    
    func tableView(tableView: UITableView!, willDisplayCell cell: UITableViewCell!, forRowAtIndexPath indexPath: NSIndexPath!) {
        cell.layer.transform = CATransform3DMakeScale(0.1,0.1,1)
        UIView.animateWithDuration(0.25, animations: {
            cell.layer.transform = CATransform3DMakeScale(1,1,1)
            })
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject) {
        var detailsViewController: DetailsViewController = segue.destinationViewController as DetailsViewController
        var albumIndex = appsTableView!.indexPathForSelectedRow().row
        var selectedAlbum = self.albums[albumIndex]
        detailsViewController.album = selectedAlbum
    }

}


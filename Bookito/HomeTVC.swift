//
//  HomeTVC.swift
//  Bookito
//
//  Created by Katsu on 17/07/2019.
//  Copyright © 2019 Katsu. All rights reserved.
//

import UIKit
import Alamofire
import MBProgressHUD
import WebKit
import FolioReaderKit
import CoreData

// Actually unsafe URLs like http:/ also will works.
let epubArray = ["https://www.planetebook.com/free-ebooks/moby-dick.epub",
                 "https://www.planetebook.com/free-ebooks/alices-adventures-in-wonderland.epub",
                 "http://www.feedbooks.com/book/2726.epub"]

let folioReader = FolioReader()

class HomeTVC: UITableViewController, cellDelegate {
    
    
    
     var refreshControll: UIRefreshControl!
    
    var titlebook = ""
    
    @IBOutlet var tableview: UITableView!
    var books : [NSManagedObject] = []
    var epub = ""
    // Dict for saveing URL to local file
    var fileLocalURLDict = [Int : String]()

    @objc func refresh(sender:AnyObject) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let persistenceContainer = appDelegate.persistentContainer
        let managedContext = persistenceContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Epub")
        do {
            try books = managedContext.fetch(fetchRequest) as! [NSManagedObject]
        } catch  {
            let nsError = error as NSError
            print(nsError.userInfo)
        }
        self.tableview.reloadData()
        print("reloading ...")
        refreshControll.endRefreshing()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView()
        self.title = "Book Reader"
        refreshControll = UIRefreshControl()
        refreshControll.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControll.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableview.addSubview(refreshControll)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let persistenceContainer = appDelegate.persistentContainer
        let managedContext = persistenceContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Epub")
        do {
            try books = managedContext.fetch(fetchRequest) as! [NSManagedObject]
        } catch  {
            let nsError = error as NSError
            print(nsError.userInfo)
        }

    }
   
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return books.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        // Configure the cell...
        self.epub = (books[indexPath.row].value(forKey: "book")  as? String)!
        //let newString = self.epub.components(separatedBy: "/").last!.replacingOccurrences(of: "\n", with: "")
        cell.nameLabel.text = (books[indexPath.row].value(forKey: "name")  as? String)!
        cell.delegate = self
        cell.selectionStyle = .none
        return cell
    }
    

    
    //MARK: - Custom cell delegate methods
    func didClickDownloadButton(cell: UITableViewCell) {
        let indexPath = self.tableView.indexPath(for: cell)
        print(indexPath?.row ?? "")
    
        if let index = indexPath?.row {
            
            (cell as! TableViewCell).readButton.isEnabled = true
            downloadFileWithIndex(ind: index)
        }
    }
    
    // FolioReader open file func
 
    func didClickReadButton(cell: UITableViewCell) {
        let indexPath = self.tableView.indexPath(for: cell)
        print(indexPath?.row ?? "")
        
        if let index = indexPath?.row {
            
            let config = FolioReaderConfig()
            let bookPath : String! = fileLocalURLDict[index]
            folioReader.presentReader(parentViewController: self, withEpubPath: bookPath!, andConfig: config)
        }
    }
    
    //MARK: - Downloading method
    func downloadFileWithIndex(ind: Int) {
        
        // Implementing the logic for MBProgressHUD
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = MBProgressHUDMode.annularDeterminate
        hud.label.text = "Loading..."
        
        // Downloading files from hardcoded URL epubArray using Alamofire
        let urlString = (books[ind].value(forKey: "book")  as? String)!
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let documentsURL: NSURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as NSURL
            print("***documentURL: ", documentsURL)
            let fileURL = documentsURL.appendingPathComponent("\(ind).epub")
            print("***fileURL: ", fileURL ?? "")
            return (fileURL!, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        Alamofire.download(urlString, to: destination).downloadProgress(closure: { (prog) in
            hud.progress = Float(prog.fractionCompleted)
        }).response { response in
            //print(response)
            
            // When download is complete, hide the progress hud
            hud.hide(animated: true)
            
            if response.error == nil, let filePath = response.destinationURL?.path {
                //let image = UIImage(contentsOfFile: imagePath)
                print("mmmm", filePath)
                self.fileLocalURLDict[ind] = filePath
            }
        }
    }
}

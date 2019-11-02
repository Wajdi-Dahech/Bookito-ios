//
//  SavedViewController.swift
//  Bookito
//
//  Created by Katsu on 15/07/2019.
//  Copyright © 2019 Katsu. All rights reserved.
//

import UIKit
import CoreData
import AlamofireImage

class SavedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var refreshControl: UIRefreshControl!
     var seasons : [NSManagedObject] = []
    
    @IBOutlet weak var tableview: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return seasons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        let contentView = cell?.viewWithTag(0)
        let img = contentView?.viewWithTag(1) as! UIImageView
        let titre = contentView?.viewWithTag(2) as! UILabel
        let author = contentView?.viewWithTag(3) as! UILabel
        //img.image = UIImage(named: seasons[indexPath.row].value(forKey: "imgBook") as! String)
        img.af_setImage(withURL: URL(string: seasons[indexPath.row].value(forKey: "imgBook") as! String)!)
        titre.text = seasons[indexPath.row].value(forKey: "titleBook") as? String
        author.text = seasons[indexPath.row].value(forKey: "authorBook") as? String
        return cell!
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete){
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let persistenceContainer = appDelegate.persistentContainer
            let managedContext = persistenceContainer.viewContext
            managedContext.delete(seasons[indexPath.row])
            do {
                try managedContext.save()
                seasons.remove(at: indexPath.row)
                tableView.reloadData()
                print ("removed")
            }catch let nsError as NSError
            {
                print(nsError.userInfo)
            }
        }
    }
    @objc func refresh(sender:AnyObject) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let persistenceContainer = appDelegate.persistentContainer
        let managedContext = persistenceContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BookFav")
        do {
            try seasons = managedContext.fetch(fetchRequest) as! [NSManagedObject]
        } catch  {
            let nsError = error as NSError
            print(nsError.userInfo)
        }
        self.tableview.reloadData()
        print("reloading ...")
        refreshControl.endRefreshing()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableview.addSubview(refreshControl)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let persistenceContainer = appDelegate.persistentContainer
        let managedContext = persistenceContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BookFav")
        do {
            try seasons = managedContext.fetch(fetchRequest) as! [NSManagedObject]
        } catch  {
            let nsError = error as NSError
            print(nsError.userInfo)
        }

        
      
        // Do any additional setup after loading the view.
    }
    
 
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//
//  HomeViewController.swift
//  Bookito
//
//  Created by Katsu on 16/07/2019.
//  Copyright © 2019 Katsu. All rights reserved.
//

import UIKit
import AlamofireImage
import Alamofire
import SwiftyXMLParser
import GoogleSignIn
class HomeViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource {
    
    
    
   
    
    var refreshControl: UIRefreshControl!
    
    @IBOutlet weak var logout: UIBarButtonItem!
    
    
    @IBAction func logout(_ sender: Any) {
        GIDSignIn.sharedInstance().signOut()
        performSegue(withIdentifier: "tologin", sender: IndexPath.self)
    }
    
    @IBOutlet weak var collectionview: UICollectionView!
    
    @IBOutlet weak var seg: UISegmentedControl!
    var books: [SimilarBooks] = []
    var tvShowArray : NSArray = []
    var yourArray = [String]()
    var bookid = ""
    var sbookid = ""
    var rev = ""
    @IBOutlet weak var tableview: UITableView!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return books.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: UICollectionViewCell?
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell1", for: indexPath)
        let bookImg = cell?.viewWithTag(1) as! UIImageView
        // bookImg.image = UIImage(named:images[indexPath.row])
        bookImg.af_setImage(withURL: URL(string: books[indexPath.row].artworkLargeURL)!)
        //print(books[indexPath.row].artworkLargeURL)
       
        cell!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap(_:))))
        return cell!;
    }
    
    
    
    
    @objc func tap(_ sender: UITapGestureRecognizer) {
        
        let location = sender.location(in: self.collectionview)
        let indexPath = self.collectionview.indexPathForItem(at: location)
        
        if let index = indexPath {
            print("Got clicked on index: \(index)!")
            print(books[indexPath!.row].bookId)
            sbookid = String(books[indexPath!.row].bookId)
             performSegue(withIdentifier: "toDetail", sender: indexPath)
            
            //self.viewDidLoad()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return tvShowArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        let contentView = cell?.viewWithTag(0)
        let img = contentView?.viewWithTag(1) as! UIImageView
        let username = contentView?.viewWithTag(2) as! UILabel
        let feedback = contentView?.viewWithTag(3) as! UITextView
        let imgbook = contentView?.viewWithTag(4) as! UIImageView
        let title = contentView?.viewWithTag(5) as! UILabel
        let author = contentView?.viewWithTag(6) as! UILabel
        img.layer.borderWidth = 1
        img.layer.masksToBounds = false
        img.layer.borderColor = UIColor.white.cgColor
        img.layer.cornerRadius = img.frame.height/2
        img.clipsToBounds = true
        let tvShowDict = tvShowArray[indexPath.row] as! Dictionary<String, Any>
        username.text = tvShowDict["username"] as? String
        
        feedback.text = tvShowDict["feedback"] as? String
        self.bookid = (tvShowDict["idbook"] as? String)!
        yourArray.append((tvShowDict["idbook"] as? String)!)
        Alamofire.request("https://www.goodreads.com/book/show/"+bookid+".xml?key=OscrxLbmwaVpi74xFhZVw")
            .responseData { response in
                if let data = response.data {
                    let xml = XML.parse(data)
                    // print(xml.GoodreadsResponse.search.results.work[0].best_book.title.text!) // outputs the top title of iTunes app raning.
                    //self.resultsEnd = Int(xml.GoodreadsResponse.search.results-end.text!)!
                   // print(xml.GoodreadsResponse.search.results.work[0].best_book.id.text!)
                     imgbook.af_setImage(withURL: URL(string: xml.GoodreadsResponse.book.image_url.text!)!)
                      title.text = xml.GoodreadsResponse.book.title.text!
                     author.text = (xml["GoodreadsResponse", "book", "authors","author",0,"name"].text!)
                }
        }
        
        let imgs = tvShowDict["image"] as? String
        //print(titre.text)
        //print(imgs)
        //print("-------------")
        img.af_setImage(withURL: URL(string: imgs!)!)
        
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toDetails", sender: indexPath) //appelle PrepareForSegue automatiquement
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetails"{
            let destination = segue.destination as! DetailsViewController
            let indice = sender as! IndexPath
           // let book = books[indice.row]
            destination.bookid = yourArray[indice.row]
            
        }
        else if segue.identifier == "toDetail"{
            print(sbookid)
            print(sbookid)
            let destination = segue.destination as! DetailsViewController
            //let indice = sender as! IndexPath
            // let book = books[indice.row]
            
            destination.bookid = sbookid
            
        }
    }
    
     var id = 0
    var userid = 0
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var review: UITextField!
    @IBOutlet weak var bookname: UITextField!
    @IBOutlet weak var submit: UIButton!
    @IBAction func submit(_ sender: Any) {
        print(bookname.text!)
        print("//////////////")
        print(review.text!)
        self.rev = review.text!
        let newString = bookname.text!.replacingOccurrences(of: " ", with: "%20")
        Alamofire.request("https://www.goodreads.com/search/index.xml?key=OscrxLbmwaVpi74xFhZVw&q="+newString)
            .responseData { response in
                if let data = response.data {
                    let xml = XML.parse(data)
                    // print(xml.GoodreadsResponse.search.results.work[0].best_book.title.text!) // outputs the top title of iTunes app raning.
                    //self.resultsEnd = Int(xml.GoodreadsResponse.search.results-end.text!)!
                    print(xml.GoodreadsResponse.search.results.work[0].best_book.id.text!)
                    self.id = Int(xml.GoodreadsResponse.search.results.work[0].best_book.id.text!)!
                    
                    
                    let parameters1: Parameters=[
                        
                        "email":UserDefaults.standard.string(forKey: "useremail")!
                        
                    ]
                    
                    Alamofire.request("http://localhost:8888/Bookito/user.php", method: .post, parameters: parameters1).responseString
                        
                        {
                            
                            response in
                            
                            //printing response
                            
                            print(response)
                            self.userid = Int(response.value!)!
                            
                            let parameters: Parameters=[
                                
                                "feedback":self.rev,
                                
                                "iduser":self.userid,
                                
                                "idbook":self.id,
                                
                                
                                
                                
                                
                                ]
                            
                            Alamofire.request("http://localhost:8888/Bookito/add_feedback.php", method: .post, parameters: parameters).responseString
                                
                                {
                                    
                                    response in
                                    
                                    //printing response
                                    
                                    print(response)
                                    
                                    print("ADDED SUCCESSFULY")
                                    
                            }
                            print("User ")
                            
                    }
                }
        }
   
        
        bookname.text = ""
        review.text = ""
       
     
    }
    
    
    @IBAction func seg(_ sender: Any) {
        let title = seg.titleForSegment(at: seg.selectedSegmentIndex)
        
    
            
            if(title == "New Releases") {
                if(books.count != 0){
                    books.removeAll()
                }
                
                Alamofire.request("https://www.goodreads.com/review/list/90102710.xml?key=OscrxLbmwaVpi74xFhZVw&v=2&shelf=new&per_page=200&page=1")
                    .responseData { response in
                        if let data = response.data {
                            let xml = XML.parse(data)
                            
                            for index in 0...7 {
                                
                                let book = SimilarBooks()
                                book.bookId = Int(xml.GoodreadsResponse.reviews.review[index].book.id.text!)!
                                book.artworkLargeURL = xml.GoodreadsResponse.reviews.review[index].book.image_url.text!
                                self.books.append(book)
                            }
                            
                            self.collectionview.reloadData()
                        }
                }
                
                print("New Releases")
            }
            else if(title == " Choice Awards") {
                
                if(books.count != 0){
                    books.removeAll()
                }
                Alamofire.request("https://www.goodreads.com/review/list/90102710.xml?key=OscrxLbmwaVpi74xFhZVw&v=2&shelf=best-books&per_page=200&page=1")
                    .responseData { response in
                        if let data = response.data {
                            let xml = XML.parse(data)
                            
                            for index in 0...12 {
                                
                                let book = SimilarBooks()
                                book.bookId = Int(xml.GoodreadsResponse.reviews.review[index].book.id.text!)!
                                book.artworkLargeURL = xml.GoodreadsResponse.reviews.review[index].book.image_url.text!
                                self.books.append(book)
                            }
                            
                            self.collectionview.reloadData()
                        }
                }
                print(" Choice Awards")
                
            }
        
    }
    
    @objc func refresh(sender:AnyObject) {
        print("irmhere")
        if(yourArray.count != 0){
            yourArray.removeAll()
        }
        Alamofire.request("http://localhost:8888/Bookito/getall_feedback.php").responseJSON{ response in
            self.tvShowArray = response.result.value as! NSArray
            
            self.tableview.reloadData()
            // Do any additional setup after loading the view.
        }
        //self.tableview.reloadData()
        print("reloading ...")
        refreshControl.endRefreshing()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
      submit.layer.cornerRadius = 4
        image.layer.borderWidth = 1
        image.layer.masksToBounds = false
        image.layer.borderColor = UIColor.white.cgColor
        image.layer.cornerRadius = image.frame.height/2
        image.clipsToBounds = true
        image.af_setImage(withURL: URL(string: UserDefaults.standard.string(forKey: "userimage")!)!)
        name.text = UserDefaults.standard.string(forKey: "username")!
        
        print(UserDefaults.standard.string(forKey: "username")!)
        print("*-----")
        print(UserDefaults.standard.string(forKey: "userimage")!)
        
        Alamofire.request("http://localhost:8888/Bookito/getall_feedback.php").responseJSON{ response in
            self.tvShowArray = response.result.value as! NSArray
            
            self.tableview.reloadData()
        // Do any additional setup after loading the view.
    }
        Alamofire.request("https://www.goodreads.com/review/list/90102710.xml?key=OscrxLbmwaVpi74xFhZVw&v=2&shelf=new&per_page=200&page=1")
            .responseData { response in
                if let data = response.data {
                    let xml = XML.parse(data)
                    
                    for index in 0...7 {
                       
                            let book = SimilarBooks()
                            book.bookId = Int(xml.GoodreadsResponse.reviews.review[index].book.id.text!)!
                            book.artworkLargeURL = xml.GoodreadsResponse.reviews.review[index].book.image_url.text!
                            self.books.append(book)
                    }
                    
                    self.collectionview.reloadData()
                }
        }
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableview.addSubview(refreshControl)
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

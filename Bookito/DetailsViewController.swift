//
//  DetailsViewController.swift
//  Bookito
//
//  Created by Katsu on 16/07/2019.
//  Copyright © 2019 Katsu. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import AlamofireImage
import SwiftyXMLParser
class DetailsViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {
    
    var epubs : [NSManagedObject] = []
    var epubbook = ""
    var epubname = ""
    @IBOutlet weak var download: UIButton!
    
    @IBAction func download(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let persistanceContainer = appDelegate.persistentContainer
        let managedContext = persistanceContainer.viewContext
        let predicateRequest = NSPredicate(format: "book == %@", epubbook) // %@ : string, %f : float, %d : int
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Epub")
        fetchRequest.predicate = predicateRequest
        
        
        do{
            try epubs = managedContext.fetch(fetchRequest) as! [NSManagedObject]
            if epubs.count == 0 {
                let entity = NSEntityDescription.entity(forEntityName: "Epub", in: managedContext)
                let Season = NSManagedObject(entity: entity!, insertInto: managedContext)
                Season.setValue(epubbook, forKey: "book")
                Season.setValue(epubname, forKey: "name")
                print(epubbook)
                print("*******")
                try managedContext.save()
                print("Book downloaded")
            }else{
                let alert = UIAlertController(title: "Alert", message: "Book already downloaded", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        }catch {
            let nsError = error as NSError
            print(nsError.userInfo)
        }
    }
    @IBOutlet weak var amazon: UIButton!
    
    @IBAction func amazon(_ sender: Any) {
        UIApplication.shared.openURL(NSURL(string: "https://www.goodreads.com/buy_buttons/12/follow?book_id="+bookid!)! as URL)
        
    }
    
    
    @IBOutlet weak var GoodReads: UIButton!
    
    
    @IBAction func GoodReads(_ sender: Any) {
        
           
        performSegue(withIdentifier: "toGoodReads", sender: sender)
        
    }
    
    @IBOutlet weak var Bookito: UIButton!
    
    
    @IBAction func Bookito(_ sender: Any) {
        
        performSegue(withIdentifier: "toBookito", sender: sender)
    }
    
    
    
    
    let images = ["1","2","3","4","5","6","7"]
    var books: [SimilarBooks] = []
    var bookTitle = ""
    var bookAuthor = ""
    var imageUrl = ""
    var id = ""
    var authorImg = "https://images.gr-assets.com/authors/1261104499p5/15337.jpg"
    var seasons : [NSManagedObject] = []
    @IBAction func heart(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let persistanceContainer = appDelegate.persistentContainer
        let managedContext = persistanceContainer.viewContext
        let predicateRequest = NSPredicate(format: "idBook == %@", bookid!) // %@ : string, %f : float, %d : int
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BookFav")
        fetchRequest.predicate = predicateRequest
        
        
        do{
            try seasons = managedContext.fetch(fetchRequest) as! [NSManagedObject]
            if seasons.count == 0 {
                let entity = NSEntityDescription.entity(forEntityName: "BookFav", in: managedContext)
                let Season = NSManagedObject(entity: entity!, insertInto: managedContext)
                Season.setValue(bookAuthor, forKey: "authorBook")
                 Season.setValue(bookTitle, forKey: "titleBook")
                 Season.setValue(imageUrl, forKey: "imgBook")
                 Season.setValue(bookid, forKey: "idBook")
                try managedContext.save()
                print("Book saved")
            }else{
                let alert = UIAlertController(title: "Alert", message: "Book already exists", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        }catch {
            let nsError = error as NSError
            print(nsError.userInfo)
        }
        heart.setImage(UIImage(named: "heartfill"), for: .normal)
    }
    @IBOutlet weak var heart: UIButton!
    @IBOutlet weak var collectionview: UICollectionView!
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
        print("0400000")
        cell!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap(_:))))
        return cell!;
    }
    
    @objc func tap(_ sender: UITapGestureRecognizer) {
        
        let location = sender.location(in: self.collectionview)
        let indexPath = self.collectionview.indexPathForItem(at: location)
        
        if let index = indexPath {
            print("Got clicked on index: \(index)!")
            print(books[indexPath!.row].bookId)
           // performSegue(withIdentifier: "toDetails", sender: indexPath!.row)
            bookid = String(books[indexPath!.row].bookId)
            self.viewDidLoad()
        }
    }

     var bookid:String?
     var bookDescription:String?
    let undesirableDescriptionStringReplacements =
        [
            "<i>": "\"",
            "</i>" : "\"",
            "<br />" : "\n",
            "<em>" : "",
            "</em>" : "",
            "&amp;" : "&",
            "&apos;" : "'",
            "&quot;" : "\"",
            "&lt;" : "<",
            "&gt;" : ">",
            "&nbsp;" : " ",
            "<a>" : "",
            "</a>" : "",
            "<b>" : "",
            "</b>" : ""
    ]
    let undesirableImageStringReplacements =
        [
            "<![CDATA[": "",
            "]]>" : ""
    ]
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        amazon.layer.cornerRadius = 4
        download.layer.cornerRadius = 4
         GoodReads.layer.cornerRadius = 4
         Bookito.layer.cornerRadius = 4
        amazon.addTarget(self, action: "amazon", for: .touchUpInside)
        if(books.count != 0){
            books.removeAll()
        }
        heart.setImage(UIImage(named: "heartempty"), for: .normal)
        
        Alamofire.request("https://www.goodreads.com/book/show/"+bookid!+".xml?key=OscrxLbmwaVpi74xFhZVw")
            
            .responseData { response in
                if let data = response.data {
                    let xml = XML.parse(data)
                     print(xml.GoodreadsResponse.book.title.text!)
                      self.epubname = xml.GoodreadsResponse.book.title.text!
                    // outputs the top title of iTunes app raning.
                    //self.resultsEnd = Int(xml.GoodreadsResponse.search.results-end.text!)!
                    let img = self.view?.viewWithTag(1) as! UIImageView
                    let titre = self.view?.viewWithTag(2) as! UILabel
                    let author = self.view?.viewWithTag(3) as! UILabel
                    let rating = self.view?.viewWithTag(4) as! UILabel
                    let description = self.view?.viewWithTag(5) as! UITextView
                    let imgAuth = self.view?.viewWithTag(6) as! UIImageView
                    imgAuth.layer.borderWidth = 1
                   imgAuth.layer.masksToBounds = false
                   imgAuth.layer.borderColor = UIColor.black.cgColor
                   imgAuth.layer.cornerRadius = imgAuth.frame.height/2
                   imgAuth.clipsToBounds = true
                    titre.text = xml.GoodreadsResponse.book.title.text!
                    self.bookTitle = xml.GoodreadsResponse.book.title.text!
                    
                self.authorImg = (xml["GoodreadsResponse", "book", "authors","author",0,"image_url"].text!)
                   // self.authorImg = self.authorImg.Replace("![CDATA[","").Replace("]]","");
                    //self.authorImg = self.authorImg.replacingOccurrences(of: "<![CDATA[", with: "")
                    //self.authorImg = self.authorImg.replacingOccurrences(of: "]]>", with: "")
                    print(self.authorImg)
                    let trimmedString = self.authorImg.trimmingCharacters(in: .whitespaces)
                    let newString = trimmedString.replacingOccurrences(of: "\n", with: "")
                   imgAuth.af_setImage(withURL: URL(string: newString)!)
                   img.af_setImage(withURL: URL(string: xml.GoodreadsResponse.book.image_url.text!)!)
                   self.imageUrl = xml.GoodreadsResponse.book.image_url.text!
                    author.text = (xml["GoodreadsResponse", "book", "authors","author",0,"name"].text!)
                    self.bookAuthor = (xml["GoodreadsResponse", "book", "authors","author",0,"name"].text!)
                    rating.text = xml.GoodreadsResponse.book.average_rating.text!
                    self.bookDescription = (xml["GoodreadsResponse", "book", "description"].text!)
                    for keyValue in self.undesirableDescriptionStringReplacements {
                        self.bookDescription = self.bookDescription?.replacingOccurrences(of: keyValue.key, with: keyValue.value)
                    }
                    
                    description.text = self.bookDescription
                    
                    for index in 0...9 {
                        if(xml.GoodreadsResponse.book.similar_books.book[index].title.text != nil)
                        {
                            
                        let book = SimilarBooks()
                        book.bookId = Int(xml.GoodreadsResponse.book.similar_books.book[index].id.text!)!
                        book.artworkLargeURL = xml.GoodreadsResponse.book.similar_books.book[index].image_url.text!
                        self.books.append(book)
                            
                        }
                        
                        
                    }
                    if(xml.GoodreadsResponse.book.public_document.text != nil)
                    {
                        self.download.isHidden = false
                        
                        //self.epubbook = xml.GoodreadsResponse.book.public_document.document_url.text!
                        let trimmedString = xml.GoodreadsResponse.book.public_document.document_url.text!.trimmingCharacters(in: .whitespaces)
                        let newString = trimmedString.replacingOccurrences(of: "\n", with: "")
                        self.epubbook = newString.trimmingCharacters(in: .whitespaces)
                        
                    } else  {
                        self.download.isHidden = true
                        
                       
                        
                    }
                    self.collectionview.reloadData()
                    
                    
                }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toGoodReads"{
            let destination = segue.destination as! GoodReadsViewController
            destination.id = bookid
            
           
            
        }
        else if segue.identifier == "toBookito"{
            let destination = segue.destination as! BookitoViewController
            destination.id = bookid
              }
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

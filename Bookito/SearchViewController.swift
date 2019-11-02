//
//  SearchViewController.swift
//  Bookito
//
//  Created by Katsu on 15/07/2019.
//  Copyright © 2019 Katsu. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import SwiftyXMLParser

class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var tableview: UITableView!
    var bookArray : NSArray = []
    var books: [Books] = []
    var bookTitle = ""
    var bookAuthor = ""
    var imageUrl = ""
    var id = 0
    var resultsEnd = 0
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return books.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        let contentView = cell?.viewWithTag(0)
        let img = contentView?.viewWithTag(1) as! UIImageView
        let titre = contentView?.viewWithTag(2) as! UILabel
        let author = contentView?.viewWithTag(3) as! UILabel
        
        let book = books[indexPath.row]
        titre.text = book.bookTitle
        let imgs = book.artworkLargeURL
        img.af_setImage(withURL: URL(string: imgs)!)
        author.text = book.bookAuthor
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toDetails", sender: indexPath) //appelle PrepareForSegue automatiquement
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetails"{
            let destination = segue.destination as! DetailsViewController
            let indice = sender as! IndexPath
            let book = books[indice.row]
            destination.bookid = String(book.bookId)
           
        }
    }
    @IBOutlet weak var SearchBar: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    func searchBarSearchButtonClicked( _ searchBar: UISearchBar)
    {
        let search = (string: searchBar.text!)
      	
        print(search.string)
        let newString = search.string.replacingOccurrences(of: " ", with: "%20")
        if(books.count != 0){
           books.removeAll()
             }
        Alamofire.request("https://www.goodreads.com/search/index.xml?key=OscrxLbmwaVpi74xFhZVw&q="+newString)
            .responseData { response in
                if let data = response.data {
                    let xml = XML.parse(data)
                   // print(xml.GoodreadsResponse.search.results.work[0].best_book.title.text!) // outputs the top title of iTunes app raning.
                    //self.resultsEnd = Int(xml.GoodreadsResponse.search.results-end.text!)!
                    self.resultsEnd = Int(xml["GoodreadsResponse", "search", "results-end"].text!)!
                    if(self.resultsEnd >= 10 ){
                        for index in 0...9 {
                            print(xml.GoodreadsResponse.search.results.work[index].best_book.title.text as Any)
                            let book = Books()
                            book.bookTitle = xml.GoodreadsResponse.search.results.work[index].best_book.title.text!
                            book.bookAuthor = (xml["GoodreadsResponse", "search", "results","work",index,"best_book","author","name"].text!)
                            book.artworkLargeURL = xml.GoodreadsResponse.search.results.work[index].best_book.image_url.text!
                            book.bookId = Int(xml.GoodreadsResponse.search.results.work[index].best_book.id.text!)!
                            self.books.append(book)
                        }
                         }
                    else{
                        for index in 0...self.resultsEnd {
                            print(xml.GoodreadsResponse.search.results.work[index].best_book.title.text!)
                            let book = Books()
                            book.bookTitle = xml.GoodreadsResponse.search.results.work[index].best_book.title.text!
                            book.bookAuthor = (xml["GoodreadsResponse", "search", "results","work",index,"best_book","author","name"].text!)
                            book.artworkLargeURL = xml.GoodreadsResponse.search.results.work[index].best_book.image_url.text!
                            book.bookId = Int(xml.GoodreadsResponse.search.results.work[index].best_book.id.text!)!
                            self.books.append(book)
                        }
                    }
                    print(self.resultsEnd)
                    for book in self.books {
                        print(book.bookTitle)
                        print(book.bookAuthor)
                        print(book.artworkLargeURL)
                        print("--------------")
                    }
                    self.tableview.reloadData()
                }
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

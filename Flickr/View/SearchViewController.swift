//
//  SearchViewController.swift
//  Flickr
//
//  Created by Vino (Vinodha) Sundaramoorthy on 11/15/18.
//  Copyright © 2018 Flickr. All rights reserved.
//

import UIKit

class SearchViewController:UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,UISearchControllerDelegate {

    @IBOutlet weak var searchResultTableView : UITableView!
    @IBOutlet weak var searchBar :UISearchBar!
    @IBOutlet weak var messageText : UILabel!
    @IBOutlet weak var activityIndicator : UIActivityIndicatorView!
    
    var searchResult : [FlickrModel] = [FlickrModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "Flickr Search"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Actions

    func clearSearchBar() {
        searchResult.removeAll(keepingCapacity: false);
        searchBar.resignFirstResponder()
        
        searchResultTableView.reloadData()
        self.searchResultTableView.isHidden = false

        self.messageText.isHidden = true
        self.messageText.text = ""
        self.title = "Flickr Search"
    }
    
    @IBAction func resetSearch(sender: AnyObject) {
        searchBar.text = ""
        self.clearSearchBar()
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResult.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let searchResultCellIdentifier = "kSearchResultCell"
        let cell = self.searchResultTableView.dequeueReusableCell(withIdentifier: searchResultCellIdentifier, for: indexPath as IndexPath) as? SearchResultCell
        cell!.setupWithPhoto(model: searchResult[indexPath.row])
        return cell!
    }

    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Show image in full screen mode
         let cell = tableView.cellForRow(at: indexPath) as? SearchResultCell
        imageTapped((cell?.resultImage)!)
    }

    // MARK: - UISearchBarDelegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            self.clearSearchBar()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        performSearchWithText(searchText: searchBar.text!)
    }
    
    // MARK: - ImageTap feature
    
    func imageTapped(_ imageView:UIImageView) {
        let newImageView = UIImageView(image: imageView.image)
        newImageView.frame = UIScreen.main.bounds
        newImageView.backgroundColor = .black
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(tap)
        self.view.addSubview(newImageView)
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        sender.view?.removeFromSuperview()
    }
    
    // MARK: - Private

    private func performSearchWithText(searchText: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        activityIndicator.startAnimating()
        FlickrServices.getPhotosForText(searchText, onCompletion: { (error: NSError?, flickrPhotos: [FlickrModel]?) -> Void in
            if error == nil {
                self.searchResult = flickrPhotos!
            } else {
                self.searchResult = []
                if (error!.code == FlickrServices.Errors.invalidAccessErrorCode) {
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.showErrorAlert()
                    })
                }
            }
            DispatchQueue.main.async(execute: { () -> Void in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.title = searchText
                self.searchResultTableView.reloadData()
                self.activityIndicator.stopAnimating()
                let noResult = self.searchResult.count == 0 ? true : false
                if noResult {
                    self.messageText.isHidden = false
                    self.messageText.text = "No image found. Please try a different search."
                    self.searchResultTableView.isHidden = true
                } else {
                    self.messageText.isHidden = true
                    self.messageText.text = ""
                    self.searchResultTableView.isHidden = false
                }
            })
        })
    }
    
    private func showErrorAlert() {
        let alertController = UIAlertController(title: "Search Error", message: "Invalid API Key", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alertController.addAction(dismissAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}


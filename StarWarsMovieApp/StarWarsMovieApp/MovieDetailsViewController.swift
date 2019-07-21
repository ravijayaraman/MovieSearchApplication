//
//  MovieDetailsViewController.swift
//  StarWarsMovieApp
//
//  Created by Tonatiuh C on 20/7/19.
//  Copyright © 2019 Ravi Jayaraman. All rights reserved.
//

import UIKit

///This lass contains all the code for the detail view controller after the details are fetched from the API
class MovieDetailsViewController: UIViewController {
    
    /// Outlets required in this viewcontroller
    @IBOutlet weak var tblViwMovieDetails: UITableView!
    @IBOutlet weak var lblError: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var cHeightBtnBack: NSLayoutConstraint!
    
    /// Variables required in this view controller
    var dataDetails: [movieModel]?
    var strError: String?
    
    // MARK: View controller lifecycle
    /// Lifecycle for view controller when the view is loaded into the memory
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupButtonConfig()
        checkViewConfig()
    }
    
    /// Function defined to effectively change the UI based on the API data
    func checkViewConfig() {
        
        //Check if there is error
        if let strError = strError {
            lblError.text = strError
            tblViwMovieDetails.isHidden = true
            lblError.isHidden = false
        }
        else {
            lblError.isHidden = true
            movieTableConfig()
        }
    }
    
    /// Function to define the button configurtion required for iPhone and iPad
    func setupButtonConfig() {
        btnBack.addTarget(self, action: #selector(btnBackTapped), for: .touchUpInside)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            cHeightBtnBack.constant = (self.view.frame.width * 0.6) / 5
        }
        else {
            cHeightBtnBack.constant = (self.view.frame.width - 40) / 5
        }
        
        btnBack.layer.cornerRadius = btnBack.frame.height * 0.1
        btnBack.layer.masksToBounds = true
    }
    
    /// Function for setting up the tableview controller
    func movieTableConfig() {
        tblViwMovieDetails.isHidden = false
        tblViwMovieDetails.delegate = self
        tblViwMovieDetails.dataSource = self
        tblViwMovieDetails.backgroundColor = .clear
        tblViwMovieDetails.estimatedRowHeight = UITableView.automaticDimension
    }
    
    /// Action for back button tapped
    ///
    /// - Parameter button: UIButton
    @IBAction func btnBackTapped(button: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
}

// MARK: - Extension for delegate and datasource for tableview
extension MovieDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataDetails?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath)
        
        cell.textLabel?.text = dataDetails?[indexPath.row].name ?? ""
        cell.detailTextLabel?.text = dataDetails?[indexPath.row].description ?? ""
        cell.selectionStyle = .none
        
        return cell
    }
}

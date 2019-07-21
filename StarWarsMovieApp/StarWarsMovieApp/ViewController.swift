//
//  ViewController.swift
//  StarWarsMovieApp
//
//  Created by Tonatiuh C on 20/7/19.
//  Copyright © 2019 Ravi Jayaraman. All rights reserved.
//

import UIKit

/// Class that loads initially when the app launches
class ViewController: UIViewController {

    /// Variables used in this view controller are defined here
    var viwActIndicatorLoader = UIActivityIndicatorView()
    
    /// Outlets from the storyboard for different elements are linked here
    @IBOutlet weak var cWidthStackView: NSLayoutConstraint!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var txtSearchBox: UITextField!
    @IBOutlet weak var cHeightBtnSend: NSLayoutConstraint!
    
    // MARK: UIViewconrtoller lifecycle
    /// View did load life cycle for view controller
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupButtonConfig()
        activityIndicatorConfig()
        setupTextFieldConfig()
        setupStackView()
    }
    
    /// Function defined to setup the stack view based on the type of device either iPad or iPhone
    func setupStackView() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            cWidthStackView.constant = self.view.frame.width * 0.55
            cHeightBtnSend.constant = (self.view.frame.width * 0.6) / 5
        }
        else {
            cWidthStackView.constant = self.view.frame.width * 0.85
            cHeightBtnSend.constant = (self.view.frame.width - 40) / 5
        }
    }
    
    /// Function defined for configuring the buttons in this view controller
    func setupButtonConfig() {
        btnSend.addTarget(self, action: #selector(btnSendTapped), for: .touchUpInside)
        btnSend.layer.cornerRadius = btnSend.frame.height * 0.1
        btnSend.layer.masksToBounds = true
    }
    
    /// Function for setting up the textfield and setting the default value "Star Wars"
    func setupTextFieldConfig() {
        txtSearchBox.text = "Star Wars"
    }

    /// Configuration for loader in this view controller during the API call
    func activityIndicatorConfig() {
        viwActIndicatorLoader.color = .black
        viwActIndicatorLoader.hidesWhenStopped = true
        viwActIndicatorLoader.style = .gray
        viwActIndicatorLoader.center = self.view.center
        self.view.addSubview(viwActIndicatorLoader)
    }
    
    /// Function called when the loader needs to be displayed before a network call
    func startLoader() {
        viwActIndicatorLoader.startAnimating()
        btnSend.isUserInteractionEnabled = false
        txtSearchBox.isUserInteractionEnabled = false
    }
    
    /// Function defined and can be called when the delegate from the netwrok API call is returned
    func endLoader() {
        viwActIndicatorLoader.stopAnimating()
        btnSend.isUserInteractionEnabled = true
        txtSearchBox.isUserInteractionEnabled = true
    }
    
    /// Action for the send button on this view controller
    ///
    /// - Parameter button: UIBUtton
    @IBAction func btnSendTapped(button: UIButton) {
        
        if let strSearchText = txtSearchBox.text {
            if strSearchText.isEmpty {
                let alertVC = UIAlertController(title: "Invalid search text", message: "Please enter your search text before clicking send", preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                    //Code for the action to be performed once the OK button is clicked
                }))
                self.present(alertVC, animated: true) {
                    //Perfom action if needed after popup presented
                }
            }
            else {
                startLoader()
                Networking.shared.get(self, query: strSearchText)
            }
        }
    }
}

// MARK: - Extension for all the network API delegates and handling done in this section
extension ViewController: NetworkingDelegate {
    func apiCallError(_ error: Error) {
        let vcMovieDetails = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MovieDetailsViewController") as! MovieDetailsViewController
        vcMovieDetails.strError = error.localizedDescription
        DispatchQueue.main.async {
            self.endLoader()
            self.navigationController?.pushViewController(vcMovieDetails, animated: true)
        }
    }
    
    func apiCallSuccess(_ data: [movieModel]) {
        
        let vcMovieDetails = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MovieDetailsViewController") as! MovieDetailsViewController
        vcMovieDetails.dataDetails = data
        DispatchQueue.main.async {
            self.endLoader()
            self.navigationController?.pushViewController(vcMovieDetails, animated: true)
        }
    }
}

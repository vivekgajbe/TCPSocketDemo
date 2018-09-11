//
//  CapabilitesViewController.swift
//  TCPSocketDemo
//
//  Created by Ravi Jayaraman on 22/07/18.
//  Copyright © 2018 Vivek Gajbe. All rights reserved.
//

import UIKit
import SwiftSocket

class CapabilitesViewController: UIViewController, UITableViewDataSource,UITableViewDelegate {

    //Outlet declaration
    @IBOutlet weak var tblCapabilities: UITableView!
    
    var arrmCapabilities = [String]()
    var client: TCPClient?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setControllerPrefrance()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK:- User define method
    func setControllerPrefrance()
    {
         client = TCPClient(address: "indition.cc", port: Int32(25))
        //Set navigation button at the top  : Add to card
        let btnDisconnect = UIBarButtonItem.init(title: "Disconnect", style: UIBarButtonItemStyle.plain, target: self, action: #selector(btnDisconnectClick))
            
        self.navigationItem.rightBarButtonItem  = btnDisconnect
        self.navigationItem.title = Constant.capabilitiesTitle
        tblCapabilities.reloadData()
    }
    //MARK: - button delegate method
    
    /// method is used for disconnect TCp connection
    @objc func btnDisconnectClick()
    {
        guard let client = client else { return }
        
        switch client.send(string: "quit\r\n")
        {
        case .success:
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0)
            {
                if self.sendRequest(string: "GET / HTTP/1.0\n\n", using: client) != nil {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        case .failure(let error):
            print("\(error)")
            self.navigationController?.popViewController(animated: true)
        }
    }
    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return arrmCapabilities.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 100
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tblCapabilities.dequeueReusableCell(withIdentifier: "cell") as! clsCapabilitiesTableViewCell
        cell.lblTitle.text = arrmCapabilities[indexPath.row]

        cell.imgProfile.image = UIImage(named: "placeholder")  //set placeholder image first.
        cell.imgProfile.downloadImageFrom(link: "http://76.74.177.168:8080/selected/\(String(describing: arrmCapabilities[indexPath.row])).jpg", contentMode: UIViewContentMode.scaleAspectFill)  //set your image from link array.

        return cell
    }

    //MARK: - Socket delegate method
    private func sendRequest(string: String, using client: TCPClient) -> String? {
        
        switch client.send(string: string) {
        case .success:
            return readResponse(from: client)
        case .failure(let error):
            print("Failed : \(error)")
            return nil
        }
    }
    
    private func readResponse(from client: TCPClient) -> String? {
        guard let response = client.read(1024*10) else { return nil }
        
        return String(bytes: response, encoding: .utf8)
    }
}
extension UIImageView {
    func downloadImageFrom(link:String, contentMode: UIViewContentMode) {
        URLSession.shared.dataTask( with: NSURL(string:link)! as URL, completionHandler: {
            (data, response, error) -> Void in
            DispatchQueue.main.async {
                self.contentMode =  contentMode
                if let data = data { self.image = UIImage(data: data) }
            }
        }).resume()
    }
}

//
//  SocketConnectionVC.swift
//  TCPSocketDemo
//
//  Created by Ravi Jayaraman on 22/07/18.
//  Copyright © 2018 Vivek Gajbe. All rights reserved.
//

import UIKit
import SwiftSocket

class SocketConnectionVC: UIViewController {

    //Outlet declaration
    @IBOutlet weak var lblUrl: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var btnDisconnect: UIButton!
    @IBOutlet weak var btnSayHello: UIButton!
    @IBOutlet weak var btnConnect: UIButton! 
    

    var client: TCPClient?

    //init method declaration
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        self.setControllerPrefrances()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //MARK:- user define method
    func setControllerPrefrances()
    {
        client = TCPClient(address: Constant.socketHost, port: Int32(Constant.socketPort))
        
        //disable sayHello button
        btnSayHello.isUserInteractionEnabled = false
        btnSayHello.alpha = 0.6
        
        //disable disconnect button
        btnDisconnect.isUserInteractionEnabled = false
        btnDisconnect.alpha = 0.6
    }
    //MARK: - Button delegate method
    
    /// method is used for disconnecting socket connection
    @IBAction func btnDisconnectClick(_ sender: Any)
    {
        guard let client = client else { return }
        
        switch client.send(string: Constant.socketQuit)
        {
        case .success:
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0)
            {
                if let response = self.sendRequest(string: "GET / HTTP/1.0\n\n", using: client) {
                    self.appendToTextField(string: "Response: \(response)")
                    //disable sayHello button
                    self.setControllerPrefrances()
                }
            }
        case .failure(let error):
            appendToTextField(string: String(describing: error))
        }
    }
    
    /// method is used for Connecting socket connection
    @IBAction func btnConnectClick(_ sender: Any)
    {
        guard let client = client else { return }
        
        switch client.connect(timeout: 20) {
        case .success:
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {

                self.appendToTextField(string: "Connected to \(client.address)")
                if let response = self.sendRequest(string: "GET / HTTP/1.0\n\n", using: client) {
                    if response.hasPrefix("220")
                    {
                    self.appendToTextField(string: "\(response)")
                       
                    //enable button
                    self.btnSayHello.isUserInteractionEnabled = true
                    self.btnSayHello.alpha = 1.0
                    
                    self.btnDisconnect.isUserInteractionEnabled = true
                    self.btnDisconnect.alpha = 1.0
                    }
                }
            }
            
        case .failure(let error):
            appendToTextField(string: "Greeting failed : \(error)")
        }
        
    }
    
     /// method is used for call 'EHLO' command with socket connection
    @IBAction func btnSayHelloClick(_ sender: Any)
    {
        guard let client = self.client else { return }
        
        switch client.send(string: Constant.socketEHLO)
        {
        case .success:
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if let response = self.sendRequest(string: "GET / HTTP/1.0\n\n", using: client) {
                self.appendToTextField(string: "Response: \(response)")
               if let str = response.slice(from: "250-AUTH LOGIN PLAIN ", to: "\r\n250-AUTH=LOGIN")
                {
                    let fullNameArr : [String] = (str.characters.split{$0 == " "}.map(String.init))

                    //str.characters.split{$0 == " "}.map(String.init) as! NSMutableArray
                    //move to next screen
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "CapabilitesViewController") as! CapabilitesViewController
                    
                    vc.arrmCapabilities = fullNameArr
                    self.navigationController?.pushViewController(vc, animated: false)
                }
                }
            }
        case .failure(let error):
            self.appendToTextField(string: String(describing: error))
        }
    }
    
    //MARK:- Socket delegate method
    private func sendRequest(string: String, using client: TCPClient) -> String? {
        
        switch client.send(string: string) {
        case .success:
            return readResponse(from: client)
        case .failure(let error):
            appendToTextField(string: String(describing: error))
            return nil
        }
    }
    
    private func readResponse(from client: TCPClient) -> String? {
        guard let response = client.read(1024*10) else { return nil }
        
        return String(bytes: response, encoding: .utf8)
    }
    
    private func appendToTextField(string: String) {
        print(string)
        textView.text = textView.text.appending("\n\(string)")
    }
}
extension String {
    
    func slice(from: String, to: String) -> String? {
        
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo])
            }
        }
    }
}

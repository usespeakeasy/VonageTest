//
//  ViewController.swift
//  VonageTest
//
//  Created by Crt Gregoric on 20/05/2022.
//

import UIKit

class ViewController: UIViewController {
        
    @IBAction private func startCallButtonTapped() {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CallViewController") as! CallViewController
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true)
    }
    
}

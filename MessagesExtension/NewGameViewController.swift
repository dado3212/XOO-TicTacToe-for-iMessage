//
//  NewGameViewController.swift
//  TicTacToe
//
//  Created by Drew Fitzpatrick on 7/6/16.
//  Copyright © 2016 Drew Fitzpatrick. All rights reserved.
//

import UIKit

protocol NewGameViewControllerDelegate {
    func controllerDidSelectNewGame(_:NewGameViewController)
}

class NewGameViewController: UIViewController {
    
    var delegate : NewGameViewControllerDelegate?
    
    override func viewWillAppear(_ animated: Bool) {
        if let gradientView = view as? GradientView {
            let index = UserDefaults.init().integer(forKey: "backgroundGradient")
            gradientView.gradient = ThemeStore.gradient(index)
        }
    }

    @IBAction func newGameButtonPressed(_ sender: AnyObject) {
        delegate?.controllerDidSelectNewGame(self)
    }
    
}

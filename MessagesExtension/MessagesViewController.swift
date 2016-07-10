//
//  MessagesViewController.swift
//  MessagesExtension
//
//  Created by Drew Fitzpatrick on 6/30/16.
//  Copyright © 2016 Drew Fitzpatrick. All rights reserved.
//

import UIKit
import Messages

class MessagesViewController: MSMessagesAppViewController {
    
    override func willBecomeActive(with conversation: MSConversation) {
        super.willBecomeActive(with: conversation)
        
        switch presentationStyle {
        case .compact:
            presentNewGameScreen()
        case .expanded:
            var game = TicTacToeGame()
            if let url = conversation.selectedMessage?.url,
               let components = URLComponents.init(url: url, resolvingAgainstBaseURL: false)
            {
                let success = game.from(components: components)
                if !success {
                    print("failed to load game from url: \(url)")
                }
            }
            present(game: game)
        }
        
    }
    
    override func willSelect(_ message: MSMessage, conversation: MSConversation) {
        if let url = message.url {
            if let components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                var game = TicTacToeGame()
                _ = game.from(components: components)
                dismissAllChildren()
                present(game: game)
            }
        }
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        dismissAllChildren()
        
        switch presentationStyle {
        case .compact:
            presentNewGameScreen()
        case .expanded:
            var game = TicTacToeGame()
            if let message = activeConversation?.selectedMessage {
                _ = game.from(components: URLComponents(url: message.url!, resolvingAgainstBaseURL: false)!)
            }
            present(game: game)
        }
        
    }
    
    // MARK: - Utilities
    
    private func present(game: TicTacToeGame) {
        let controller = storyboard?.instantiateViewController(withIdentifier: "ActiveGameScene")
        if let tController = controller as? ActiveGameViewController {
            tController.delegate = self
            tController.game = game
        }
        
        attachController(controller!)
    }
    
    private func presentNewGameScreen() {
        let controller = storyboard?.instantiateViewController(withIdentifier: "NewGameScene")
        if let ngController = controller as? NewGameViewController {
            ngController.delegate = self
        }
        
        attachController(controller!)
    }
    
    private func attachController(_ controller: UIViewController) {
        addChildViewController(controller)
        
        controller.view.frame = view.bounds
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controller.view)
        
        controller.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        controller.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        controller.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        controller.didMove(toParentViewController: self)
    }
    
    private func dismissAllChildren() {
        for viewController in childViewControllers {
            viewController.willMove(toParentViewController: nil)
            viewController.view.removeFromSuperview()
            viewController.removeFromParentViewController()
        }
    }
}

extension MessagesViewController : NewGameViewControllerDelegate {
    func controllerDidSelectNewGame(_ controller: NewGameViewController) {
        requestPresentationStyle(.expanded)
    }
}

extension MessagesViewController : ActiveGameViewControllerDelegate {
    func activeGameView(_ viewController: ActiveGameViewController, didSelectCellAt indexPath: IndexPath) {
        
        if  let image = viewController.imageSnapshot(),
            let conversation = activeConversation
        {
            let message = MSMessage(session: activeConversation?.selectedMessage?.session ?? MSSession())
            let layout = MSMessageTemplateLayout()
            layout.image = image
            message.layout = layout
            message.url = viewController.game.toURLComponents().url
            conversation.insert(message, completionHandler: nil)
        }
        
        dismiss()
    }
    
    func activeGameViewCancelledChoosing(_ viewController: ActiveGameViewController) {
        dismiss()
    }
}

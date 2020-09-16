//
//  ViewController.swift
//  RESThub
//
//  Created by Harrison on 7/25/19.
//  Edited by Brian on 9/10/20
//  Copyright © 2019 Harrison. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var feedTableView: UITableView!
    
    // MARK: Variables
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let testGist = Gist(id: nil, isPublic: true, description: "Banana")
//        
//        do {
//            let gistData = try JSONEncoder().encode(testGist)
//            let stringData = String(data: gistData, encoding: .utf8)
//            print(stringData)
//        } catch {
//            print("Encoding failed")
//        }
        
        // TODO: GET a list of gists
//        DataService.shared.fetchGists { (result) in
//            switch result  {
//                case .success(let gists):
//                    
//                    for gist in gists {
//                        print("\(gist)\n")
//                    }
//                
//                case .failure(let error):
//                    print(error)
//            }
//        }
        
        DataService.shared.starUnstarGist(id: "912f1e89fec65f80e89eaa7a3555d32e", star: false) { (success) in
            if success {
                print("Gist successfully unstarred")
            } else {
                print("Gist was unable to be unstarred.")
            }
        }
    }

    @IBAction func createNewGist(_ sender: UIButton) {
        // TODO: POST a new gist
        DataService.shared.createNewGist { (result) in
            switch result {
                case .success(let json) :
                    print(json)
                case .failure(let error):
                    print(error)
            }
        }
    }
    
    // MARK: Utilities
    func showResultAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
}

// MARK: UITableView Delegate & DataSource
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "feedCellID", for: indexPath)
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let starAction = UIContextualAction(style: .normal, title: "Star") { (action, view, completion) in
            
            // TODO: PUT a gist star
            completion(true)
        }
        
        let unstarAction = UIContextualAction(style: .normal, title: "Unstar") { (action, view, completion) in
            
            // TODO: DELETE a gist star
            completion(true)
        }
        
        starAction.backgroundColor = .blue
        unstarAction.backgroundColor = .darkGray
        
        let actionConfig = UISwipeActionsConfiguration(actions: [unstarAction, starAction])
        return actionConfig
    }
    
}


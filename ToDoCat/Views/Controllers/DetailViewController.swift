//
//  DetailViewController.swift
//  ToDoCat
//
//  Created by 서준일 on 3/14/25.
//

import UIKit

class DetailViewController: UIViewController {
    
    var detailView = DetailView()

    override func viewDidLoad() {
        super.viewDidLoad()

        view = detailView
    }
    

}

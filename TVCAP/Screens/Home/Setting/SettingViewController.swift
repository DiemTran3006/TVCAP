//
//  SettingViewController.swift
//  TVCAP
//
//  Created by Diem Tran on 07/11/2023.
//

import UIKit

class SettingViewController: UIViewController {
    
    @IBOutlet weak var myTable: UITableView!
    
    var setting: [SettingModel] = [SettingModel(buttonleft: "Icon.button.left.1",
                                                contentlabel: "How to use",
                                                buttonright: "icon.next.button"),
                                   SettingModel(buttonleft: "Icon.button.left.2",
                                                contentlabel: "Contact us",
                                                buttonright: "icon.next.button"),
                                   SettingModel(buttonleft: "Icon.button.left.3",
                                                contentlabel: "Privacy & policy",
                                                buttonright: "icon.next.button"),
                                   SettingModel(buttonleft: "Icon.button.left.4",
                                                contentlabel: "Term of use",
                                                buttonright: "icon.next.button")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myTable.dataSource = self
        myTable.delegate = self
        myTable.separatorStyle = .none
        myTable.register(cellType: SettingTableViewCell.self)
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
// MARK: - Action
    @IBAction func actionPopHomeButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource
extension SettingViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        setting.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SettingTableViewCell",
                                                       for: indexPath) as? SettingTableViewCell else {
            return UITableViewCell()
        }
        cell.configCell(model: setting[indexPath.row])
        return cell
    }
    
    
}

// MARK: - UITableViewDelegate
extension SettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
}

// MARK: - Model
struct SettingModel {
    let buttonleft: String
    let contentlabel: String
    let buttonright: String
}

//
//  MoreRecentsViewController.swift
//  TVCAP
//
//  Created by Bui Trung Quan on 15/11/2023.
//

import UIKit
import RealmSwift

protocol MoreRecentsDelegate: AnyObject {
    func onClearAll()
    func onSelectedURL(url: String)
}

class MoreRecentsViewController: UIViewController {
    @IBOutlet weak var modalBottomView: ModalBottomView!
    @IBOutlet weak var moreRecentTableView: UITableView!
    @IBOutlet weak var overlayBackground: UIView!
    @IBOutlet weak var constraint: NSLayoutConstraint!
    
    public weak var moreRecentsDelegate: MoreRecentsDelegate?
    
    private var listHistory: [HistoryBrowserModel] = [] {
        didSet {
            self.changeListToDictionaryHistory()
        }
    }
    
    private var dictionaryHistory: [String: [HistoryBrowserModel]] = [:]
    
    private var arrayKeySorted: [String] {
        return Array(dictionaryHistory.keys.sorted(by: { item1, item2 in
            
            let dateString1 = dictionaryHistory[item1]?.first?.dateTime
            let dateString2 = dictionaryHistory[item2]?.first?.dateTime
            guard let dateString1,let dateString2 else { return item1 > item2 }

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
            let date1 = dateFormatter.date(from: dateString1)
            let date2 = dateFormatter.date(from: dateString2)
            
            guard let date1, let date2 else { return item1 > item2 }
            
            return date1>date2
        }))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Recent"
        let clearButton = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(clearTapped))
        clearButton.tintColor = UIColor(hexString: "#E8505B")
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))
        cancelButton.tintColor = UIColor(hexString: "#1797FF")
        self.navigationItem.rightBarButtonItem = clearButton
        self.navigationItem.leftBarButtonItem = cancelButton
        
        setupTableView()
        setupModalBottomView()
        fetchHistoryRealm()
    }
    
    private func setupModalBottomView() {
        modalBottomView.layer.cornerRadius = 24
        modalBottomView.layer.masksToBounds = true
        modalBottomView.delegate = self
        modalBottomView.configure(title: "Clear Recent", subtitle: "Are you sure to clear all the recent site?", buttonAccept: "Clear all")
    }
    
    private func fetchHistoryRealm() {
        let realm = try? Realm()
        guard let realm = realm else { return }
        let results = realm.objects(HistoryBrowserModel.self).toArray(ofType: HistoryBrowserModel.self)
        listHistory = results
        moreRecentTableView.reloadData()
    }
    
    private func setupTableView() {
        moreRecentTableView.delegate = self
        moreRecentTableView.dataSource = self
        moreRecentTableView.estimatedRowHeight = 100
        moreRecentTableView.register(cellType: BrowserTableViewCell.self)
        moreRecentTableView.separatorStyle = .none
    }
    
    private func changeListToDictionaryHistory() {
        dictionaryHistory = [:]
        listHistory.forEach { model in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
            let dateModel = dateFormatter.date(from: model.dateTime)
            guard let dateModel else { return }
            
            if Calendar.current.isDateInToday(dateModel) {
                dictionaryHistory["Today", default: []].append(model)
            } else if Calendar.current.isDateInYesterday(dateModel) {
                dictionaryHistory["Yesterday", default: []].append(model)
            } else {
                dateFormatter.dateFormat = "dd MMM yyyy"
                let stringFormatted = dateFormatter.string(from: dateModel)
                dictionaryHistory[stringFormatted, default: []].append(model)
            }
        }
    }
    
    @objc func cancelTapped() {
        self.navigationController?.dismiss(animated: true)
    }
    
    @objc func clearTapped() {
        UIView.animate(withDuration: 0.5) {
            self.constraint.priority = .init(250)
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.overlayBackground.layer.opacity = 0.5
        }
    }
}

extension MoreRecentsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? BrowserTableViewCell,
              let url = cell.urlString.text
        else { return }
        self.moreRecentsDelegate?.onSelectedURL(url: url)
        self.navigationController?.dismiss(animated: true)
    }
}

extension MoreRecentsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        dictionaryHistory.keys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = arrayKeySorted[section]
        return dictionaryHistory[key]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let key = arrayKeySorted[section]
        return key
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(with: BrowserTableViewCell.self, for: indexPath) else { return BrowserTableViewCell()}
        
        let key = arrayKeySorted[indexPath.section]
        guard let listHistory = dictionaryHistory[key] else { return BrowserTableViewCell()}
        
        cell.configure(historyModel: (listHistory[indexPath.row]))
        cell.selectionStyle = .none
        return cell
    }
}

extension MoreRecentsViewController: ModalBottomDelegate {
    func handleAccept() {
        self.moreRecentsDelegate?.onClearAll()
        self.navigationController?.dismiss(animated: true)
    }
    
    func handleCancel() {
        UIView.animate(withDuration: 0.5) {
            self.constraint.priority = .init(1000)
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.overlayBackground.layer.opacity = 0
        }
    }
}

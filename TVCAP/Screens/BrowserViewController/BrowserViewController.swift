//
//  BrowserViewController.swift
//  TVCAP
//
//  Created by Bui Trung Quan on 08/11/2023.
//

import UIKit
import WebKit

class BrowserViewController: UIViewController {
    @IBOutlet weak var buttonPrev: UIImageView! {
        didSet {
            buttonPrev.addTapGesture {
                if self.webView.canGoBack {
                    self.webView.goBack()
                }
            }
        }
    }
    @IBOutlet weak var buttonNext: UIImageView! {
        didSet {
            buttonNext.addTapGesture {
                if self.webView.canGoForward {
                    self.webView.goForward()
                }
            }
        }
    }
    @IBOutlet weak var buttonHome: UIImageView! {
        didSet {
            buttonHome.addTapGesture {
                self.webView.isHidden = true
                self.webView.load(URLRequest(url: URL(string: "about:blank")!))
                self.webView.backForwardList.perform(Selector(("_removeAllItems")))
            }
        }
    }
    @IBOutlet weak var buttonReload: UIImageView! {
        didSet {
            buttonReload.addTapGesture {
                self.webView.reload()
            }
        }
    }
    @IBOutlet weak var webView: WKWebView! {
        didSet {
            self.webView.isHidden = true
            self.webView.navigationDelegate = self
            self.webView.load(URLRequest(url: URL(string: "about:blank")!))
        }
    }
    @IBOutlet weak var bottomConstraintHistorySearch: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var recentsTableView: UITableView! {
        didSet {
            recentsTableView.delegate = self
            recentsTableView.dataSource = self
            recentsTableView.estimatedRowHeight = 100
            recentsTableView.register(cellType: BrowserTableViewCell.self)
            recentsTableView.allowsSelection = false
            recentsTableView.separatorStyle = .none
        }
    }
    @IBOutlet weak var historySearchTableView: UITableView! {
        didSet {
            historySearchTableView.delegate = self
            historySearchTableView.dataSource = self
            historySearchTableView.estimatedRowHeight = 40
            historySearchTableView.register(cellType: HistorySearchTableViewCell.self)
            historySearchTableView.allowsSelection = false
            historySearchTableView.separatorStyle = .none
        }
    }
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar.delegate = self
            searchBar.searchTextField.tintColor = UIColor(hexString: "#505874")
            searchBar.searchTextField.clearButtonMode = .whileEditing
            searchBar.searchTextField.borderStyle = .none
            searchBar.searchTextField.layer.cornerRadius = 12
            searchBar.searchTextField.backgroundColor = .white
            searchBar.layer.shadowColor = UIColor(hexString: "F0F1F2").cgColor
            searchBar.layer.shadowOpacity = 1
            searchBar.layer.shadowOffset = .zero
            searchBar.layer.shadowRadius = 2
            searchBar.setImage(UIImage(named: "searchIcon"), for: .search, state: .normal)
            searchBar.setImage(UIImage(systemName: "multiply"), for: .clear, state: .normal)
        }
    }
    @IBOutlet weak var socialCollectionView: UICollectionView! {
        didSet {
            socialCollectionView.delegate = self
            socialCollectionView.dataSource = self
            socialCollectionView.register(cellType: SocialCollectionViewCell.self)
        }
    }
    private var borderBottom: CALayer? = nil
    
    var keyboardNotifier: KeyboardNotifier!
    
    private var listHintSearch: [String] = []
    
    private var textSearch = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Browser"
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "multiply"), style: .plain, target: self, action: #selector(backTapped))
        
        let buttonAirPlay = UIBarButtonItem.menuButton(self, action: #selector(airplayTapped), imageName: "airplayIcon")
        
        self.navigationItem.rightBarButtonItem = buttonAirPlay
        
//        hideKeyboardWhenTappedAround()
        
        keyboardNotifier = KeyboardNotifier(parentView: view, constraint: bottomConstraint)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.drawBorderBottom(borderWidth: 1, color: .black.withAlphaComponent(0.1), margin: 0)
        self.navigationController?.navigationBar.tintColor = UIColor(hexString: "#384161")
        keyboardNotifier.enabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.tintColor = UIColor.systemBlue
        self.borderBottom?.removeFromSuperlayer()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        keyboardNotifier.enabled = false
        super.viewDidDisappear(animated)
    }
    
    @objc func backTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func airplayTapped() {
        print("Air play")
        self.navigationController?.pushViewController(PhotoViewController(), animated: true)
    }
    
    func verifyUrl (urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url = NSURL(string: urlString) {
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }
    
    @objc func handleSearch(sender: UIButton?) {
        self.webView.isHidden = false
        
        let urlString = searchBar.text?.lowercased() ?? ""
        if urlString.isValidURL {
            let urlHasHttpPrefix = urlString.hasPrefix("http://")
            let urlHasHttpsPrefix = urlString.hasPrefix("https://")
            let validUrlString = (urlHasHttpPrefix || urlHasHttpsPrefix) ? urlString : "https://\(urlString)"
            let url = URL(string: "\(validUrlString)")!
            let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
            webView.load(request)
        } else {
            let urlRequest = URLRequest(url: URL(string: "https://www.google.com/search?q=\(searchBar.text ?? "")")!)
            webView.load(urlRequest)
        }
    }
    
    func drawBorderBottom(borderWidth: CGFloat, color: UIColor, margin: CGFloat) {
        let frame = self.navigationController!.navigationBar.frame
        let borderLayer: CALayer = CALayer()
        borderLayer.borderColor = color.cgColor
        borderLayer.borderWidth = borderWidth
        borderLayer.frame = CGRect(x: margin, y: frame.height - borderWidth, width: frame.width - (margin*2), height: borderWidth)
        self.borderBottom = borderLayer
        self.navigationController!.navigationBar.layer.addSublayer(borderLayer)
    }
}

extension BrowserViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == recentsTableView {
            return 4
        } else {
            return listHintSearch.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == recentsTableView {
            let cell = tableView.dequeueReusableCell(with: BrowserTableViewCell.self, for: indexPath)!
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(with: HistorySearchTableViewCell.self, for: indexPath)!
            cell.configureLabel(listHintSearch[indexPath.row], textSearch: self.textSearch)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == historySearchTableView {
            return "Google search"
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == historySearchTableView {
            let cell = tableView.cellForRow(at: indexPath) as! HistorySearchTableViewCell
            let urlRequest = URLRequest(url: URL(string: "https://www.google.com/search?q=\(cell.labelSearch.text ?? "")")!)
            webView.load(urlRequest)
        }
    }
}

extension BrowserViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        if tableView == recentsTableView {
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, completionHandler) in
                // delete the item here
                completionHandler(true)
            }
            deleteAction.image = UIImage(named: "trashIcon")?.withTintColor(.white)
            deleteAction.backgroundColor = UIColor(hexString: "#E8505B")
            let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
            return configuration
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // delete your item here and reload table view
        }
    }
}

extension BrowserViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = Int(collectionView.frame.width/4)
        return .init(width: width, height: 80)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
}

extension BrowserViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        arraySocial.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(with: SocialCollectionViewCell.self, for: indexPath)!
        cell.configureSocial(arraySocial[indexPath.row])
        cell.socialDelegate = self
        return cell
    }
}

extension BrowserViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        UIView.animate(withDuration: 0.4) {
            self.bottomConstraintHistorySearch.priority = .init(1000)
            self.view.layoutIfNeeded()
        }
        return true
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.textSearch = searchText
        
        self.historySearchTableView.reloadData()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        handleSearch(sender: nil)
        
        UIView.animate(withDuration: 0.4) {
            self.bottomConstraintHistorySearch.priority = .init(250)
            self.view.layoutIfNeeded()
        }
        self.view.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        UIView.animate(withDuration: 0.4) {
            self.bottomConstraintHistorySearch.priority = .init(250)
            self.view.layoutIfNeeded()
        }
        self.view.endEditing(true)
    }
}

extension BrowserViewController: SocialDelegate {
    func tapImageWithURL(_ url: String) {
        let urlRequest = URLRequest(url: URL(string: url)!)
        self.webView.load(urlRequest)
        self.webView.isHidden = false
    }
}

extension BrowserViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) { // triggers when loading is complete
        buttonPrev.tintColor = !webView.canGoBack ? UIColor(hexString: "#777D91") : UIColor(hexString: "#384161")
        buttonNext.tintColor = !webView.canGoForward ? UIColor(hexString: "#777D91") : UIColor(hexString: "#384161")
//        buttonPrev.isHidden = !webView.canGoBack
//        buttonNext.isHidden = !webView.canGoForward
        searchBar.text = webView.url?.absoluteString
        let newPosition = searchBar.searchTextField.beginningOfDocument
        searchBar.searchTextField.selectedTextRange = searchBar.searchTextField.textRange(from: newPosition, to: newPosition)
    }
}

extension String {
    var isValidURL: Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
            // it is a link, if the match covers the whole string
            return match.range.length == self.utf16.count
        } else {
            return false
        }
    }
}

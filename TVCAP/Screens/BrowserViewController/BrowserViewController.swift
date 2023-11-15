//
//  BrowserViewController.swift
//  TVCAP
//
//  Created by Bui Trung Quan on 08/11/2023.
//

import UIKit
import WebKit
import RealmSwift

class BrowserViewController: UIViewController {
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var emptyHistory: UIView!
    @IBOutlet weak var buttonPrev: UIImageView!
    @IBOutlet weak var buttonNext: UIImageView!
    @IBOutlet weak var buttonHome: UIImageView!
    @IBOutlet weak var buttonReload: UIImageView!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var bottomConstraintHistorySearch: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var recentsTableView: UITableView!
    @IBOutlet weak var historySearchTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var socialCollectionView: UICollectionView!
    
    private var borderBottom: CALayer? = nil
    private var keyboardNotifier: KeyboardNotifier!
    private var listHintSearch: [String] = []
    private var textSearch = ""
    private var listHistory: [HistoryBrowserModel] = [] {
        didSet {
            self.emptyHistory.isHidden = !listHistory.isEmpty
            self.moreButton.isHidden = listHistory.count <= 5
        }
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Browser"
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "multiply"), style: .plain, target: self, action: #selector(backTapped))
        
        let buttonAirPlay = UIBarButtonItem.menuButton(self, action: #selector(airplayTapped), imageName: "airplayIcon")
        
        self.navigationItem.rightBarButtonItem = buttonAirPlay
        
        addTapGestureButtonTabBar()
        setupCollectionView()
        setupSearchBar()
        setupWebView()
        setupTableView()
        keyboardNotifier = KeyboardNotifier(parentView: view, constraint: bottomConstraint)
        fetchHistoryRealm()
    }
    
    @objc func backTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func airplayTapped() {
        print("Air play")
    }
    
    @objc func handleSearch(sender: UIButton?) {
        self.webView.isHidden = false
        
        let urlString = searchBar.text?.lowercased() ?? ""
        if urlString.isValidURL {
            let urlHasHttpPrefix = urlString.hasPrefix("http://")
            let urlHasHttpsPrefix = urlString.hasPrefix("https://")
            let validUrlString = (urlHasHttpPrefix || urlHasHttpsPrefix) ? urlString : "https://\(urlString)"
            let url = URL(string: "\(validUrlString)")
            guard let url = url else { return }
            let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
            webView.load(request)
            self.webView.isHidden = false
        } else {
            guard let url = URL(string: "https://www.google.com/search?q=\(searchBar.text?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")") else { return }
            let urlRequest = URLRequest(url: url)
            webView.load(urlRequest)
            self.webView.isHidden = false
        }
    }
    
    fileprivate func fetchHintSearch(query: String) {
        let url = URL(string: "https://google.com/complete/search?client=firefox&q=\(query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? query)")
        print(url)
        guard let url = url else { return }
        URLSession.shared.dataTask(with: url) {[weak self] data,response, error in
            guard let self = self else { return }
            if let data = data {
                    let responseStrInISOLatin = String(data: data, encoding: String.Encoding.isoLatin1)
                    guard let modifiedDataInUTF8Format = responseStrInISOLatin?.data(using: String.Encoding.utf8) else { return }
                    do {
                        guard let object = try JSONSerialization.jsonObject(with: modifiedDataInUTF8Format) as? [Any],
                              let listHint = object[1] as? [String]
                        else { return }
                        
                        self.listHintSearch = listHint
                        DispatchQueue.main.async {
                            self.historySearchTableView.reloadData()
                        }
                    } catch {
                        print(error)
                    }
            }
        }.resume()
    }
    
    private func fetchHistoryRealm() {
        let realm = try? Realm()
        guard let realm = realm else { return }
        let results = realm.objects(HistoryBrowserModel.self).toArray(ofType: HistoryBrowserModel.self)
        listHistory = results
        recentsTableView.reloadData()
    }
    
    private func addTapGestureButtonTabBar() {
        buttonPrev.addTapGesture { [weak self] in
            guard let self = self else { return }
            if self.webView.canGoBack {
                self.webView.goBack()
            }
        }
        buttonNext.addTapGesture { [weak self] in
            guard let self = self else { return }
            if self.webView.canGoForward {
                self.webView.goForward()
            }
        }
        buttonHome.addTapGesture { [weak self] in
            guard let self = self else { return }
            self.webView.isHidden = true
            if let url = URL(string: "about:blank") {
                self.webView.load(URLRequest(url: url))
            }
            self.webView.backForwardList.perform(Selector(("_removeAllItems")))
        }
        buttonReload.addTapGesture { [weak self] in
            guard let self = self else { return }
            self.webView.reload()
        }
    }
    
    private func setupCollectionView() {
        socialCollectionView.delegate = self
        socialCollectionView.dataSource = self
        socialCollectionView.register(cellType: SocialCollectionViewCell.self)
    }
    
    private func setupSearchBar() {
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
    
    private func setupWebView() {
        self.webView.isHidden = true
        self.webView.navigationDelegate = self
        guard let url = URL(string: "about:blank") else { return }
        self.webView.load(URLRequest(url: url))
    }
    
    private func setupTableView() {
        recentsTableView.delegate = self
        recentsTableView.dataSource = self
        recentsTableView.estimatedRowHeight = 100
        recentsTableView.register(cellType: BrowserTableViewCell.self)
        recentsTableView.separatorStyle = .none
        
        historySearchTableView.delegate = self
        historySearchTableView.dataSource = self
        historySearchTableView.estimatedRowHeight = 40
        historySearchTableView.register(cellType: HistorySearchTableViewCell.self)
        historySearchTableView.separatorStyle = .none
        
    }
    
    private func verifyUrl (urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url = NSURL(string: urlString) {
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }
    
    private func drawBorderBottom(borderWidth: CGFloat, color: UIColor, margin: CGFloat) {
        guard let frame = self.navigationController?.navigationBar.frame else { return }
        let borderLayer: CALayer = CALayer()
        borderLayer.borderColor = color.cgColor
        borderLayer.borderWidth = borderWidth
        borderLayer.frame = CGRect(x: margin, y: frame.height - borderWidth, width: frame.width - (margin*2), height: borderWidth)
        self.borderBottom = borderLayer
        self.navigationController?.navigationBar.layer.addSublayer(borderLayer)
    }
    
    private func addHistoryBrowser() {
        if webView.url?.absoluteString == "about:blank" { return }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        let historyBrowser = HistoryBrowserModel(url: webView.url?.absoluteString ?? "", dateTime: dateFormatter.string(from: Date()))
        historyBrowser.toggleRealm()
        listHistory.append(historyBrowser)
        recentsTableView.reloadData()
    }
    
    @IBAction func handleMore(_ sender: Any) {
        let vc = MoreRecentsViewController()
        vc.moreRecentsDelegate = self
        let nav = BaseNavigationController(rootViewController: vc)
        self.present(nav, animated: true)
    }
}

extension BrowserViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == recentsTableView {
            return min(5, listHistory.count)
        } else {
            return listHintSearch.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == recentsTableView {
            guard let cell = tableView.dequeueReusableCell(with: BrowserTableViewCell.self, for: indexPath) else { return BrowserTableViewCell()}
            cell.configure(historyModel: listHistory[indexPath.row])
            cell.selectionStyle = .none
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(with: HistorySearchTableViewCell.self, for: indexPath) else { return HistorySearchTableViewCell()}
            cell.configureLabel(listHintSearch[indexPath.row], textSearch: self.textSearch)
            cell.selectionStyle = .none
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
            guard let cell = tableView.cellForRow(at: indexPath) as? HistorySearchTableViewCell,
                  let url = URL(string: "https://www.google.com/search?q=\(cell.labelSearch.text ?? "")")
            else { return }
            
            let urlRequest = URLRequest(url: url)
            webView.load(urlRequest)
            webView.isHidden = false
        }
        if tableView == recentsTableView {
            guard let cell = tableView.cellForRow(at: indexPath) as? BrowserTableViewCell,
                  let url = URL(string: cell.urlString.text ?? "")
            else { return }
            let urlRequest = URLRequest(url: url)
            webView.load(urlRequest)
            webView.isHidden = false
        }
    }
}

extension BrowserViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        if tableView == recentsTableView {
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completionHandler) in
                // delete the item here
                guard let self = self else { return }
                self.listHistory[indexPath.row].toggleRealm()
                self.listHistory.remove(at: indexPath.row)
                if self.listHistory.count <= 4 {
                    recentsTableView.deleteRows(at: [indexPath], with: .automatic)
                }
                self.recentsTableView.reloadData()
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
//            self.listHistory.remove(at: indexPath.row)
//            if self.listHistory.count <= 4 {
//                recentsTableView.deleteRows(at: [indexPath], with: .automatic)
//            }
//            recentsTableView.reloadData()
//
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
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
        guard let cell = collectionView.dequeueReusableCell(with: SocialCollectionViewCell.self, for: indexPath) else { return SocialCollectionViewCell()}
        cell.configureSocial(arraySocial[indexPath.row])
        cell.socialDelegate = self
        return cell
    }
}

extension BrowserViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        UIView.animate(withDuration: 0.4) {
            self.bottomConstraintHistorySearch.priority = .init(1000)
            self.webView.isHidden = true
            self.view.layoutIfNeeded()
        }
        return true
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        fetchHintSearch(query: searchText)
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
        guard let url = URL(string: url) else { return }
        let urlRequest = URLRequest(url: url)
        self.webView.load(urlRequest)
        self.webView.isHidden = false
    }
}

extension BrowserViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) { // triggers when loading is complete
        buttonPrev.tintColor = !webView.canGoBack ? UIColor(hexString: "#777D91") : UIColor(hexString: "#384161")
        buttonNext.tintColor = !webView.canGoForward ? UIColor(hexString: "#777D91") : UIColor(hexString: "#384161")
        searchBar.text = webView.url?.absoluteString
        let newPosition = searchBar.searchTextField.beginningOfDocument
        searchBar.searchTextField.selectedTextRange = searchBar.searchTextField.textRange(from: newPosition, to: newPosition)
        
        addHistoryBrowser()
        
        listHintSearch = []
        historySearchTableView.reloadData()
    }
}

extension BrowserViewController: MoreRecentsDelegate {
    func onClearAll() {
//        guard let realm = try? Realm() else { return }
//        try? realm.write {
//            realm.delete(self.listHistory)
//        }
        self.listHistory = []
        self.recentsTableView.reloadData()
    }
    
    func onSelectedURL(url: String) {
        guard let url = URL(string: url) else { return }
        let urlRequest = URLRequest(url: url)
        webView.load(urlRequest)
        webView.isHidden = false
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

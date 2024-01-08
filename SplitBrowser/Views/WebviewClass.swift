//
//  WebviewClass.swift
//  SplitBrowser
//
//  Created by Saif Mukadam on 29/12/23.
//

import UIKit
import WebKit

protocol textfiledDelegate {
    func returnPressed()
}

class WebviewClass: UIView,UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegate?.returnPressed()
        return true
    }
    
    @IBOutlet weak var noBookmarksYet: UILabel!
    @IBOutlet weak var webbar: UIView!
    var delegate:textfiledDelegate?
    @IBOutlet weak var homepage: UIView!
    @IBOutlet weak var bookmarCollection: UICollectionView!
    @IBOutlet weak var menuSlack: UIStackView!
    @IBOutlet weak var textfiled: UITextField!
    @IBOutlet weak var webview: WKWebView!
    var bookmark =  getBookmarks()
    var fevicon:UIImage?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    // Initializer required for loading the view from a XIB
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // Common initialization code
    private func commonInit() {
        // Load the XIB
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "Webview", bundle: bundle)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else { return }
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(view)
        
        let request = URLRequest(url: URL(string: "about:blank")!)
        webview.load(request)
        
        self.bookmarCollection.register(BookmarkCell.nib, forCellWithReuseIdentifier: BookmarkCell.name)
        
        self.textfiled.delegate = self
        self.bookmarCollection.delegate = self
        self.bookmarCollection.dataSource = self
        self.bookmarCollection.reloadData()
        
    }
    
    @IBAction func openMenu(_ sender: Any) {
        self.menuSlack.isHidden.toggle()
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    @IBAction func restorebar(_ sender: Any) {
        webbar.isHidden = false
    }
    
    @IBAction func tabbarOptions(_ sender: UIButton) {
        menuSlack.isHidden = true
        let tag = sender.tag
        
        switch tag {
        case 0:
            
            webbar.isHidden = true
            break
            
        case 1:
            webview.reload()
            
        case 2:
            
            if let topController = UIApplication.topViewController() {
                let text = webview.url?.absoluteString
                let textShare = [ text ]
                let activityViewController = UIActivityViewController(activityItems: textShare, applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = topController.view
                topController.present(activityViewController, animated: true, completion: nil)
            }
            
        case 3:
            
            let url = webview.url?.absoluteString ?? ""
            guard !bookmark.contains(url) else {
                return
            }
            appendBookmarks(newString: url)
            
        case 4:
            
            homepage.isHidden = false
            self.bookmark = getBookmarks()
            self.bookmarCollection.reloadData()

            
        default:
            break
        }
        
    }
  
}

extension WebviewClass:UICollectionViewDelegate,UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if bookmark.count == 0 {
            self.bookmarCollection.isHidden = true
            self.noBookmarksYet.isHidden = false
        }else{
            self.noBookmarksYet.isHidden = true
            self.bookmarCollection.isHidden = false
        }
        
        return bookmark.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BookmarkCell.name, for: indexPath) as! BookmarkCell
        
        let link = bookmark[indexPath.row]
        cell.config(url: link)
        
        return cell
    }
    
}

class BlurredTransparentView: UIView {
    
    // Initializer for programmatically created views
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBlurEffect()
    }
    
    // Initializer for views loaded from a storyboard
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupBlurEffect()
    }
    
    private func setupBlurEffect() {
        // Choose the style of the blur effect you want
        let blurEffect = UIBlurEffect(style: .systemChromeMaterialDark) // or .extraLight, .dark
        
        // Create a UIVisualEffectView which will render the blur effect
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        
        // Make sure the effect view resizes to always fit the entire view
        blurredEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurredEffectView.frame = self.bounds
        
        // Add the effect view to the view hierarchy
        addSubview(blurredEffectView)
        blurredEffectView.layer.zPosition = -1  // Put the blur view behind other content
    }
}

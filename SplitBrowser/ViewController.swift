import UIKit
import WebKit

class ViewController: UIViewController,WKNavigationDelegate {
    
    @IBOutlet weak var parentView: UIView!
    var wkwebview = WebviewClass()
    var wkwebviewTwo = WebviewClass()
    
    // Flags to track keyboard state for each WKWebView
    var isKeyboardOpenInWebView1 = false
    var isKeyboardOpenInWebView2 = false
    var activeWebView = ""
    var mySplitView = SplitView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       // if !Manager.isWelcomeDone {
            DispatchQueue.main.async {
                let main = UIStoryboard(name: "Welcome", bundle: Bundle.main)
                let vc = main.instantiateViewController(identifier: "WelcomeVC")
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: false)
            }
      //  }
        
        wkwebview.delegate = self
        wkwebviewTwo.delegate = self
        
        mySplitView = SplitView(frame: parentView.bounds)
        mySplitView.axis = .vertical
        
        mySplitView.addSplitSubview(wkwebview)
        mySplitView.addSplitSubview(wkwebviewTwo)
        
        parentView.addSubview(mySplitView)
        
        wkwebview.webview.navigationDelegate = self
        wkwebviewTwo.webview.navigationDelegate = self
        
        mySplitView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        
        // Register for keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func checkIfInputIsFocused(in webView: WKWebView, completion: @escaping (Bool) -> Void) {
        let js = "document.activeElement.tagName.toLowerCase() === 'input' || document.activeElement.tagName.toLowerCase() === 'textarea'"
        webView.evaluateJavaScript(js) { (result, error) in
            if let isInputFocused = result as? Bool {
                completion(isInputFocused)
            } else {
                completion(false)
            }
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        self.mySplitView.assignRatios(newRatio: 0.5, for: 1)
        self.mySplitView.update()
    }
    
    @objc func keyboardDidShow(notification: Notification) {
        
        if wkwebview.textfiled.isFirstResponder {
            self.activeWebView = "Upper"
            self.keyboardDetected()
            return
        }
        
        if wkwebviewTwo.textfiled.isFirstResponder {
            self.activeWebView = "Below"
            self.keyboardDetected()
            return
        }
        
        
        // Evaluate JavaScript in both web views
        checkIfInputIsFocused(in: wkwebview.webview) { [weak self] isFocused in
            if isFocused {
                
                self?.activeWebView = "Upper"
                self?.keyboardDetected()
                return
            }
        }
        
        checkIfInputIsFocused(in: wkwebviewTwo.webview) { [weak self] isFocused in
            if isFocused {
                self?.activeWebView = "Below"
                self?.keyboardDetected()
                return
            }
        }
        
        
    }
    
    
    private func keyboardDetected() {
        
        if activeWebView == "Below" {
            self.mySplitView.assignRatios(newRatio: 0.85, for: 1)
            self.mySplitView.update()
        }else{
            self.mySplitView.assignRatios(newRatio: 0.85, for: 0)
            self.mySplitView.update()
        }
        
    }
    
}


extension ViewController:textfiledDelegate {
    
    //Go button pressed
    func returnPressed() {
        if activeWebView == "Below" {
            hitWebview(webview: self.wkwebviewTwo)
        }else{
            hitWebview(webview: self.wkwebview)
        }
    }
    
    private func hitWebview(webview:WebviewClass) {
        webview.webbar.isHidden = true
        webview.homepage.isHidden = true
        webview.menuSlack.isHidden = true
        loadContent(from: webview.textfiled.text ?? "", in: webview.webview)
    }
    
    
    private func loadContent(from text: String, in webView: WKWebView) {
        // Function to create a URL with a default scheme if needed
        func createURL(withString string: String) -> URL? {
            if let url = URL(string: string), UIApplication.shared.canOpenURL(url) {
                return url
            } else if string.contains(".") && !string.contains(" ") {
                return URL(string: "https://" + string)
            } else {
                return nil
            }
        }
        
        // Check if the text is a valid URL or can be made into one
        if let url = createURL(withString: text) {
            // Load the URL directly in the WebView
            let request = URLRequest(url: url)
            webView.load(request)
            print("Loading URL: \(url)")
        } else {
            // Treat the text as a Google search query
            let query = text.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
            if let searchURL = URL(string: "https://www.google.com/search?q=\(query)") {
                let request = URLRequest(url: searchURL)
                webView.load(request)
                print("Performing Google search for: \(text)")
            } else {
                print("Invalid search query")
            }
        }
    }
    
    
}

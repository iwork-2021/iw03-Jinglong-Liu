//
//  AboutUsViewController.swift
//  ITSC
//
//  Created by mac on 2021/11/6.
//

import UIKit
import WebKit

class AboutUsViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    override func viewDidLoad() {
            self.loadWeb()
            super.viewDidLoad()
            // Do any additional setup after loading the view.
        }
    
    
        private func loadWeb(){
            print("about")
            let url = URL(string: "https://itsc.nju.edu.cn/xwdt/list.htm")!
            let task = URLSession.shared.dataTask(with: url, completionHandler: {
                data, response, error in
                if let error = error {
                    print("\(error.localizedDescription)")
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse,
                    (200...299).contains(httpResponse.statusCode) else {
                    print("server error")
                    return
                }
                
                if let mimeType = httpResponse.mimeType, mimeType == "text/html",
                            let data = data,
                            let string = String(data: data, encoding: .utf8) {
                                DispatchQueue.main.async {
                                    let lines = string.split(separator: "\r\n")
                                    var flag = false
                                    var timetorecord = false
                                    var content = "<html><body>"
                                    for line in lines{
                                        let symbol = line.split(separator: "\t")
                                        if line == "<!--Start||footer-->"{
                                            flag = true
                                        }
                                        else if line == "<!--End||footer-->"{
                                            flag = false
                                        }
                                        if flag{
                                           
                                            
                                            if !symbol.isEmpty && symbol[0] == "<div class=\"foot-center\">"{
                                                timetorecord = true
                                            }
                                            if !symbol.isEmpty && symbol[0] == "<div class=\"foot-right\" >"{
                                                timetorecord = false
                                            }
                                            if timetorecord && !symbol.isEmpty && symbol[0] != "<div class=\"foot-center\">"{
                                                content += line
                                            }
                                        }
                                    }
                                    content += "</body></html>"
                        self.webView.loadHTMLString(content, baseURL: nil)
                }
                    
            }
        
        })
            task.resume()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

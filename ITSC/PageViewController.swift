//
//  PageViewController.swift
//  ITSC
//
//  Created by mac on 2021/11/6.
//
/*
    concrete page view
 */
import UIKit
import WebKit

class PageViewController: UIViewController {
    @IBOutlet weak var webView: WKWebView!
    var myURL:String=""
    var cache:[String:String]=[:]
    override func viewDidLoad() {
        self.loadWeb()
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    func loadWeb() {
        if self.cache[myURL] != nil{
            self.webView.loadHTMLString(self.cache[myURL]!, baseURL: nil)
            return
        }
        let task = URLSession.shared.dataTask(with: URL(string: self.myURL)!, completionHandler: {
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
                                    var content = "<html>\r\n<meta charset=\"utf-8\">\r\n<base href=\"https://itsc.nju.edu.cn\"/>\r\n"
                                    content += self.header
                                    content += self.htmlBody(string: string)
                                    content += "<html/>"
                                    print(content)

                                    self.webView.loadHTMLString(content, baseURL: nil)
                                    self.cache[self.myURL]=content
                            }
                }
            })
        task.resume()
        task.priority=1
        }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    private func htmlBody(string:String)->String{
        let lines=string.split(separator: "\r\n")
        var body:String = ""
        var start:Bool=false
        for line in lines{
            if line == "<!--Start||content-->"{
                start=true
            }
            else if line == "<!--End||content-->"{
                start=false
            }
            if start{
                body = body + line + "\r\n"
            }
        }
        return body
    }
    let header = """
            <head>
                <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no" />
                <style>
                    body {
                        font-family: "Avenir";
                        font-size: 14px;
                    }
                    img{
                        max-width:360px !important;
                    }
                </style>
            </head>
            """
}

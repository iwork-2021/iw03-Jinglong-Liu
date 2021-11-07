//
//  InfoViewController.swift
//  ITSC
//
//  Created by mac on 2021/11/6.
//

import UIKit
import WebKit

let maxMemory=10

class InfoViewController: UIViewController {
    @IBOutlet weak var webView: WKWebView!
    var myURL:String="www.baidu.com"
    var contentDict:[String:String]=[:]
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.readFile()
        self.loadWeb()
        // Do any additional setup after loading the view.
    }
    
    func loadWeb() {
        if self.contentDict[myURL] != nil{
            self.webView.loadHTMLString(self.contentDict[myURL]!, baseURL: nil)
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
                                    var content="<html>\r\n<meta charset=\"utf-8\">\r\n<base href=\"https://itsc.nju.edu.cn\"/>\r\n"
                                    let lines=string.split(separator: "\r\n")
                                    var start:Bool=false
                                    for i in lines{
                                        if i == "<!--Start||content-->"{
                                            start=true
                                        }
                                        else if i == "<!--End||content-->"{
                                            start=false
                                        }
                                        if start{
                                            content=content+i+"\r\n"
                                        }
                                    }
                                    content+="<html/>\r\n"
                                    

                                    self.webView.loadHTMLString(content, baseURL: nil)
                                    self.contentDict[self.myURL]=content
                                    self.saveFile()
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

    func saveFile(){
        let path:URL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first)!.appendingPathComponent("webSave.json")
        do{
            let data = try JSONEncoder().encode(contentDict)
            try data.write(to: path, options: .atomic)
        }catch{
            print("Can not save: \(error.localizedDescription)")
        }
    }
    
    func readFile(){
        let path:URL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first)!.appendingPathComponent("webSave.json")
        if let data = try? Data(contentsOf: path){
            do{
                contentDict=try JSONDecoder().decode([String:String].self, from: data)
            }catch{
                print("Error decoding list:\(error.localizedDescription)")
            }
        }
    }
    
}

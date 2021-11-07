//
//  News.swift
//  ITSC
//
//  Created by mac on 2021/11/7.
//

import UIKit
class News: NSObject{
    var title:String=""
    var date:String=""
    var url:String=""
    override init(){
    }
    init(title:String,date:String,url:String) {
        self.title = title
        self.date = date;
        self.url = url;
    }
    public func setTitle(title:String) -> News{
        self.title = title;
        return self
    }
    public func setDate(date:String)  -> News{
        self.date = date;
        return self
    }
    public func setUrl(url:String)   -> News{
        self.url = url;
        return self
    }
}

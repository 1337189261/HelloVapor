//
//  File.swift
//  
//
//  Created by chenhaoyu.1999 on 2021/3/22.
//

import Vapor
import Fluent

func mockMoment(on db: Database) {
    let images = (1...3).map {"fm" + String($0) + ".jpg"}.map {$0.imgUrl}
    let moment = Moment(content: "这是我的第一条动态", userId: haoyuId, images: images, location: "北京")
    try! moment.save(on: db).wait()
}

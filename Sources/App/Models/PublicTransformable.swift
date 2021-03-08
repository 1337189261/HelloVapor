//
//  File.swift
//  
//
//  Created by chenhaoyu.1999 on 2021/2/26.
//

import Vapor
import Fluent

protocol PublicTransformable {
    associatedtype PublicType: Content
    func convertToPublic() -> PublicType
}

extension EventLoopFuture where Value: PublicTransformable {
    func convertToPublic() -> EventLoopFuture<Value.PublicType> {
        map { $0.convertToPublic() }
    }
}

extension EventLoopFuture where Value: Collection, Value.Element: PublicTransformable {
    func convertToPublic() -> EventLoopFuture<[Value.Element.PublicType]> {
        map { $0.map { $0.convertToPublic() }}
    }
}

extension Collection where Element: PublicTransformable {
    func convertToPublic() -> [Element.PublicType] {
        map { $0.convertToPublic() }
    }
}

//
//  File.swift
//  
//
//  Created by chenhaoyu.1999 on 2021/2/26.
//

import Vapor
import Fluent

protocol PublicTransformable: Model {
    associatedtype PublicType: PublicTypeProtocol where PublicType.PrivateType == Self
    func convertToPublic() -> PublicType
}

extension PublicTransformable {
    func convertToPublic() -> PublicType {
        PublicType(self)
    }
}

protocol PublicTypeProtocol: Content {
    associatedtype PrivateType
    init(_ privateValue:PrivateType)
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

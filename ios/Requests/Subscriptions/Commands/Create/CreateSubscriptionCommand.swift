//
//  CreateSubscriptionCommand.swift
//  ios
//
//  Created by Mike Pattyn on 28/07/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
import CoreData

class CreateSubscriptionCommand : Codable, RequestProtocol {
    typealias TResponse = Bool
    
    var userId: UUID? = nil
    let amountPerTurn: Int
    let nameSpace: String
    let endsAfterTurns: Int
    let cronExpression: String
    
    enum CodingKeys: String, CodingKey {
        case userId
        case amountPerTurn
        case nameSpace
        case endsAfterTurns
        case cronExpression
    }
    
    internal init(amountPerTurn: Int, nameSpace: String, endsAfterTurns: Int, cronExpression: String) {
        self.amountPerTurn = amountPerTurn
        self.nameSpace = nameSpace
        self.endsAfterTurns = endsAfterTurns
        self.cronExpression = cronExpression
    }
}
extension CreateSubscriptionCommand {
    convenience init(data: Data) throws {
        let me = try newJSONDecoder().decode(CreateSubscriptionCommand.self, from: data)
        self.init(amountPerTurn: me.amountPerTurn, nameSpace: me.nameSpace, endsAfterTurns: me.endsAfterTurns, cronExpression: me.cronExpression)
    }

    convenience init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    convenience init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
func newJSONDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        decoder.dateDecodingStrategy = .iso8601
    }
    return decoder
}

func newJSONEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        encoder.dateEncodingStrategy = .iso8601
    }
    return encoder
}

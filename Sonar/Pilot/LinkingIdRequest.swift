//
//  LinkingIdRequest.swift
//  Sonar
//
//  Created by NHSX.
//  Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

typealias LinkingId = String

class LinkingIdRequest: SecureRequest, Request {
    typealias ResponseType = LinkingId

    let method: HTTPMethod = .put
    let urlable: Urlable

    let decoder = JSONDecoder()

    init(registration: Registration) {
        urlable = .path("/api/residents/\(registration.id.uuidString)/linking-id")

        super.init(registration.secretKey, Data(), [
            "Accept": "application/json"
        ])
    }

    func parse(_ data: Data) throws -> LinkingId {
        let response = try decoder.decode(LinkingIdResponse.self, from: data)
        return response.linkingId
    }

}

fileprivate struct LinkingIdResponse: Codable {
    let linkingId: LinkingId
}
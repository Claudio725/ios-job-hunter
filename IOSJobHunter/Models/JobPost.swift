//
//  JobPost.swift
//  IOSJobHunter
//
//  Created by CLAUDIO JOSE DA SILVA MENEZES MENEZES on 13/10/26.
//

import Foundation

struct JobPost: Identifiable, Codable {
    let id: String
    let title: String
    let company: String
    let location: String
    let description: String
    var email: String
    var matchScore: Int?
    var redirecturl: String

    init(id: String, title: String, company: String, location: String, description: String, email: String,
         matchScore: Int? = nil, redirecturl: String) {
        self.id = id
        self.title = title
        self.company = company
        self.location = location
        self.description = description
        self.email = ""
        self.matchScore = matchScore
        self.redirecturl = redirecturl
    }
}

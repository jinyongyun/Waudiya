//
//  GeocodingOverview.swift
//  waudiya
//
//  Created by mac on 2022/08/08.
//

import Foundation

struct CeocodingOverview: Codable {
    let status: String
    let meta: meta
    let addresses: [addresses]
    let errorMessage: String
    
}

struct meta: Codable {
    let totalCount: Int
    let page: Int
    let count: Int
    
    
}

struct addresses: Codable {
    let roadAddress: String
    let jibunAddress: String
    let englishAddress: String
    let addressElements: [addressElements]
    let x: String
    let y: String
    let distance: Double
    
}

struct addressElements: Codable {
    let types: [String]
    let longName: String
    let shortName: String
    let code: String
    
    
    
}

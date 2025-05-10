//
//  Document.swift
//  UMit
//
//  Created by Yermakhan Kasymzhomart on 10.05.2025.
//

import Foundation

struct Document: Identifiable, Codable {
    let id: Int
    let title: String
    let uploadedAt: String
    let downloadURL: String

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case uploadedAt = "uploaded_at"
        case downloadURL = "download_url"
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        if let date = formatter.date(from: uploadedAt) {
            return DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .short)
        }
        return uploadedAt
    }
}

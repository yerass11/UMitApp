//
//  DocumentsListView.swift
//  UMit
//
//  Created by Yermakhan Kasymzhomart on 10.05.2025.
//

import SwiftUI

struct DocumentsListView: View {
    @ObservedObject var viewModel: DocumentViewModel

    var body: some View {
        NavigationView {
            List(viewModel.documents) { document in
                VStack(alignment: .leading, spacing: 6) {
                    Text(document.title)
                        .font(.headline)

                    Text("Uploaded at: \(document.uploadedAt)")
                        .font(.caption)
                        .foregroundColor(.gray)

                    Link("Download / View", destination: URL(string: document.downloadURL)!)
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                .padding(.vertical, 6)
            }
            .navigationTitle("Documents")
        }
    }
}

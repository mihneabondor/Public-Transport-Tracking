//
//  ComunicateView.swift
//  Public Transport Tracking
//
//  Created by Mihnea on 4/10/23.
//

import SwiftUI
import FeedKit

struct ComunicateView: View {
    @State private var feed = [News]()
    var body: some View {
        NavigationStack {
            ScrollView{
                Text(" ")
                ForEach(feed, id: \.self) {item in
                    Button{
                        guard let url = URL(string: item.link ?? "") else { return }
                        UIApplication.shared.open(url)
                    } label: {
                        VStack{
                            Text(item.title ?? "")
                                .bold()
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading)
                            Text("\(item.description ?? "") **Citeste mai mult.**")
                                .padding([.leading, .trailing])
                                .foregroundColor(Color(UIColor.systemGray))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading)
                            Divider()
                                .tint(.purple)
                                .foregroundColor(.purple)
                        }
                    }
                }
            }
            .navigationTitle("Comunicate")
        }
        .onAppear() {
            Task {
                let decodedFeed = try? await RequestManager().getNews()
                for item in decodedFeed?.items ?? [] {
                    var newFeedItem = News(link: item.link, title: item.title, description: item.description)
                    newFeedItem.description = newFeedItem.description?.replacingOccurrences(of: "<b>", with: "")
                    newFeedItem.description = newFeedItem.description?.replacingOccurrences(of: "</b>", with: "")
                    newFeedItem.description = newFeedItem.description?.replacingOccurrences(of: "<h5>", with: "")
                    newFeedItem.description = newFeedItem.description?.replacingOccurrences(of: "</h5>", with: "")
                    newFeedItem.description = newFeedItem.description?.replacingOccurrences(of: "<p>", with: "")
                    newFeedItem.description = newFeedItem.description?.replacingOccurrences(of: "</p>", with: "")
                    newFeedItem.description = newFeedItem.description?.replacingOccurrences(of: "În atenția publicului călător  !", with: "")
                    newFeedItem.description = newFeedItem.description?.trimmingCharacters(in: .whitespacesAndNewlines)
                    feed.append(newFeedItem)
                }
            }
        }
    }
}

struct ComunicateView_Previews: PreviewProvider {
    static var previews: some View {
        ComunicateView()
    }
}

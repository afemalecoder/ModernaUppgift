//
//  apiView.swift
//  ModernaUppgift3
//
//  Created by Matilda Cederberg on 26/12/2023.
//
import SwiftUI

struct BreedsResponse: Codable {
    let message: [String: [String]]
    let status: String
}

struct ImagesResponse: Codable {
    let message: String
    let status: String
}

struct apiView: View {
    @State private var breeds: [String] = []
    @State private var dogImages: [String: String] = [:]

    func fetchBreeds() {
        guard let url = URL(string: "https://dog.ceo/api/breeds/list/all") else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }

            do {
                let decodedData = try JSONDecoder().decode(BreedsResponse.self, from: data)
                DispatchQueue.main.async {
                    self.breeds = Array(decodedData.message.keys)
                }
            } catch {
                print("Error decoding breed JSON: \(error)")
            }
        }.resume()
    }

    func fetchImagesForBreed(breedName: String) {
        guard let url = URL(string: "https://dog.ceo/api/breed/\(breedName)/images/random") else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }

            do {
                let decodedData = try JSONDecoder().decode(ImagesResponse.self, from: data)
                DispatchQueue.main.async {
                    self.dogImages[breedName] = decodedData.message
                }
            } catch {
                print("Error decoding image JSON: \(error)")
            }
        }.resume()
    }

    var body: some View {
        VStack {
            Button("Fetch Images for Breeds") {
                for breed in breeds {
                    fetchImagesForBreed(breedName: breed)
                }
            }
            .padding()

            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(breeds, id: \.self) { breed in
                        if let imageUrl = dogImages[breed] {
                            VStack {
                                AsyncImage(url: URL(string: imageUrl)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 100, height: 100)
                                } placeholder: {
                                    ProgressView()
                                        .frame(width: 100, height: 100)
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                
                                Text(breed)
                                    .padding(.top, 8)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding()
            }
        }
        .onAppear {
            fetchBreeds()
        }
    }
}

import Foundation

enum Explicitness: String, Decodable {
	case explicit, clean, notExplicit
}

struct SearchResult: Decodable {

	let trackName: String?
	let trackExplicitness: Explicitness?
	let trackViewURL: URL?
	let previewURL: URL?
	let artistName: String?
	let collectionName: String?
	let artworkURL100: URL?

	enum CodingKeys: String, CodingKey {
		case trackName
		case trackExplicitness
		case trackViewURL = "trackViewUrl"
		case previewURL = "previewUrl"
		case artistName
		case collectionName
		case artworkURL100 = "artworkUrl100"
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.trackName = try container.decodeIfPresent(String.self, forKey: .trackName)
		self.trackExplicitness = try container.decodeIfPresent(Explicitness.self, forKey: .trackExplicitness)
		self.trackViewURL = try container.decodeIfPresent(URL.self, forKey: .trackViewURL)
		self.previewURL = try container.decodeIfPresent(URL.self, forKey: .previewURL)
		self.artistName = try container.decodeIfPresent(String.self, forKey: .artistName)
		self.collectionName = try container.decodeIfPresent(String.self, forKey: .collectionName)
		self.artworkURL100 = try container.decodeIfPresent(URL.self, forKey: .artworkURL100)
	}
}

extension SearchResult {
	func artworkURL(size dimension: Int = 100) -> URL? {
		guard dimension > 0, dimension != 100, var url = self.artworkURL100 else {
			return self.artworkURL100
		}
		url.deleteLastPathComponent()
		url.appendPathComponent("\(dimension)x\(dimension)bb.jpg")
		return url
	}
}

struct SearchResponse: Decodable {
	let results: [SearchResult]
}

extension SearchResponse {
	var nonExplicitResults: [SearchResult] {
		self.results.filter { $0.trackExplicitness != .explicit }
	}
}

// MARK: - Downloading

var dataTask: URLSessionDataTask? = nil
var results: [SearchResult] = []

func search<T>(for type: T.Type, with term: String) where T: MediaType {
	let components = AppleiTunesSearchURLComponents<T>(term: term)
	guard let url = components.url else {
		fatalError("Error creating URL")
	}
	self.dataTask?.cancel()
	self.dataTask = URLSession.shared.dataTask(with: url) {
		(data, response, error) in
		guard let data = data, error == nil else {
			fatalError("Networking error \(error) \(response)")
	}
		do {
			let decoder = JSONDecoder()
			let searchResponse =
				try decoder.decode(SearchResponse.self, from: data)
			self.results = searchResponse.nonExplicitResults
		} catch {
			fatalError("Decoding error \(error)")
	}
		DispatchQueue.main.async {
			self.tableView.reloadData()
	} }
	self.dataTask?.resume()
}

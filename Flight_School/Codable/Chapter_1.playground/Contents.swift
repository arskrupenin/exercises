import Foundation

let json = """
{
	"manufacturer": "Cessna",
	"model": "172 Skyhawk",
	"seats": 4,
}
""".data(using: .utf8)!

let json2 = """
[
	{
		"manufacturer": "Piper",
		"model": "PA-28 Cherokee",
		"seats": 4
	},
	{
		"manufacturer": "Cessna",
		"model": "172 Skyhawk",
		"seats": 4
	}
]
""".data(using: .utf8)!

struct Plane: Codable {

	var manufacturer: String
	var model: String
	var seats: Int

	enum Keys: String, CodingKey {
		case manufacturer, model, seats
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: Keys.self)
		self.manufacturer = try container.decode(String.self, forKey: .manufacturer)
		self.seats = try container.decode(Int.self, forKey: .seats)
		self.model = try container.decode(String.self, forKey: .model)
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: Keys.self)
		try container.encode(self.manufacturer, forKey: .manufacturer)
		try container.encode(self.seats, forKey: .seats)
		try container.encode(self.model, forKey: .model)
	}
}

let decoder = JSONDecoder()
let encoder = JSONEncoder()
let plane = try decoder.decode(Plane.self, from: json)
let data = try encoder.encode(plane)

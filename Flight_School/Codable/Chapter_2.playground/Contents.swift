import Foundation

let json = """
{
	"aircraft": {
		"identification": "NA12345",
		"color": "Blue/White"
	},
	"route": ["KTTD", "KHIO"],
	"flight_rules": "VFR",
	"departure_time": {
		"proposed": "2018-04-20T14:15:00-07:00",
		"actual": "2018-04-20T14:20:00-07:00"
	},
	"remarks": null
}
""".data(using: .utf8)!

struct Aircraft: Decodable {
	var identification: String
	var color: String
}

enum FlightRules: String, Decodable {
	case visual = "VFR"
	case instrument = "IFR"
}

struct FlightPlan: Decodable {
	var aircraft: Aircraft
	var route: [String]
	var flightRules: FlightRules
	var remarks: String?
	private var departureDates: [String: Date]

	var proposedDepartureDate: Date? { departureDates["proposed"] }

	var actualDepartureDate: Date? { departureDates["actual"] }

	private enum CodingKeys: String, CodingKey {
		case aircraft
		case flightRules = "flight_rules"
		case route
		case departureDates = "departure_time"
		case remarks
	}
}

var decoder = JSONDecoder()
//decoder.keyDecodingStrategy = .convertFromSnakeCase
decoder.dateDecodingStrategy = .iso8601

do {
	let flightPlan = try decoder.decode(FlightPlan.self, from: json)
	print(flightPlan)
} catch {
	print("error")
}

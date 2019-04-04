import Cocoa
import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true;

let apiKey: String = "2dd8f457671f8f42cf85af02cf47ca48";

let currentWeatherUrl: String = "https://api.openweathermap.org/data/2.5/weather"
let currentWeatherUrlGroup: String = "https://api.openweathermap.org/data/2.5/group"
let forecastUrl: String = "https://api.openweathermap.org/data/2.5/forecast"

extension URL {
    func withQueries(_ queries: [String: String]) -> URL? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
        components?.queryItems = queries.map {
            URLQueryItem(name: $0.0, value: $0.1)
        }
        return components?.url
    }
}
extension String: Error {}

struct Weather: Codable {
    
    enum WeatherType: String, Codable {
        case Thunderstorm, Drizzle, Snow, Atmosphere, Clear, Clouds, Mist, Smoke, Haze, Dust, Fog, Sand, Ash, Squall, Tornado, Rain
    }
    
    let main: WeatherType
    let description: String
}

struct Main: Codable {
    let temp, pressure, humidity, temp_min, temp_max, sea_level, grnd_level: Float?
}

struct Wind: Codable {
    let speed, deg: Float?
}

struct Clouds: Codable {
    let all: Float?
}

struct Rain: Codable {
    let one: Float?
    let three: Float?
    private enum CodingKeys: String, CodingKey {
        case one = "1h"
        case three = "3h"
    }
}

struct Snow: Codable {
    let one: Float?
    let three: Float?
    private enum CodingKeys: String, CodingKey {
        case one = "1h"
        case three = "3h"
    }
}

struct City: Codable {
    let name: String
    let country: String
}

struct Current: Codable {
    let weather: [Weather]
    let main: Main
    let wind: Wind?
    let rain: Rain?
    let clouds: Clouds?
    let snow: Snow?
    let dt: Int
    let name: String
}

struct ForecastListElem: Codable {
    let weather: [Weather]
    let main: Main
    let wind: Wind?
    let rain: Rain?
    let clouds: Clouds?
    let snow: Snow?
    let dt: Int
}

struct MultipleIdCurrent: Codable {
    let list: [Current]
}

struct Forecast: Codable { //returned by either a call on multiple cities or a call on the 5 days API
    let list: [ForecastListElem]
    let city: City
}

func readJson() -> [String: String]? {
    struct City: Codable {
        let id: Int
        let name: String
    }
    do {
        if let file = Bundle.main.url(forResource: "current.city.list.min", withExtension: "json") {
            let data = try Data(contentsOf: file)
            let  cities = try JSONDecoder().decode([City].self, from: data)
            var citiesDictionary = [String: String]();
            for (city) in cities {
                let name = city.name.lowercased()
                citiesDictionary[name] = String(city.id)
            }
            return citiesDictionary;
        } else {
            print("no file")
            return nil;
        }
    } catch {
        print("error")
        print(error.localizedDescription)
    }
    return nil;
}

func getCityIdByName (cityName: String, cityDic: [String: String]) -> String? {
    if let cityId = cityDic[cityName.lowercased()] {
        return cityId;
    } else {
        return nil;
    }
}

// will return current weather for one city
func getWeatherForId(cityId: String) -> Void {

    let query: [String: String] = [
        "id": cityId,
        "APPID": apiKey
    ]
    
    let url = URL(string: currentWeatherUrl)!.withQueries(query)!
    print("url \(url)");
    let task = URLSession.shared.dataTask(with: url){ (data, response, error) -> Void in
        if let error = error {
            print(error)
        }
        if let data = data {
            if let goodData = try? JSONDecoder().decode(Current.self, from: data) {
                print(goodData)
            } else {
                if let string = String(data: data, encoding: .utf8) {
                    print(string)
                } else {
                    print("unkownError")
                }
            }
        }
    }
    task.resume();
}

// will return current weather for multiple cities
func getWeatherForIds(cityIds: [String]) -> Void {
    let cityIdsAsString: String = cityIds.reduce("") { (acc, val) -> String in
        return acc + val + ","
    }
    
    let correctCityIdsAsString = cityIdsAsString.trimmingCharacters(in: CharacterSet(charactersIn: ","))
    
    let query: [String: String] = [
        "id": correctCityIdsAsString,
        "APPID": apiKey
    ]
    
    let url = URL(string: currentWeatherUrlGroup)!.withQueries(query)!
    print("url \(url)");
    let task = URLSession.shared.dataTask(with: url){ (data, response, error) -> Void in
        if let error = error {
            print(error)
        }
        if let data = data {
            if let goodData = try? JSONDecoder().decode(MultipleIdCurrent.self, from: data) {
                print(goodData)
            } else {
                if let string = String(data: data, encoding: .utf8) {
                    print(string)
                } else {
                    print("unkownError")
                }
            }
        }
    }
    task.resume();
}

//will return 5 days forecast for one city
func getForecastForId(cityId: String) -> Void {
    let query: [String: String] = [
        "id": cityId,
        "APPID": apiKey
    ]
    
    let url = URL(string: forecastUrl)!.withQueries(query)!
    print("url \(url)");
    let task = URLSession.shared.dataTask(with: url){ (data, response, error) -> Void in
        if let error = error {
            print(error)
        }
        if let data = data {
            if let goodData = try? JSONDecoder().decode(Forecast.self, from: data) {
                print(goodData)
            } else {
                if let string = String(data: data, encoding: .utf8) {
                    print(string)
                } else {
                    print("unkownError")
                }
            }
        }

    }
    task.resume();
}

do {
    guard let cityDic = readJson() else {
        print("unable to parse json file")
        throw "Error"
    }
    print("parsedJsonFile")
    guard let cityId = getCityIdByName(cityName: "Marseille", cityDic: cityDic) else {
        print("city1 not found")
        throw "Error"
    }
    
    guard let cityId2 = getCityIdByName(cityName: "Bordeaux", cityDic: cityDic) else {
        print("city2 not found")
        throw "Error"
    }
    //for one city
    getWeatherForId(cityId: cityId)
    
    //for multiple cities
    getWeatherForIds(cityIds: [cityId, cityId2])
    
    //a 5 days forecast on One city
    getForecastForId(cityId: cityId)
    
} catch {
    print("unable to go further")
}

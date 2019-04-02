import Cocoa
import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true;

let apiKey: String = "2dd8f457671f8f42cf85af02cf47ca48";

let currentWeatherUrl: String = "https://api.openweathermap.org/data/2.5/weather"
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

struct CurrentWeather: Codable {
    
    struct Weather: Codable {
        let main: String
        let description: String
        
        enum MyStructKeys: String, CodingKey {
            case main = "main"
            case description = "description"
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: MyStructKeys.self)
            self.main = try container.decodeIfPresent(String.self, forKey: .main) ?? ""
            self.description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
        }
        
        init() {
            self.main = ""
            self.description = ""
        }
    }
    
    struct Main: Codable {
        let temp, pressure, humidity, temp_min, temp_max, sea_level, grnd_level: Float
        
        enum MyStructKeys: String, CodingKey {
            case temp, pressure, humidity, temp_min, temp_max, sea_level, grnd_level
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: MyStructKeys.self)
            self.temp = try container.decodeIfPresent(Float.self, forKey: .temp) ?? 0.0
            self.pressure = try container.decodeIfPresent(Float.self, forKey: .pressure) ?? 0.0
            self.humidity = try container.decodeIfPresent(Float.self, forKey: .humidity) ?? 0.0
            self.temp_min = try container.decodeIfPresent(Float.self, forKey: .temp_min) ?? 0.0
            self.temp_max = try container.decodeIfPresent(Float.self, forKey: .temp_max) ?? 0.0
            self.sea_level = try container.decodeIfPresent(Float.self, forKey: .sea_level) ?? 0.0
            self.grnd_level = try container.decodeIfPresent(Float.self, forKey: .grnd_level) ?? 0.0
        }
        
        init() {
            self.temp = 0.0
            self.pressure = 0.0
            self.humidity = 0.0
            self.temp_min = 0.0
            self.temp_max = 0.0
            self.sea_level = 0.0
            self.grnd_level = 0.0
        }
    }
    
    struct Wind: Codable {
        let speed, deg: Float
        
        enum MyStructKeys: String, CodingKey {
            case speed, deg
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: MyStructKeys.self)
            self.speed = try container.decodeIfPresent(Float.self, forKey: .speed) ?? 0.0
            self.deg = try container.decodeIfPresent(Float.self, forKey: .deg) ?? 0.0
        }
        
        init() {
            self.speed = 0.0
            self.deg = 0.0
        }
    }
    
    struct Clouds: Codable {
        let all: Float
        
        enum MyStructKeys: String, CodingKey {
            case all
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: MyStructKeys.self)
            self.all = try container.decodeIfPresent(Float.self, forKey: .all) ?? 0.0
        }
        
        init() {
            self.all = 0.0
        }
    }
    
    struct Rain: Codable {
        let one, three: String
        
        private enum MyStructKeys: String, CodingKey {
            case one = "1h"
            case three = "3h"
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: MyStructKeys.self)
            self.one = try container.decodeIfPresent(String.self, forKey: .one) ?? ""
            self.three = try container.decodeIfPresent(String.self, forKey: .three) ?? ""
        }
        
        init() {
            self.one = ""
            self.three = ""
        }
    }
    
    struct Snow: Codable {
        let one, three: String
        
        private enum MyStructKeys: String, CodingKey {
            case one = "1h"
            case three = "3h"
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: MyStructKeys.self)
            self.one = try container.decodeIfPresent(String.self, forKey: .one) ?? ""
            self.three = try container.decodeIfPresent(String.self, forKey: .three) ?? ""
        }
        
        init() {
            self.one = ""
            self.three = ""
        }
    }
    
    let weather: [Weather]
    let main: Main
    let wind: Wind
    let rain: Rain
    let clouds: Clouds
    let snow: Snow
    let dt: Int
    let name: String

    enum MyStructKeys: String, CodingKey {
        case weather, main, clouds, wind, rain, snow, dt, name
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: MyStructKeys.self)
        self.weather = try container.decodeIfPresent([Weather].self, forKey: .weather) ?? [Weather()]
        self.main = try container.decodeIfPresent(Main.self, forKey: .main) ?? Main()
        self.wind = try container.decodeIfPresent(Wind.self, forKey: .wind) ?? Wind()
        self.rain = try container.decodeIfPresent(Rain.self, forKey: .rain) ?? Rain()
        self.snow = try container.decodeIfPresent(Snow.self, forKey: .snow) ?? Snow()
        self.clouds = try container.decodeIfPresent(Clouds.self, forKey: .clouds) ?? Clouds()
        self.dt = try container.decodeIfPresent(Int.self, forKey: .dt) ?? 0
        self.name = try container.decode(String.self, forKey: .name) ?? ""
    }
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
                citiesDictionary[city.name] = String(city.id)
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

func getForecastForCityName (cityName: String, cityDic: [String: String]) -> String? {
    if let cityId = cityDic[cityName] {
        return cityId;
    } else {
        print("cityNotFound");
        return nil;
    }
}

func getCurrentWeatherForCityId(cityId: String, completionHandler: @escaping (CurrentWeather?, String?, Error?) -> Void) -> URLSessionTask {
    
    let query: [String: String] = [
        "id": cityId,
        "APPID": apiKey
    ]
    
    let url = URL(string: currentWeatherUrl)!.withQueries(query)!
    let task = URLSession.shared.dataTask(with: url){ (data, response, error) -> Void in
        if let error = error {
            completionHandler(nil, nil, error)
        }
        if let data = data {
            if let goodData = try? JSONDecoder().decode(CurrentWeather.self, from: data) {
                completionHandler(goodData, nil, nil);
                return;
            } else {
                if let string = String(data: data, encoding: .utf8) {
                    completionHandler(nil, string, nil)
                } else {
                    completionHandler(nil, "unknownError", nil)
                }
            }
        }
    }
    task.resume();
    return task;
}

if let cityDic = readJson() {
    if let cityId = getForecastForCityName(cityName: "Paris", cityDic: cityDic) {
        getCurrentWeatherForCityId(cityId: cityId) { currentWeather, string, error in
            if let error = error {
                print("error")
                print(error);
            }
            
            if let string = string {
                print("string")
                print(string);
            }
            
            if let currentWeather = currentWeather {
                print("currentWeather")
                print(currentWeather)
            }
            print("over")
            PlaygroundPage.current.finishExecution()
        }
    }
}


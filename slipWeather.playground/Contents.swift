import Cocoa
import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true;

let apiKey: String = "2dd8f457671f8f42cf85af02cf47ca48";

extension URL {
    func withQueries(_ queries: [String: String]) -> URL? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
        components?.queryItems = queries.map {
            URLQueryItem(name: $0.0, value: $0.1)
        }
        return components?.url
    }
}

struct Forecast: Codable {
    
    let weather: [Weather]
    let wind: Wind
    //let rain: Rain
    let clouds: Clouds
    
    struct Weather: Codable {
        let main: String
        let description: String
    }
    
    struct Wind: Codable {
        let speed: Float
    }
    
    struct Rain: Codable {
        let type: String
        
        private enum MyStructKeys: String, CodingKey {
            case type = "3h"
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: MyStructKeys.self) // defining our (keyed) container
            self.type = try container.decode(String.self, forKey: .type)
        }
    }
    
    struct Clouds: Codable {
        let all: Int
    }

    enum MyStructKeys: String, CodingKey {
        case weather = "weather"
        case wind = "wind"
        case rain = "rain"
        case clouds = "clouds"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: MyStructKeys.self) // defining our (keyed) container
        self.weather = try container.decode([Weather].self, forKey: .weather) // extracting the data
        self.wind = try container.decode(Wind.self, forKey: .wind) // extracting the data
        //self.rain = try container.decode(Rain.self, forKey: .rain) // extracting the data
        self.clouds = try container.decode(Clouds.self, forKey: .clouds) // extracting the data
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

func getForecastForCityId(cityId: String, completionHandler: @escaping (Forecast?, String?, Error?) -> Void) -> URLSessionTask {
    
    let query: [String: String] = [
        "id": cityId,
        "APPID": apiKey
    ]
    
    let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?")!.withQueries(query)!
    let task = URLSession.shared.dataTask(with: url){ (data, response, error) -> Void in
        if let error = error {
            completionHandler(nil, nil, error)
        }
        if let data = data {
            if let goodData = try? JSONDecoder().decode(Forecast.self, from: data) {
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
        getForecastForCityId(cityId: cityId) { forecast, string, error in
            if let error = error {
                print("error")
                print(error);
            }
            
            if let string = string {
                print("string")
                print(string);
            }
            
            if let forecast = forecast {
                print("forecast")
                print(forecast)
            }
            print("over")
            PlaygroundPage.current.finishExecution()
        }
    }
}


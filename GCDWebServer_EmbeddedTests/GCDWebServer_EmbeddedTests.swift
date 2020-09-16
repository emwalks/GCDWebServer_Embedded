//
//  GCDWebServer_EmbeddedTests.swift
//  GCDWebServer_EmbeddedTests
//
//  Created by Emma Walker - TVandMobile Platforms - Core Engineering on 02/03/2020.
//  Copyright © 2020 Emma Walker - TVandMobile Platforms - Core Engineering. All rights reserved.
//
//  https://github.com/swisspol/GCDWebServer
//  https://github.com/bbc/iOSNotWireMock/blob/master/iOSNotWireMockTests/iOSNotWireMockTests.swift#L18-L27


import XCTest
@testable import GCDWebServer_Embedded
import GCDWebServer

class GCDWebServer_EmbeddedTests: XCTestCase {
    
    var webServer: GCDWebServer? = nil
    
    struct FruitData : Codable {
        var fruit : [Fruit]
    }
    
    struct Fruit : Codable {
        var type : String
        var price : Int
        var weight : Int
    }
    
    func jsonEncoder() -> Data? {
        let encoder = JSONEncoder()
        
        do {
            let fruitsJSON = try encoder.encode(Fruit(type: "Apple", price: 149, weight: 120))
            return fruitsJSON
        } catch {
            print(error)
            return nil
        }
    }
    
    func initDefaultWebServer() {
        
        webServer = GCDWebServer()
        
        webServer?.addDefaultHandler(forMethod: "GET", request: GCDWebServerRequest.self, processBlock: {request in
            return GCDWebServerDataResponse(html:"<html><body><p>Hello World</p></body></html>")
            
        })
        
        webServer?.start(withPort: 8080, bonjourName: "GCD Web Server")
        
        print("Visit \(webServer?.serverURL) in your web browser")
    }
    
    func fruitJSONWebServer(){
        webServer = GCDWebServer()
        
        let fruitAsJson = jsonEncoder()
        
        webServer?.addDefaultHandler(forMethod: "POST", request: GCDWebServerRequest.self, processBlock: {request in
            return GCDWebServerDataResponse(jsonObject: fruitAsJson)
            
        })
        //need to encode a JSON using JSON Encoder?
        
        webServer?.start(withPort: 8080, bonjourName: "GCD Web Server")
        
        print("Visit \(webServer?.serverURL) in your web browser")
    }
    enum NetworkingError: Error {
        case dataNotFound
        case noInternetConnection
        case dataDecodingError
        
        var caseId: String {
            switch self {
            case .dataNotFound:
                return "noData"
            case .noInternetConnection:
                return "noInternet"
            case .dataDecodingError:
                return "wrongDataType"
            }
        }
    }
    
    class NetworkService {
        func get(url: URL, completion: @escaping (Data?, NetworkingError?) -> Void) {
            let dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
                print("Data: \(data)")
                print("Response \(response)")
                print("Error \(error)")
                
                if response == nil {
                    completion(nil, NetworkingError.noInternetConnection)
                }
                if let data = data {
                    completion(data, nil)
                }
                if error != nil {
                    completion(nil, NetworkingError.dataNotFound)
                }
            }
            dataTask.resume()
            
        }
    }
    
    //func testDefaultWebServer(){
    //    initDefaultWebServer()
    //    XCTAssertNotNil(webServer?.serverURL)
    //    XCTAssertEqual(webServer?.
    //    sleep(20)
    //
    //}
    //
    //func testFruitWebServerResponse(){
    //    fruitJSONWebServer()
    //    sleep(20)
    //
    //}
    
    func testWhenGetRequestIsMadeToAURLDataIsReturned(){
        // Given
        initDefaultWebServer()
        
        sleep(5)
        
        let expectation = XCTestExpectation(description: "Download fruit Data")
        
        let networkService = NetworkService()
        
        let url = URL(string: "http://10.100.18.60:8080/")
     
        // When
        networkService.get(url: url!) { data, error  in
            // Then
            XCTAssertNotNil(data, "No data retrieved")
            XCTAssertNil(error)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
        
    }
    
    func testWhenGetRequestIsMadeToAWebServerDataIsReturned(){
        // Given
        
        fruitJSONWebServer()
        sleep(5)
        
        let expectation = XCTestExpectation(description: "Download fruit Data")
        
        let networkService = NetworkService()
        
        let url = URL(string: "http://10.100.18.60:8080/")
        // When
        networkService.get(url: url!) { data, error  in
            // Then
            XCTAssertNotNil(data, "No data retrieved")
            XCTAssertNil(error)
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let fruitList = try decoder.decode([Fruit].self, from: data)
                    print(fruitList)
                } catch {
                    print(error)
                }
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
        
    }
    
    
    
    
}

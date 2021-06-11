//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Zion Tuiasoa 1/10/21.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate {
    func didUpdate(with coinModel: CoinModel)
    func didFail(with error: Error)
}

struct CoinManager {
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    var currencyURL = "/USD"
    let apiKey = "?apikey=C0330A63-D199-484E-962A-ED93FA7B5020"
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    var delegate: CoinManagerDelegate?
    
    mutating func getCoinPrice(for currency: String) {
        currencyURL = "/\(currency)"
        let coinPrice = baseURL + currencyURL + apiKey
        performRequest(with: coinPrice)
    }
    
    func performRequest(with url: String) {
        
        // Create URL
        guard let url = URL(string: url) else {
            print("Couldn't create URL from dat string")
            return
        }
        
        // Create Network Session
        let session = URLSession(configuration: .default)
        
        // Make Request
        let task = session.dataTask(with: url) { (data, resonse, error) in
            
            // Check for Error
            if let unwrappedError = error {
                DispatchQueue.main.async {
                    delegate?.didFail(with: unwrappedError)
                }
                return
            }
            
            // Make sure weather data exists
            guard let unwrappedData = data else {
                print("Data is nil")
                return
            }
            
            // Turn JSON into our Weather object
            guard let updatedCoinModel = self.parseJSON(unwrappedData) else {
                print("Couldn't get data from JSON")
                return
            }
            // Tell the delegate (the UI) to update it's UI with latest weather data
            DispatchQueue.main.async {
                delegate?.didUpdate(with: updatedCoinModel)
            }
        }
        
        // Continue checking for network response in the background
        task.resume()
    }
    
    func parseJSON(_ data: Data) -> CoinModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CoinModel.self , from: data)
            return decodedData
            
        } catch let error {
            DispatchQueue.main.async {
                delegate?.didFail(with: error)
            }
            return nil
        }
    }
}

struct CoinModel: Codable {
    let time: String
    let asset_id_base: String
    let asset_id_quote: String
    let rate: Double
}

/*"time": "2021-01-14T22:07:30.7387120Z",
"asset_id_base": "BTC",
"asset_id_quote": "USD",
"rate": 38708.647105623225313228377594
} */

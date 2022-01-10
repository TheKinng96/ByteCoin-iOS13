//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate {
    func didUpdateCurrency(price: String, currency: String)
    func updateFailed(error: Error)
}

extension Double {
    func withCommas() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 2
        return numberFormatter.string(from: NSNumber(value:self))!
    }
}

struct CoinManager {
    var delegate: CoinManagerDelegate?

    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "AB37CAAE-44F9-4599-AF46-BD21255B1DD3"
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]

    func getCoinPrice(for currency: String) {
        let urlString = "\(baseURL)/\(currency)?apikey=\(apiKey)"

        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, URLResponse, error) in
                if error != nil {
                    self.delegate?.updateFailed(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let bitcoinPrice = parseJSON(safeData) {
                        self.delegate?.didUpdateCurrency(price: bitcoinPrice.withCommas(), currency: currency)
                    }
                }
            }
            
            task.resume()
        }
    }
}

func parseJSON(_ data: Data) -> Double? {
    let decoder = JSONDecoder()
    do {
        let decodedData = try decoder.decode(CoinData.self, from: data)
        let currentRate = decodedData.rate;
        print(currentRate)
        return currentRate
    } catch {
        return nil
    }
}

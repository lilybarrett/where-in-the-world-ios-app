//
//  ViewController.swift
//  GDI Class App 2
//
//  Created by Lily Barrett1 on 2/20/18.
//  Copyright © 2018 Lily Barrett1. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var Picture: UIImageView!
    @IBOutlet var tableView: UITableView!
    
    let flickrUrl = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=51e35c229eb831ee98ec4530983f991c&safe_search=1&content_type=1&media=photos&accuracy=3&per_page=1&page=1&format=json&nojsoncallback=1"
    let countries = [
        "Afghanistan",
        "Albania",
        "Algeria",
        "Angola",
        "Argentina",
        "Australia",
        "Austria",
        "The Bahamas",
        "Belgium",
        "Botswana",
        "Brazil",
        "Bulgaria",
        "Canada",
        "Chile",
        "China",
        "Costa Rica",
        "Cuba",
        "Denmark",
        "Dominican Republic",
        "Egypt",
        "Ethiopia",
        "Finland",
        "France",
        "Germany",
        "Greece",
        "Guatemala",
        "Haiti",
        "Hong Kong",
        "Iceland",
        "India",
        "Iran",
        "Iraq",
        "Ireland",
        "Israel",
        "Italy",
        "Jamaica",
        "Japan",
        "Kazakhstan",
        "Kenya",
        "Lebanon",
        "Libya",
        "Mexico",
        "Morocco",
        "Netherlands",
        "New Zealand",
        "North Korea",
        "Norway",
        "Pakistan",
        "Peru",
        "Poland",
        "Portugal",
        "Russia",
        "Rwanda",
        "Spain",
        "South Korea",
        "Sweden",
        "Switzerland",
        "Thailand",
        "Uganda",
        "United Kingdom",
        "United States",
        "Venezuela",
        "Vatican City",
        "Zimbabwe"
    ]
    var selectedCountry = "United States"
    var guesses: [String] = []
    var guessedCountry: String?
    var shouldShowAnswer = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label.text = selectedCountry
        button.setTitle("press me", for: .normal)
    }
    
    
    @IBAction func buttonWasClicked(_ sender: Any) {
        shouldShowAnswer = false
        let count = countries.count
        let index = Int(arc4random_uniform(UInt32(count)))
        selectedCountry = countries[index]
        
        let searchURL = createFlickrSearchUrl(for: selectedCountry)
        var uniqueGuesses = Set<String>()
        uniqueGuesses.insert(selectedCountry)
        
        while uniqueGuesses.count < 4 {
            let randomIndex = Int(arc4random_uniform(UInt32(count)))
            uniqueGuesses.insert(countries[randomIndex])
        }
        guesses = Array(uniqueGuesses)
        self.makePictureRequest(with: searchURL)
        tableView.reloadData()
    }
    
    func createFlickrSearchUrl(for searchterm: String) -> String{
        guard let encodedSearchTerm = searchterm.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
                print("Something weng wrong")
                return flickrUrl
            }
            return flickrUrl + "&text=\(encodedSearchTerm)"
    }
    
    func makePictureRequest(with urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Error something went wrong")
            return
        }
        
        let request = URLRequest(url: url)
        let session = URLSession(configuration: .default)
        let datatask = session.dataTask(with: request) { [weak self] (data, response, error) in
            guard let responseData = data else {
                print("Something went wrong")
                return
            }
            let decoder = JSONDecoder()
            do {
                let photoResponse = try decoder.decode(PhotoResponse.self, from: responseData)
                let imageUrl = photoResponse.photos.photo.first?.imageUrl()
                self?.displayImage(from: imageUrl!)
            } catch let jsonError {
                
            }
        }
        datatask.resume()
    }
    
    private func displayImage(from imageUrl: URL) {
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let imageRequest = URLRequest(url: imageUrl)
        
        let imageTask = session.dataTask(with: imageRequest) { [weak self] (data, response, error) in
            guard let imageData = data, error == nil, let image = UIImage(data: imageData) else {
                print("Something went wrong in getting the image.")
                return
            }
            // All UI Updates must be done on the main thread - so you put them in this closure
            DispatchQueue.main.async {
                // Display image and change label text to be a question
                self?.Picture.image = image
                self?.label.text = "Where in the World is This?"
            }
        }
        imageTask.resume()
    }
    
    // MARK:- UITableViewDataSource Methods
    
    func tableView( _ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return guesses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CountryCellIdentifier", for: indexPath)
        cell.backgroundColor = UIColor.white
        cell.textLabel?.textColor = UIColor.darkText
        if guesses.count > indexPath.row {
            let guess = guesses[indexPath.row]
            cell.textLabel?.text = guess
            
            if shouldShowAnswer {
                if guess == selectedCountry {
                    cell.backgroundColor = UIColor.green
                    cell.textLabel?.textColor = UIColor.white
                } else if guess == guessedCountry  {
                    cell.backgroundColor = UIColor.red
                }
            }
        }
        return cell
    }
    
    // MARK: - UITableViewDelegateMethods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        shouldShowAnswer = true
        if guesses.count > indexPath.row {
            guessedCountry = guesses[indexPath.row]
        }
        if guessedCountry == selectedCountry {
            label.text = "Congratulations! You got the right answer!"
        } else {
            label.text = "Wrong answer! The answer was \(selectedCountry). Better luck next time."
        }
    }
}



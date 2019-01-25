//
//  MovieController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class MovieController {
    private let moc = CoreDataStack.shared.mainContext
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    private let firebaseURL = URL(string: "https://iossprint4project.firebaseio.com/")!
    
    typealias CompletionHandler = (Error?) -> Void
    
    func searchForMovie(with searchTerm: String, completion: @escaping (Error?) -> Void) {
        
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        
        let queryParameters = ["query": searchTerm,
                               "api_key": apiKey]
        
        components?.queryItems = queryParameters.map({URLQueryItem(name: $0.key, value: $0.value)})
        
        guard let requestURL = components?.url else {
            completion(NSError())
            return
        }
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            
            if let error = error {
                NSLog("Error searching for movie with search term \(searchTerm): \(error)")
                completion(error)
                return
            }
            
            guard let data = data else {
                NSLog("No data returned from data task")
                completion(NSError())
                return
            }
            
            do {
                let movieRepresentations = try JSONDecoder().decode(MovieRepresentations.self, from: data).results
                self.searchedMovies = movieRepresentations
                completion(nil)
            } catch {
                NSLog("Error decoding JSON data: \(error)")
                completion(error)
            }
        }.resume()
    }
    
    
    
    func put(movie: Movie, completion: @escaping CompletionHandler = {_ in}){
        let url = firebaseURL.appendingPathComponent(movie.identifier!.uuidString)
                            .appendingPathExtension("json")
        var requestUrl = URLRequest(url: url)
        requestUrl.httpMethod = "PUt"
        do{
            let jsonEncoder = JSONEncoder()
            requestUrl.httpBody = try jsonEncoder.encode(movie)
        }catch{
            NSLog("Error encoding movie data to JSON: \(error)")
            completion(nil)
        }
        
        URLSession.shared.dataTask(with: requestUrl) { (_, _, error) in
            if let error = error {
                NSLog("Error Sending movie to Firebase\(error)")
            }
            completion(nil)
        }.resume()
        
        
    }
    
    func fetchSingleMovie(identifier: UUID) -> Movie?{
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", identifier as NSUUID)
        return (try? moc.fetch(fetchRequest))?.first
    }
    
    
    func fetchAllMovies(completion: @escaping CompletionHandler = {_ in}){
        let url = firebaseURL.appendingPathExtension("json")
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            guard let data = data else {
                NSLog("Data not found on database")
                completion(NSError())
                return
            }
            
            if let error = error {
                NSLog("Error fetching data task: \(error)")
                completion(error)
                return
            }
            
            do{
                let jsonDecoder = JSONDecoder()
                let movieRepresentation = try jsonDecoder.decode([String : MovieRepresentation].self, from: data).values.map({$0})
                for movieRep in movieRepresentation{
                    if let movie = self.fetchSingleMovie(identifier: movieRep.identifier!){
                        self.update(movieRepresentation: movieRep, movie: movie)
                    }else{
                        let _ = Movie(movieRepresentation: movieRep)
                    }
                }
                self.saveToPersistence()
                completion(nil)
            }catch{
                NSLog("Error occured trying to retrieve data from dataBase \(error)")
                completion(error)
                return
            }
        }.resume()
    }

    
    var searchedMovies: [MovieRepresentation] = []
}

extension MovieController {
    
    func saveToPersistence(){
        do{
            try moc.save()
        }catch{
            NSLog("Error Saving Data to Manage object context: \(error)")
        }
    }
    
    func update(movieRepresentation: MovieRepresentation, movie: Movie){
        movie.title = movieRepresentation.title
        movie.identifier = movieRepresentation.identifier
        movie.hasWatched = movieRepresentation.hasWatched!
    }
    
}

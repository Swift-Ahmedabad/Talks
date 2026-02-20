
import Foundation

class TraditionalQueues {
    
    private let networkQueue = DispatchQueue(label: "com.queue,network")
    private let dataProcessingQueue = DispatchQueue(label: "com.queue.data.processing")
    private let saveQueue = DispatchQueue(label: "com.queue.data.save")
    
    func syncData() {
        fetchData { [weak self] result in
            switch result {
            case .success(let data):
                self?.process(data) { [weak self] processedResult in
                    switch processedResult {
                    case .success(let success):
                        self?.save(success) { saveResult in
                            print("All operations completed successfully!")
                        }
                    case .failure(let failure):
                        self?.handleError(failure)
                    }
                }
            case .failure(let error):
                self?.handleError(error)
            }
        }
    }
    
    private func fetchData(completion: @escaping (Result<Data, Error>) -> Void) {
        networkQueue.async { [weak self] in
            do {
                let data = try self?.fetchDataFromServer()
                guard let data else {
                    completion(.failure(NSError(domain: "FetchError", code: 1, userInfo: nil)))
                    return
                }
                completion(.success(data))
            } catch {
                completion(.failure(NSError(domain: "FetchError", code: 2, userInfo: nil)))
            }
        }
    }
    
    private func process(_ data: Data, completion: @escaping (Result<Data, Error>) -> Void) {
        dataProcessingQueue.async {
            let success = Bool.random()
            if success {
                let processedData = Data(data.reversed())
                completion(.success(processedData))
            } else {
                completion(.failure(NSError(domain: "ProcessError", code: 3, userInfo: nil)))
            }
        }
    }
    
    private func save(_ data: Data, completion: @escaping (Result<Void, Error>) -> Void) {
        saveQueue.async {
            let success = Bool.random()
            if success {
                print("Data saved: \(data)")
                completion(.success(()))
            } else {
                completion(.failure(NSError(domain: "SaveError", code: 4, userInfo: nil)))
            }
        }
    }
    
    private func handleError(_ error: Error) {
        print("Error occurred: \(error.localizedDescription)")
    }
    
    private func fetchDataFromServer() throws -> Data {
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts/1")!
        let data = try Data(contentsOf: url)
        return data
    }
}

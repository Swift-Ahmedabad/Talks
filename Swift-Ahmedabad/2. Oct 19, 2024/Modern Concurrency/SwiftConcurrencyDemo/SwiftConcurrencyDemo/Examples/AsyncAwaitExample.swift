
import Foundation

class AsyncAwaitExample {
    
    func syncData() async {
        do {
            let data = try fetchDataFromServer()
            let processedData = try await process(data)
            try await save(processedData)
            print("All operations completed successfully!")
        } catch {
            print("Error occurred: \(error.localizedDescription)")
        }
    }
    
    private func process(_ data: Data) async throws -> Data {
        let success = Bool.random()
        guard success else {
            throw NSError(domain: "ProcessError", code: 2, userInfo: nil)
        }
        return Data(data.reversed())
    }
    
    private func save(_ data: Data) async throws {
        let success = Bool.random()
        guard success else {
            throw NSError(domain: "SaveError", code: 3, userInfo: nil)
        }
        print("Data saved: \(data)")
    }
    
    private func fetchDataFromServer() throws -> Data {
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts/1")!
        let data = try Data(contentsOf: url)
        return data
    }
}

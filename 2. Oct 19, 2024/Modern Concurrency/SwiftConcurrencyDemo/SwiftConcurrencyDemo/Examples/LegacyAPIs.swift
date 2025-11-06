
import Foundation

final class LegacyAPIs: Sendable {
    
    func myOperation() {
        Task {
            do {
                try await operation()
            } catch {
                print("Error: \(error)")
            }
        }
    }
    
    func operation() async throws {
        print("Operation started")
        let result = try await getAPIResult()
        print("Operation completed with value: \(result)")
    }
    
    func getAPIResult() async throws -> Int {
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self else {
                continuation.resume(returning: -1)
                return
            }
            self.someLegacyAPI() { result in
                switch result {
                case .success(let success):
                    continuation.resume(returning: success)
                case .failure(let failure):
                    continuation.resume(throwing: failure)
                }
            }
        }
    }
    
    func someLegacyAPI(completion: @escaping (Result<Int, Error>) -> Void) {
        completion(.success(1))
    }
}

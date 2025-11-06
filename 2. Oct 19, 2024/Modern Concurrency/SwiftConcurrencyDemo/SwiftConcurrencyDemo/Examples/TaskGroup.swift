
import SwiftUI
@preconcurrency import Alamofire

actor TaskGroupExample {
    
    func loadMultiple() {
        Task {
            do {
                try await loadFromMultipleSources()
            } catch {
                print("Operation failed: \(error.localizedDescription)")
            }
        }
    }
    
    func loadUserProfile() {
        Task {
            async let profile = fetchUserProfile()
            async let posts = fetchUserPosts()
            
            let (userProfile, userPosts) = try await (profile, posts)
            print("Profile: \(userProfile), Posts: \(userPosts)")
        }
    }
    
    private func fetchUserProfile() async throws -> String {
        try await Task.sleep(for: .seconds(1))
        return "User data"
    }
    
    private func fetchUserPosts() async throws -> [String] {
        try await Task.sleep(for: .seconds(2))
        return ["Post 1", "Post 2"]
    }
    
    private func loadFromMultipleSources() async throws {
        let result: [String] = try await withThrowingTaskGroup(of: Data.self, returning: [String].self) { [weak self] group in
            
            for index in (1...5) {
                guard let self else { throw CancellationError() }
                let added = group.addTaskUnlessCancelled {
                    try Task.checkCancellation()
                    return try await self.fetchDataFromServer(from: "API \(index)")
                }
                guard added else { break }
            }
            
            var collectedResults: [String] = []
            for try await result in group {
                collectedResults.append(String(data: result, encoding: .utf8) ?? "Not found")
            }
            return collectedResults
        }
        print("Result: \(result)")
    }
    
    private func fetchDataFromServer(from source: String) async throws -> Data {
        return try await AF.request("https://httpbin.org/get").serializingData().value
    }
}

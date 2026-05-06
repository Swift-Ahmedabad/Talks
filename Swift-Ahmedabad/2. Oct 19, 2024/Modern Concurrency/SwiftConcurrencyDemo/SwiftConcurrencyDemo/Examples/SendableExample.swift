
import SwiftUI

class User {
    let id: Int
    let name: String
    
    init(id: Int = 0, name: String = "Not disclosed") {
        self.id = id
        self.name = name
    }
}

final class UserDataStore: Sendable {
    
    nonisolated(unsafe) private var user = User()
    
    func updateUserData() {
        user = User(name: "Nishchal")
    }
}

final class UserProfileViewModel: ObservableObject, Sendable {
    
    let userDataStore = UserDataStore()
    
    func updateUserData() {
        Task { [weak self] in
            self?.userDataStore.updateUserData()
        }
    }
}

struct SendableExample: View {
    
    @StateObject var userProfileViewModel = UserProfileViewModel()
    
    var body: some View {
        Button("Update User Data") {
            userProfileViewModel.updateUserData()
        }
    }
}

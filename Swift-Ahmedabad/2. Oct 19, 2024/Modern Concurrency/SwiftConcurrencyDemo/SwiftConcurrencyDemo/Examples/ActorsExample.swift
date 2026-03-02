
import SwiftUI

actor BankAccount {
    
    enum TransectionType {
        case deposit
        case withdrawal
    }
    
    let accountNumber: String
    private var balance: Double = 0.0
    private var runningTransection: Task<Void, Never>?
    
    var currentBalance: Double {
        get async {
            await runningTransection?.value
            return balance
        }
    }
    
    init(accountNumber: String) {
        self.accountNumber = accountNumber
    }
    
    func transection(type: TransectionType, amount: Double) {
        runningTransection = Task { [runningTransection] in
            await runningTransection?.value
            switch type {
            case .deposit:
                await deposit(amount)
            case .withdrawal:
                await withdraw(amount)
            }
        }
    }
    
    private func deposit(_ amount: Double) async {
        print("Start deposit of \(amount)")
        await donSomeWorkBeforeDeposit()
        balance += amount
        print("Deposit complete. New balance: \(balance)")
    }
    
    private func withdraw(_ amount: Double) async {
        print("Start withdrawal of \(amount)")
        await donSomeWorkBeforeWithdrawal()
        guard balance >= amount else {
            print("Insufficient funds!")
            return
        }
        balance -= amount
        print("Withdrawal complete. New balance: \(balance)")
        return
    }
    
    private func donSomeWorkBeforeDeposit() async {
        print("Do some deposit checks")
        try? await Task.sleep(for: .seconds(2))
        print("Deposit checks complete")
    }
    
    private func donSomeWorkBeforeWithdrawal() async {
        print("Do some withdrawal checks")
        try? await Task.sleep(for: .seconds(1))
        print("Withdrawal checks complete")
    }
    
    nonisolated func printAccountNumber() {
        print("Account number: \(accountNumber)")
    }
}

final class ViewModel: ObservableObject, Sendable {
    
    private let account = BankAccount(accountNumber: "123456")
    
    func run() {
        Task {
            await account.transection(type: .deposit, amount: 100)
        }
        account.printAccountNumber()
        Task {
            await account.transection(type: .withdrawal, amount: 50)
        }
    }
}

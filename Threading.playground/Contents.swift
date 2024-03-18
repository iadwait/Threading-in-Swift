import UIKit

// MARK: - Variable Declarations
let semaphore = DispatchSemaphore(value: 1)
var bankBalance = 10000

// MARK: - Enum
enum TransactionType {
    case ATM
    case NetBanking
}


print("Threading")

// MARK: - GCD
func testGCD() {
    print("-------GCD------")
    let queue = DispatchQueue(label: "ConcurrentQueue", attributes: .concurrent)
    queue.async {
        print("Task 1 Executed")
    }
    queue.asyncAfter(wallDeadline: .now() + 3, execute: {
        print("Task 2 Executed")
    })
    queue.async {
        print("Task 3 Executed")
    }
    
}

func testGCDWorkItem() {
    print("-------GCD Work Item------")
    let queue = DispatchQueue(label: "ConcurrentQueue", attributes: .concurrent)
    var workItem: DispatchWorkItem?
    workItem = DispatchWorkItem {
        print("Work Item Executing")
        for i in 0..<10 {
            if !(workItem?.isCancelled ?? false) {
                Thread.sleep(forTimeInterval: 1)
                print("i = \(i)")
            } else {
                print("Work Item Cancelled")
                break
            }
        }
    }
    
    workItem?.notify(queue: .main) {
        print("Notify - My Work Task Executed")
    }
    
    queue.async(execute: workItem!)
    queue.asyncAfter(deadline: .now() + 2) {
        workItem?.cancel()
    }
}

func testDispatchSemaphore() {
    print("------Dispatch Semaphore------")
    let queue = DispatchQueue(label: "ConcurrentQueue", attributes: .concurrent)
    queue.async {
        print("Processing ATM Transaction: Deduct 8000")
        deductBankBalance(amountToDeduct: 8000, type: .ATM)
    }
    
    queue.async {
        print("Processing NetBanking Transaction: Deduct 8000")
        deductBankBalance(amountToDeduct: 8000, type: .NetBanking)
    }
    
}

func deductBankBalance(amountToDeduct: Int, type: TransactionType) {
    semaphore.wait()
    if bankBalance > amountToDeduct {
        bankBalance = bankBalance - amountToDeduct
        print("Amount \(amountToDeduct) deducted from \(type), Update Bank Balance = \(bankBalance)")
    } else {
        print("\(type) Transaction cannot be deducted due to insufficient bank balance")
    }
    semaphore.signal()
}

// MARK: - Operation Queue

func testOperationQueue() {
    print("-------Operation Queue-------")
    // Create Block Operations
    let blockoperation1 = BlockOperation()
    blockoperation1.addExecutionBlock {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            print("Task 1 Executed")
        }
    }
    
    let blockoperation2 = BlockOperation()
    blockoperation1.addExecutionBlock {
        print("Task 2 Executed")
    }
    
    //blockoperation1.start()
    
    // Create Operation queue and give tasks
    let queue = OperationQueue()
    queue.isSuspended = false
    queue.addOperations([blockoperation1, blockoperation2], waitUntilFinished: false)
}

// MARK: - Testing

//testGCD()
//testGCDWorkItem()
//testDispatchSemaphore()
//testOperationQueue()



func getEmployeeDetails() {
    print("Started Fetching Employee Details")
    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
        print("Success Employee Details")
    }
}

func getOfficeList() {
    print("Started Fetching Office List Details")
    DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
        print("Success Office List Details")
    }
}

func makeParallelCalls() {
//    GCD
//    let queue = DispatchQueue(label: "DashboardQueue", attributes: .concurrent)
//    
//    queue.async {
//        getEmployeeDetails()
//    }
//    
//    queue.async {
//        getOfficeList()
//    }
    
//    Operation Queue
    
    
    let queue = OperationQueue()
    
    let blockOperation1 = BlockOperation {
        getEmployeeDetails()
    }
    
    let blockOperation2 = BlockOperation {
        getOfficeList()
    }
    
    let blockOperation3 = BlockOperation {
        //getOfficeList()
        print("Dummy API Call")
        URLSession.shared.dataTask(with: URLRequest(url: URL(string: "www.google.com")!)) { data, response, error in
            guard error == nil, let safeData = data else {
                print("Incorrect Api Endpoint")
                return
            }
            print("Safe Data = \(String(data: safeData, encoding: .utf8) ?? "")")
        }
    }
    
    blockOperation2.queuePriority = .veryHigh
    blockOperation1.queuePriority = .veryLow
    
    //queue.addOperations([blockOperation1, blockOperation2], waitUntilFinished: false)
    queue.addOperation(blockOperation1)
    //queue.isSuspended = true
    queue.addOperation(blockOperation2)
    //Thread.sleep(forTimeInterval: 9)
    //queue.isSuspended = false
    queue.addOperation(blockOperation3)
    
    var prevScreen = "Dashboard"
    var currentScreen = "Dashboard"
    
    if prevScreen != currentScreen {
        // Screen Changed
        queue.cancelAllOperations()
        prevScreen = currentScreen
        queue.addOperation {
            //print("Whatever Operation or api call")
        }
    } else {
        queue.addOperation {
            //print("Whatever Operation or api call")
        }
    }
    
    
}

makeParallelCalls()

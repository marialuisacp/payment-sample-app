import Foundation
import React

@available(iOS 15.0, *)
@objc(PaymentModule)
class PaymentModule: NSObject {
    let paymentHandler = PaymentHandler()
    @objc
    static func requiresMainQueueSetup() -> Bool {
        true
    }

    @objc
    func openPayment(_ total: String, resolver: @escaping RCTResponseSenderBlock) -> Void {
      print("Call payment method" + String(total))
      paymentHandler.startPayment(total: Double(total) ?? 100) { (success) in
          if success {
              print(success)
              resolver(["Success"])
          }
      }
    }
}


import UIKit
import PassKit

typealias PaymentCompletionHandler = (Bool) -> Void

class PaymentHandler: NSObject {

    var paymentController: PKPaymentAuthorizationController?
    var paymentSummaryItems = [PKPaymentSummaryItem]()
    var paymentStatus = PKPaymentAuthorizationStatus.failure
    var completionHandler: PaymentCompletionHandler!

    static let supportedNetworks: [PKPaymentNetwork] = [
        .amex,
        .discover,
        .masterCard,
        .visa
    ]

    class func applePayStatus() -> (canMakePayments: Bool, canSetupCards: Bool) {
        return (PKPaymentAuthorizationController.canMakePayments(),
                PKPaymentAuthorizationController.canMakePayments(usingNetworks: supportedNetworks))
    }
    
    func shippingMethodCalculator() -> [PKShippingMethod] {
        let today = Date()
        let calendar = Calendar.current
        
        let shippingStart = calendar.date(byAdding: .day, value: 3, to: today)!
        let shippingEnd = calendar.date(byAdding: .day, value: 5, to: today)!
        
        let startComponents = calendar.dateComponents([.calendar, .year, .month, .day], from: shippingStart)
        let endComponents = calendar.dateComponents([.calendar, .year, .month, .day], from: shippingEnd)
         
        let shippingDelivery = PKShippingMethod(label: "Delivery", amount: NSDecimalNumber(string: "0.00"))
        shippingDelivery.dateComponentsRange = PKDateComponentsRange(start: startComponents, end: endComponents)
        shippingDelivery.detail = "Ticket sent to you address"
        shippingDelivery.identifier = "DELIVERY"
        
        let shippingCollection = PKShippingMethod(label: "Collection", amount: NSDecimalNumber(string: "0.00"))
        shippingCollection.detail = "Collect ticket at festival"
        shippingCollection.identifier = "COLLECTION"
        
        return [shippingDelivery, shippingCollection]
    }
    
    func startPayment(total: Double, completion: @escaping PaymentCompletionHandler) {

        completionHandler = completion
        
        let tax = PKPaymentSummaryItem(label: "Tax", amount: NSDecimalNumber(string: "1.00"), type: .final)
        let total = PKPaymentSummaryItem(label: "Total", amount: NSDecimalNumber(string: String(total)), type: .final)
        paymentSummaryItems = [tax, total]
        
        let paymentRequest = PKPaymentRequest()
        paymentRequest.paymentSummaryItems = paymentSummaryItems
        paymentRequest.merchantIdentifier = Configuration.Merchant.identifier
        paymentRequest.merchantCapabilities = .capability3DS
        paymentRequest.countryCode = "BR"
        paymentRequest.currencyCode = "BRL"
        paymentRequest.supportedNetworks = PaymentHandler.supportedNetworks
        //paymentRequest.shippingType = .servicePickup
        //paymentRequest.shippingMethods = shippingMethodCalculator()
        //paymentRequest.requiredShippingContactFields = [.name, .postalAddress]
        #if !os(watchOS)
        paymentRequest.supportsCouponCode = true
        #endif
        
        paymentController = PKPaymentAuthorizationController(paymentRequest: paymentRequest)
        paymentController?.delegate = self
        paymentController?.present(completion: { (presented: Bool) in
            if presented {
                debugPrint("Presented payment controller")
            } else {
                debugPrint("Failed to present payment controller")
                self.completionHandler(false)
            }
        })
    }
}

extension PaymentHandler: PKPaymentAuthorizationControllerDelegate {

    func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        
        print(payment)
        var errors = [Error]()
        var status = PKPaymentAuthorizationStatus.success
        
        self.paymentStatus = status
        completion(PKPaymentAuthorizationResult(status: status, errors: errors))
    }
    
    func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        controller.dismiss {
            DispatchQueue.main.async {
                if self.paymentStatus == .success {
                    self.completionHandler!(true)
                } else {
                    self.completionHandler!(false)
                }
            }
        }
    }
    
    #if !os(watchOS)

    func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController,
                                        didChangeCouponCode couponCode: String,
                                        handler completion: @escaping (PKPaymentRequestCouponCodeUpdate) -> Void) {

        func applyDiscount(items: [PKPaymentSummaryItem]) -> [PKPaymentSummaryItem] {
            let tickets = items.first!
            let couponDiscountItem = PKPaymentSummaryItem(label: "Coupon Code Applied", amount: NSDecimalNumber(string: "-2.00"))
            let updatedTax = PKPaymentSummaryItem(label: "Tax", amount: NSDecimalNumber(string: "0.80"), type: .final)
            let updatedTotal = PKPaymentSummaryItem(label: "Total", amount: NSDecimalNumber(string: "8.80"), type: .final)
            let discountedItems = [tickets, couponDiscountItem, updatedTax, updatedTotal]
            return discountedItems
        }
        
        if couponCode.uppercased() == "FESTIVAL" {
            let couponCodeSummaryItems = applyDiscount(items: paymentSummaryItems)
            completion(PKPaymentRequestCouponCodeUpdate(paymentSummaryItems: applyDiscount(items: couponCodeSummaryItems)))
            return
        } else if couponCode.isEmpty {
            completion(PKPaymentRequestCouponCodeUpdate(paymentSummaryItems: paymentSummaryItems))
            return
        } else {
            let couponError = PKPaymentRequest.paymentCouponCodeInvalidError(localizedDescription: "Coupon code is not valid.")
            completion(PKPaymentRequestCouponCodeUpdate(errors: [couponError], paymentSummaryItems: paymentSummaryItems, shippingMethods: shippingMethodCalculator()))
            return
        }
    }
    #endif
}


//
//  ViewController.swift
//  PaymentModel
//
//  Created by User on 9/16/19.
//  Copyright © 2019 NTIC. All rights reserved.
//

import UIKit
import Stripe

class ViewController: UIViewController, PayPalPaymentDelegate, STPAddCardViewControllerDelegate {
    
    @IBOutlet weak var amauntTextField: UITextField!
    
    let paymentCardTextField = STPPaymentCardTextField()
    
    var environment:String = PayPalEnvironmentNoNetwork {
        willSet(newEnvironment) {
            if (newEnvironment != environment) {
                PayPalMobile.preconnect(withEnvironment: newEnvironment)
            }
        }
    }
    var payPalConfig = PayPalConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up payPalConfig
        payPalConfig.acceptCreditCards = false
        payPalConfig.merchantName =  "NTIC" // your company name here.
        payPalConfig.merchantPrivacyPolicyURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/privacy-full")
        payPalConfig.merchantUserAgreementURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/useragreement-full")
        //This is the language in which your paypal sdk will be shown to users.
        payPalConfig.languageOrLocale = Locale.preferredLanguages[0]
        //Here you can set the shipping address. You can choose either the address associated with PayPal account or different address. We’ll use .both here.
        //        payPalConfig.payPalShippingAddressOption = .both;
        
        let btn = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 30))
        view.addSubview(btn)
        btn.addTarget(nil, action: #selector(done), for: .touchUpInside)
        btn.backgroundColor = UIColor.red
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        PayPalMobile.preconnect(withEnvironment: environment)
    }
    
    @IBAction func paymentBtnPayPal(_ sender: Any) {
        //These are the items choosen by user, for example
        let item1 = PayPalItem(name: "Donation For Ntic", withQuantity: 1, withPrice: NSDecimalNumber(string: amauntTextField.text), withCurrency: "USD", withSku: "003")
        //        let item2 = PayPalItem(name: "Free rainbow patch", withQuantity: 1, withPrice: NSDecimalNumber(string: "0.00"), withCurrency: "USD", withSku: "Hip-00066")
        //        let item3 = PayPalItem(name: "Long-sleeve plaid shirt (mustache not included)", withQuantity: 1, withPrice: NSDecimalNumber(string: "37.99"), withCurrency: "USD", withSku: "Hip-00291")
        let items = [item1]//[item1, item2, item3]
        let subtotal = PayPalItem.totalPrice(forItems: items) //This is the total price of all the items
        // Optional: include payment details
        //        let shipping = NSDecimalNumber(string: "0")
        //        let tax = NSDecimalNumber(string: "2.50")
        let paymentDetails = PayPalPaymentDetails(subtotal: subtotal, withShipping: nil, withTax: nil)
        let total = subtotal //.adding(shipping).adding(tax) //This is the total price including shipping and tax
        let payment = PayPalPayment(amount: total, currencyCode: "USD", shortDescription: "Donation For Ntic", intent: .sale)
        payment.items = items
        payment.paymentDetails = paymentDetails
        if (payment.processable) {
            let paymentViewController = PayPalPaymentViewController(payment: payment, configuration: payPalConfig, delegate: self)
            present(paymentViewController!, animated: true, completion: nil)
        }
        else {
            // This particular payment will always be processable. If, for
            // example, the amount was negative or the shortDescription was
            // empty, this payment wouldn’t be processable, and you’d want
            // to handle that here.
            print("Payment not processalbe: (payment)")
        }
    }
    
    // PayPalPaymentDelegate
    func payPalPaymentDidCancel(_ paymentViewController: PayPalPaymentViewController) {
        print("PayPal Payment Cancelled")
        paymentViewController.dismiss(animated: true, completion: nil)
    }
    func payPalPaymentViewController(_ paymentViewController: PayPalPaymentViewController, didComplete completedPayment: PayPalPayment) {
        print("PayPal Payment Success !")
        paymentViewController.dismiss(animated: true, completion: { () -> Void in
            // send completed confirmaion to your server
            print("Here is your proof of payment:nn(completedPayment.confirmation)nnSend this to your server for confirmation and fulfillment.")
        })
    }
    
    
    // Stripe
    
    @IBAction func goToStripe() {
        // Setup add card view controller
        let addCardViewController = STPAddCardViewController()
        addCardViewController.delegate = self
        
        // Present add card view controller
        let navigationController = UINavigationController(rootViewController: addCardViewController)
        present(navigationController, animated: true)
    }
    
    @objc func done() {
        // Setup add card view controller
        let addCardViewController = STPAddCardViewController()
        addCardViewController.delegate = self
        
        // Present add card view controller
        let navigationController = UINavigationController(rootViewController: addCardViewController)
        present(navigationController, animated: true)
    }
    
    // MARK: STPAddCardViewControllerDelegate
     
      func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreatePaymentMethod paymentMethod: STPPaymentMethod, completion: @escaping STPErrorBlock) {
                 print(paymentMethod)
                 //        submitPaymentMethodToBackend(paymentMethod, completion: { (error: Error?) in
                 //            if let error = error {
                 //                // Show error in add card view controller
                 //                completion(error)
                 //            }
                 //            else {
                 //                // Notify add card view controller that PaymentMethod creation was handled successfully
                 //                completion(nil)
                 //
                 //                // Dismiss add card view controller
                 //                dismiss(animated: true)
                 //            }
                 //        })
             }
        
   
    
    func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
             // Dismiss add card view controller
             dismiss(animated: true)
         }
}


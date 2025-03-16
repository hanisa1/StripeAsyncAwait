//
//  ViewController.swift
//  StripeAsyncAwait
//
//  Created by Hanisa Hilole on 16/3/2025.
//

import UIKit
import StripePaymentSheet

class ViewController: UIViewController {
    
    var paymentSheet: PaymentSheet?
    let backendCheckoutUrl = URL(string: "https://api.stripe.com")
    
    var checkoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Checkout", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        fetchInfoForPaymentSheet()
        
        checkoutButton.addTarget(self, action: #selector(didTapCheckoutButton), for: .touchUpInside)
        
        
        
        
        
    }
    
    @objc private func didTapCheckoutButton() {
        // Start the checkout process
        print("Button pressed")
         paymentSheet?.present(from: self) { paymentResult in
           // Handle the payment result
           switch paymentResult {
           case .completed:
             print("Your order is confirmed")
           case .canceled:
             print("Canceled!")
           case .failed(let error):
             print("Payment failed: \(error)")
           }
         }
    }
    
    private func fetchInfoForPaymentSheet() {
        
        

        // Fetch the PaymentIntent client secret, Ephemeral Key secret, Customer ID, and publishable key
        
        guard let url = backendCheckoutUrl else {
            print("Invalid URL")
            return
        }
        
        var configuration = PaymentSheet.Configuration()
        
        configuration.returnURL = "your-app://stripe-redirect"
        
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let task = URLSession.shared.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
          guard let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                let customerId = json["customer"] as? String,
                let customerEphemeralKeySecret = json["ephemeralKey"] as? String,
                let paymentIntentClientSecret = json["paymentIntent"] as? String,
                let publishableKey = json["publishableKey"] as? String,
                let self = self else {
            // Handle error
            return
          }

          STPAPIClient.shared.publishableKey = publishableKey
          // Create a PaymentSheet instance
          var configuration = PaymentSheet.Configuration()
          configuration.merchantDisplayName = "Example, Inc."
          configuration.customer = .init(id: customerId, ephemeralKeySecret: customerEphemeralKeySecret)
          // Set `allowsDelayedPaymentMethods` to true if your business handles
          // delayed notification payment methods like US bank accounts.
          configuration.allowsDelayedPaymentMethods = true
          self.paymentSheet = PaymentSheet(paymentIntentClientSecret: paymentIntentClientSecret, configuration: configuration)

          DispatchQueue.main.async {
            self.checkoutButton.isEnabled = true
          }
        })
        task.resume()
        
    }
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        
        //constraints
        checkoutButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(checkoutButton)
        
        NSLayoutConstraint.activate([
            checkoutButton.heightAnchor.constraint(equalToConstant: 50),
            checkoutButton.widthAnchor.constraint(equalToConstant: 150),
            checkoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            checkoutButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }


}


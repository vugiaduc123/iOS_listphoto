//
//  WelcomeViewController.swift
//  ListPhoto
//
//  Created by Vũ Đức on 16/12/24.
//

import UIKit
import Network
class WelcomeViewController: UIViewController {
    let paddingItem:CGFloat = 20
    let welcomeLabel = UILabel()
    let backgroundImage = UIImageView()
    let destinationBtn = UIButton()
    let monitor = NWPathMonitor()

    var connectNetwork: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        addView()
        setUpView()
    }
}

// MARK: Setup View - Constraint
extension WelcomeViewController {
    func addView() {
        self.view.backgroundColor = .white
        self.view.addSubview(backgroundImage)
        self.view.addSubview(welcomeLabel)
        self.view.addSubview(destinationBtn)
    }

    func setUpView() {
        configBackground()
        configureLb()
        configButton()
    }

    func configureLb() {
        welcomeLabel.text = "Welcome to Picsum"
        welcomeLabel.textColor = .black
        welcomeLabel.textAlignment = .left
        welcomeLabel.font = UIFont.boldSystemFont(ofSize: 25)
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            self.welcomeLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 40),
            self.welcomeLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: paddingItem),
            self.welcomeLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -paddingItem),
        ])
    }

    func configBackground() {
        backgroundImage.image = UIImage(named: "bg_piscum")
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundImage.widthAnchor.constraint(equalToConstant: self.view.bounds.width).isActive = true
        self.backgroundImage.heightAnchor.constraint(equalToConstant: self.view.bounds.height).isActive = true
    }

    func configButton() {
        destinationBtn.setTitle("Đi tới", for: .normal)
        destinationBtn.backgroundColor = .black
        destinationBtn.layer.cornerRadius = 15
        destinationBtn.clipsToBounds = true
        destinationBtn.addTarget(self, action: #selector(destinationPhoto), for: .touchUpInside)
        destinationBtn.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            self.destinationBtn.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -25),
            self.destinationBtn.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: paddingItem),
            self.destinationBtn.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -paddingItem),
            self.destinationBtn.heightAnchor.constraint(equalToConstant: 55)
        ])
    }
}

// MARK: Function
extension WelcomeViewController {
    @objc func destinationPhoto(sender: UIButton){
        if let navi = self.navigationController {
            PhotoNavigator(navigationController: navi).navigateToEventScreen()
            return
        }
    }

    func checkNetwork() {
        NetworkMonitor.shared.startMonitoring()
        DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
            guard let strongSelf = self else { return }
            if NetworkMonitor.shared.isConnected {
                print("Device on wifi: \(NetworkMonitor.shared.connectionType)")
                strongSelf.connectNetwork = true
            } else {
                print("Device not connected wifi.")
                strongSelf.connectNetwork = false
                strongSelf.showAlert(title: "Thông báo", message: "Thiết bị mất mạng.")
            }
        }
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil)) // Nút OK
        self.present(alert, animated: true, completion: nil)
    }
}

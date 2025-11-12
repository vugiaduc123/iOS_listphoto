//
//  SSL.swift
//  ListPhoto
//
//  Created by Đức Vũ on 11/11/25.
//

import Foundation
import Combine
import Security

final class PinningSessionDelegate: NSObject, URLSessionDelegate {
    private let pinnedCertificateName = "server"

    func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {

        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust,
              let serverCert = SecTrustGetCertificateAtIndex(serverTrust, 0) else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        guard let localCertPath = Bundle.main.path(forResource: pinnedCertificateName, ofType: "cer"),
              let localCertData = try? Data(contentsOf: URL(fileURLWithPath: localCertPath)),
              let localCert = SecCertificateCreateWithData(nil, localCertData as CFData) else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        let serverCertData = SecCertificateCopyData(serverCert) as Data

        if serverCertData == localCertData {
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }

//        if let serverKey = SecTrustCopyKey(serverTrust),
//           let localKey = SecCertificateCopyKey(localCert),
//           serverKey == localKey {
//            completionHandler(.useCredential, URLCredential(trust: serverTrust))
//        } else {
//            completionHandler(.cancelAuthenticationChallenge, nil)
//        }
    }
}

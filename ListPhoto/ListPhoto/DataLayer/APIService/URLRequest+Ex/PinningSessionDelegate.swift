//
//  PinningSessionDelegate.swift
//  ListPhoto
//
//  Created by Đức Vũ on 30/10/25.
//

import Foundation
import Combine
import Security

final class PinningSessionDelegate: NSObject, URLSessionDelegate {
    // Tên file chứng chỉ bạn nhúng vào app (ví dụ: server.cer)
    private let pinnedCertificateName = "server"

    func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {

        // 1️⃣ Chỉ xử lý khi challenge liên quan đến server trust
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust,
              let serverCert = SecTrustGetCertificateAtIndex(serverTrust, 0) else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // 2️⃣ Tải chứng chỉ đã pin từ bundle
        guard let localCertPath = Bundle.main.path(forResource: pinnedCertificateName, ofType: "cer"),
              let localCertData = try? Data(contentsOf: URL(fileURLWithPath: localCertPath)),
              let localCert = SecCertificateCreateWithData(nil, localCertData as CFData) else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // 3️⃣ So sánh dữ liệu nhị phân của chứng chỉ server và local
        let serverCertData = SecCertificateCopyData(serverCert) as Data

        if serverCertData == localCertData {
            // ✅ Khớp —> cấp quyền
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        } else {
            // ❌ Không khớp —> từ chối
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}

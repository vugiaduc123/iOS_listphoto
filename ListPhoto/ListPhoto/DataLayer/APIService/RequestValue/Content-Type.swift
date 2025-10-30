//
//  Content-Type.swift
//  ListPhoto
//
//  Created by Đức Vũ on 10/5/25.
//

public enum ConTentType: String {
    case json = "application/json" // JSON
    case jsonImage = "image/png" // JSON
    case formUrlencoded = "application/x-www-form-urlencoded" // Gửi như form truyền thống (key=value&...)
    case formData = "multipart/form-data" // Gửi file upload, ảnh, dữ liệu phức tạp
    case plainText = "text/plain" // Gửi text thường
}

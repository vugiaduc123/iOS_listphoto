//
//  HeaderField.swift
//  ListPhoto
//
//  Created by Đức Vũ on 10/5/25.
//

public enum HeaderField: String {
    case contentType = "Content-Type" //     Kiểu dữ liệu được gửi trong httpBody VD: "application/json", "multipart/form-data"
    case accept = "Accept" //     Yêu cầu kiểu dữ liệu mà client muốn nhận về VD: "application/json", "image/png"
    case authorization = "Authorization" // Dùng để gửi token hoặc credential xác thực
    case UserAgent = "User-Agent" // Thông tin về app hoặc trình duyệt gửi request VD: "iOSApp/1.0"
    case acceptEncoding = "Accept-Encoding" // Cho phép server nén dữ liệu (gzip, deflate...) VD: "gzip, deflate"
    case cacheControl = "Cache-Control" //     Điều khiển việc cache của request VD: "no-cache", "max-age=3600"
    case host = "Host" // Tên miền server (đôi khi dùng để route đa host)
    case contentLength = "Content-Length" // Độ dài dữ liệu được gửi (thường auto set bởi hệ thống)
    case connection = "Connection" // Điều khiển việc giữ kết nối VD: "keep-alive" hoặc "close"
    case referer = "Referer" // URL của trang trước đó gọi request (dùng cho tracking, bảo mật...)
}

# Bus Tracking System

**Bus Tracking System** là dự án hệ thống web theo dõi xe buýt công cộng theo thời gian thực. Hệ thống hướng tới việc giúp hành khách tra cứu tuyến, trạm và thời gian xe dự kiến đến; đồng thời hỗ trợ tài xế thực hiện chuyến và bộ phận điều hành quản lý hoạt động vận tải.

> **Trạng thái dự án:** Đang thiết kế và chuẩn bị triển khai. Các chức năng, công nghệ và cấu trúc bên dưới là **phạm vi/kiến trúc dự kiến theo tài liệu đặc tả**, chưa phải xác nhận rằng hệ thống đã được xây dựng hoặc vận hành.

## Tính năng dự kiến

| Nhóm người dùng | Chức năng chính |
| --- | --- |
| **Khách chưa đăng nhập** | Tìm kiếm tuyến và trạm; xem bản đồ, lịch chạy, vị trí xe công khai, ETA và cảnh báo dịch vụ. |
| **Hành khách (Passenger)** | Các chức năng công khai; đăng nhập Google, quản lý hồ sơ, lưu tuyến/trạm yêu thích và đăng ký thông báo. |
| **Tài xế (Driver)** | Xem chuyến được phân công, cập nhật trạng thái chuyến, gửi vị trí GPS và báo cáo sự cố. |
| **Quản trị/Điều phối (Admin/Dispatcher)** | Quản lý tuyến, trạm, lịch chạy, phương tiện và tài xế; phân công chuyến, giám sát đội xe, phát hành cảnh báo và tra cứu báo cáo/nhật ký thao tác. |

Hệ thống dự kiến sử dụng **SignalR** để cập nhật vị trí xe và trạng thái chuyến mà không cần tải lại trang. Vị trí sẽ được phân biệt giữa **đang cập nhật**, **dữ liệu cũ (stale)** và **mất kết nối (offline)**.

## Công nghệ và kiến trúc

| Thành phần | Công nghệ dự kiến |
| --- | --- |
| Frontend | React 19, TypeScript, Vite, React Router, TanStack Query |
| Backend | ASP.NET Core Web API (.NET 10) |
| Cơ sở dữ liệu | MySQL 8.4, Entity Framework Core 10 (Code First) |
| Thời gian thực | ASP.NET Core SignalR |
| Xác thực và phân quyền | Google OAuth 2.0/OpenID Connect, phiên đăng nhập bằng cookie, RBAC |
| Bản đồ | Leaflet hoặc MapLibre (**chưa chốt**) |
| Môi trường phát triển | Docker Compose cho MySQL; backend và frontend chạy riêng |

Kiến trúc được đề xuất là **modular monolith**: React giao tiếp với ASP.NET Core qua REST API và SignalR; backend quản lý nghiệp vụ và lưu trữ dữ liệu trong MySQL.

```text
             React Web App
                   |
             REST / SignalR
                   |
          ASP.NET Core Web API
           (Modular Monolith)
              /         \
      MySQL + EF Core   Google OIDC
```

Luồng Google Sign-In được xử lý tại **backend**. Frontend sử dụng phiên đăng nhập ứng dụng; quyền **Driver** và **Admin** phải được cấp nội bộ, không tự động có được khi đăng nhập Google.

## Thiết lập và chạy dự án

**Hướng triển khai local đã thống nhất:** sử dụng Docker Compose để chạy MySQL; khởi động backend ASP.NET Core và frontend React **riêng biệt**.

Các bước dự kiến:

1. Cài đặt .NET SDK 10, Node.js tương thích với bộ công cụ frontend và Docker Compose.
2. Khởi động MySQL bằng cấu hình Docker Compose của dự án.
3. Cấu hình kết nối cơ sở dữ liệu và Google OIDC cho backend; chạy migration khi đã có mã nguồn.
4. Khởi động backend, sau đó khởi động frontend.

**Chưa xác nhận:** đường dẫn source thực tế, tên file cấu hình, trình quản lý gói frontend, các lệnh chạy, cổng truy cập và Google redirect URI. Hướng dẫn với câu lệnh chính xác sẽ được bổ sung sau khi tạo project và cấu hình môi trường.

> **Bảo mật:** Không commit connection string chứa mật khẩu, Google Client Secret hoặc các thông tin nhạy cảm vào repository.

## Phạm vi phiên bản đầu tiên (MVP)

MVP tập trung vào **mạng lưới tuyến/trạm, lịch chạy, phân công và vận hành chuyến, theo dõi GPS, ETA, cảnh báo và quản trị**. **Bán vé, đặt chỗ, thanh toán và tối ưu tuyến tự động** chưa thuộc phạm vi lõi.

Lộ trình phát triển dự kiến: **Nền tảng & xác thực → Mạng lưới tuyến/trạm → Vận hành chuyến → Theo dõi thời gian thực → ETA & cảnh báo → Kiểm thử và hoàn thiện**.

## Tài liệu

Tài liệu nền tảng: **Bus Tracking System Specification — phiên bản 1.0 (21/09/2026)**. Vị trí lưu tài liệu trong repository **bus-tracking-system/BTS_SPECIFICATION.pdf**.

---

**Ghi chú:** README sẽ được cập nhật cùng tiến độ triển khai; các tính năng nêu trên là yêu cầu dự kiến, không phải danh sách tính năng đã hoàn thành.

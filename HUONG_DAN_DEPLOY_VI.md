# NEXORA CIP — ĐỌC FILE NÀY TRƯỚC KHI DEPLOY

## Cấu trúc bản bàn giao

GitHub lưu source. Render chạy ứng dụng Docker gồm FastAPI, React đã build, AI và Jira. Vercel là địa chỉ truy cập và reverse proxy toàn bộ ứng dụng sang Render. Cách này giữ một nguồn truy cập, mật khẩu áp dụng cho cả giao diện lẫn API, không đưa khóa vào frontend. Vercel không chạy Python/Docker; không build React lần thứ hai.

Chưa có website online được xác minh. Code đã kiểm thử local; bản Docker cần được Render build và kiểm tra log khi bạn deploy.

## 1. Giải nén và đưa lên GitHub

Giải nén ZIP. Mở repository https://github.com/quynhthunguyen21-png/nexoracip.
Chọn Add file → Upload files. Kéo CÁC THƯ MỤC VÀ FILE BÊN TRONG thư mục vừa giải nén lên; không upload file ZIP hoặc bọc thêm một thư mục ngoài.
Ở trang gốc repository phải thấy Dockerfile, vercel.json, backend/, frontend/ và data/.
Nếu trình duyệt không hiển thị file bắt đầu bằng dấu chấm trên Mac, nhấn Cmd + Shift + . để thấy .gitignore và .dockerignore. Upload hai file này.
Chọn Commit changes. Không đưa .env, token hoặc mật khẩu lên GitHub. Bản ZIP bàn giao không có các bí mật này.

Nếu GitHub báo quá nhiều file (giới hạn upload qua web), chia thành vài lượt theo backend/, frontend/ và các file gốc, hoặc dùng GitHub Desktop để Add local repository và Publish/Push vào repository của bạn. Nếu repository đã có code khác, không xóa đè hàng loạt; kiểm tra trước khi upload.

## 2. Deploy Render trước

Trong Render: New → Web Service → chọn repository nexoracip.
Đặt Name: nexoracip-api. Root Directory: để trống. Language/Runtime: Docker.
Dockerfile Path: ./Dockerfile. Docker Context: . (gốc repository).
Health Check Path: /health. Có thể chọn Free cho bản trình diễn AI và ĐỌC Jira.
Không nhập build/start command kiểu npm dev hay uvicorn riêng: Dockerfile đã có lệnh chạy.

Trong Environment, thêm:

APP_ENV=demo
AI_MODE=gemini
GEMINI_API_KEY=<khóa Gemini của bạn>
GEMINI_MODEL=<giá trị GEMINI_MODEL đang có trong .env local>
AI_DATA_SHARING_APPROVED=yes
DEMO_USERNAME=cip
DEMO_PASSWORD=<tự đặt mật khẩu ngẫu nhiên từ 16 ký tự>
JIRA_EMAIL=<email đăng nhập Jira>
JIRA_API_TOKEN=<token Jira riêng>
JIRA_TOKEN_MODE=scoped
JIRA_CLOUD_ID=<giá trị đã có trong .env local>
JIRA_ALLOWED_PROJECTS=KAN
JIRA_WRITE_ENABLED=no

Không điền nguyên dấu <...>. Lấy các giá trị riêng từ file .env local của bạn; không upload file đó hoặc gửi key vào chat. Chỉ gửi dữ liệu được phép tới AI. Không cần DATABASE_URL cho bản demo này.

Bấm Deploy Web Service. Chờ Live. Lần đầu có thể mất vài phút.
Mở URL Render được cấp, ví dụ https://nexoracip-api-xxxx.onrender.com.
Hộp đăng nhập xuất hiện: nhập cip và mật khẩu DEMO_PASSWORD vừa đặt.
Trang /health phải trả {"status":"ok"}. Không có tên miền cố định nào được hứa trước; dùng URL Render thực tế của bạn.

Nếu chưa đặt DEMO_PUBLIC_URL, ứng dụng tự dùng RENDER_EXTERNAL_URL do Render cấp cho lần kiểm tra đầu tiên.

## 3. Sửa đích proxy của Vercel

Trên GitHub mở vercel.json → Edit. Thay CHI_DIA_CHI_RENDER bằng hostname Render vừa được cấp.
Ví dụ dòng destination sau khi sửa:
"destination": "https://nexoracip-api-xxxx.onrender.com/:path*"
Giữ nguyên phần :path*. Không trỏ về localhost, không thêm /api vào đích này.
Commit thay đổi. Có thể sửa file ở máy trước khi upload nếu bạn đã biết URL Render.

## 4. Deploy Vercel

Trong Vercel: Add New → Project → Import repository nexoracip.
Project Name: nexoracip (nếu còn trống).
Framework Preset: Other. Root Directory: gốc repository, KHÔNG chọn frontend.
Không ghi đè Build Command/Output Directory: vercel.json đã cấu hình không build và dùng vercel-public.
Không đưa Gemini/Jira key vào Vercel; chúng nằm ở Render.
Bấm Deploy. Mở domain Vercel được cấp, ví dụ https://nexoracip.vercel.app.

## 5. Khớp origin để AI và Jira hoạt động

Quay Render → service → Environment. Thêm/sửa:
DEMO_PUBLIC_URL=https://<domain-vercel-thật-của-bạn>
Không có dấu / ở cuối và không thêm #overview. Save, rebuild/redeploy nếu Render yêu cầu.
Luôn dùng domain production này khi trình diễn; domain preview ngẫu nhiên của từng commit không nằm trong allowlist.

Tải lại Vercel. Đăng nhập nếu được hỏi. Mở Trợ lý AI, gửi một câu chào. Sau đó Hồ sơ doanh nghiệp → Kiểm tra kết nối Jira, hoặc Theo dõi tuân thủ → Rà soát Jira → đọc KAN-10.
Nếu báo 403, kiểm tra DEMO_PUBLIC_URL đã khớp domain Vercel chưa. Nếu AI báo model/quota, kiểm tra các biến riêng ở Render và quota Gemini. Vercel chuyển tiếp yêu cầu; Render Free có thể khởi động chậm sau khi ngủ, hãy mở trước buổi quay.

## 6. Nếu cần GỬI ticket Jira thật

Cấu hình Free bên trên CHỈ ĐỌC Jira, vẫn dùng được AI, kế hoạch, nhiệm vụ nội bộ và minh chứng trên web. Không bật gửi thật vào ổ tạm: khi Render restart có thể mất nhật ký chống tạo trùng.
Để gửi thật: chọn gói web hỗ trợ persistent disk, xem và đồng ý chi phí trước; gắn disk mount path /data, rồi thêm:
DEMO_STORAGE_DIR=/data
DEMO_STORAGE_PERSISTENT=yes
JIRA_WRITE_ENABLED=yes
Chỉ bật sau khi disk đã được gắn thật. Redeploy. Chọn tài khoản Jira nhận việc và xác nhận từng lần gửi trên web. Không tự điền biến giả để vượt kiểm tra volume.
Chưa có POST tạo Jira thật nào được thực hiện để kiểm thử trong bản bàn giao; kiểm tra từng receipt mã KAN trước khi tuyên bố thành công.

## Dữ liệu và mật khẩu

Dữ liệu nhiệm vụ/chat/tệp trên localhost không tự chuyển sang domain mới. Bản mới có hồ sơ/danh mục và các nút tạo kế hoạch sẵn; không xóa dữ liệu local. Mỗi trình duyệt vẫn có dữ liệu nghiệp vụ riêng, chưa có đồng bộ nhiều người.
Mật khẩu dùng chung là lớp bảo vệ cho demo, không phải tài khoản/phân quyền doanh nghiệp. Chia sẻ mật khẩu riêng cho mentor; dùng HTTPS. HTTP Basic có thể được trình duyệt ghi nhớ: đóng cửa sổ riêng tư sau demo.

Tài liệu nền tảng: https://render.com/docs/web-services ; https://render.com/docs/free ; https://render.com/docs/disks ; https://vercel.com/docs/rewrites .

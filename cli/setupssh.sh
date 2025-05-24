#!/bin/bash

# 1. Kiểm tra SSH key
KEY="$HOME/.ssh/id_rsa.pub"
if [ ! -f "$KEY" ]; then
    echo "🔐 Chưa có SSH key, đang tạo mới..."
    ssh-keygen -t rsa -b 4096 -f "${KEY%.*}" -N ""
else
    echo "✅ SSH key đã tồn tại tại $KEY"
fi

# 2. Nhập đối tượng remote (user@host hoặc alias trong ~/.ssh/config)
read -p "🌐 Nhập địa chỉ remote (user@host hoặc alias trong ~/.ssh/config): " TARGET

# 3. Nội dung public key local
PUB_KEY=$(<"$KEY")

# 4. Kiểm tra và chỉ thêm nếu chưa tồn tại
echo "📤 Đang kiểm tra và gửi SSH key đến $TARGET..."
ssh "$TARGET" "
  mkdir -p ~/.ssh && chmod 700 ~/.ssh
  touch ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys
  grep -qxF '$PUB_KEY' ~/.ssh/authorized_keys || echo '$PUB_KEY' >> ~/.ssh/authorized_keys
"

# 5. Kiểm tra kết nối không cần mật khẩu
echo "🧪 Kiểm tra kết nối không cần mật khẩu..."
ssh -o PasswordAuthentication=no "$TARGET" "echo '🎉 Thiết lập SSH không mật khẩu thành công!'"


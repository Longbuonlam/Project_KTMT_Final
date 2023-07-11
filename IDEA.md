1. Ý tưởng bài toán
Để làm một đối tượng di chuyển thì chúng ta sẽ xóa đối tượng ở vị trí cũ và
vẽ đối tượng ở vị trí mới. Để xóa đối tượng chúng ta chỉ cần vẽ đối tượng đó
với màu là màu nền.
2. Phân tích cách thực hiện
 Khởi tạo 3 tập lệnh bó macro gồm: delay, LessOrEqual và DrawCirle_withColor (chức năng các tập lệnh bó macro sẽ được phân tích rõ ở các phần liên quan).
-  Hàm circleStore dùng để tạo mảng dữ liệu và lưu trữ tọa độ các điểm trên đường tròn.
-  Hàm Keyboard dùng để đọc dữ liệu người dùng nhập vào từ bàn phím. Đầu tiên, dùng hàm Position để kiểm tra xem đã có ký tự nào được nhập vào hay chưa? Nếu chưa nhập thì cho phép người dùng nhập vào từ bàn phím. Nếu đã nhập thì nhảy xuống hàm Position rồi lần lượt vào các hàm RightEdge, LeftEdge, TopEdge và BottomEdge để kiểm tra xem đường tròn đã chạm các mép màn hình hay chưa?
-  Nếu các điều kiện trên không thỏa mãn nghĩa là đường tròn chưa chạm mép nào thì nhảy xuống hàm draw, đổi màu đường tròn hiện tại sang màu nền, cập nhật vị trí mới và đổi màu đường tròn sang màu đỏ.
-  Hàm drawCircle dùng để vẽ đường tròn, ta dùng hàm hàm drawCirclePoint để vẽ các điểm ảnh tạo nên một đường tròn.

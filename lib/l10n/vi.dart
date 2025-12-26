class Vi {
  static const Map<String, String> _s = {
    'app_title': 'Khai thuế (DPFO mẫu B) – Xuất XML',
    'clients': 'Khách hàng',
    'add_client': 'Thêm khách hàng',
    'edit_client': 'Sửa khách hàng',
    'delete': 'Xoá',
    'save': 'Lưu',
    'cancel': 'Hủy',
    'next': 'Tiếp tục',
    'create_return': 'Tạo tờ khai',
    'export_xml': 'Xuất XML',
    'scan_ocr': 'Quét (OCR)',
    'client_card': 'Thông tin cá nhân',
    'tax_inputs': 'Dữ liệu tính thuế',
    'result': 'Kết quả',
    'warning_check': 'Vui lòng kiểm tra lại dữ liệu trước khi xuất XML.',
    // Client fields
    'first_name': 'Tên',
    'last_name': 'Họ',
    'title': 'Học hàm/học vị',
    'dic': 'Mã số thuế (DIČ)',
    'ico': 'Mã số doanh nghiệp (IČO)',
    'rc': 'Số định danh cá nhân (RČ)',
    'street': 'Đường',
    'city': 'Thành phố',
    'zip': 'Mã bưu điện',
    'country': 'Quốc gia',
    'nace': 'Ngành nghề (SK NACE)',
    'iban': 'IBAN',
    // Tax inputs
    'year': 'Năm tính thuế',
    'income': 'Doanh thu (tổng)',
    'expense': 'Chi phí (tổng)',
    'social': 'BHXH đã đóng',
    'health': 'BHYT đã đóng',
    'prepayments': 'Thuế tạm nộp (preddavky)',
    'loss': 'Lỗ được khấu trừ (tùy chọn)',
    'other_income': 'Thu nhập khác (tùy chọn)',
    'withholding': 'Thuế khấu trừ (§43) (tùy chọn)',
    'assign_2pct': 'Chuyển 2% thuế',
    'receiver_ico': 'IČO tổ chức nhận (2%)',
    // Errors
    'required': 'Trường bắt buộc',
    'number': 'Vui lòng nhập số hợp lệ',
  };

  static String t(String key) => _s[key] ?? key;
}

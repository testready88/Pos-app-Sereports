class DropdownItem {
  final String code;
  final String name;

  DropdownItem({required this.code, required this.name});

  factory DropdownItem.fromJson(Map<String, dynamic> json) {
    return DropdownItem(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

class CustomFormField {
  final String id;
  final String fieldKey;
  final String
      fieldType; // text, textarea, select, checkbox, date, number, email, tel
  final String label;
  final String? placeholder;
  final String? description;
  final bool required;
  final List<Map<String, String>>? options;
  final String? section;
  final int order;
  final dynamic defaultValue;
  final bool isActive;

  CustomFormField({
    required this.id,
    required this.fieldKey,
    required this.fieldType,
    required this.label,
    this.placeholder,
    this.description,
    required this.required,
    this.options,
    this.section,
    required this.order,
    this.defaultValue,
    required this.isActive,
  });

  factory CustomFormField.fromJson(Map<String, dynamic> json) {
    return CustomFormField(
      id: json['_id'] ?? json['id'] ?? '',
      fieldKey: json['fieldKey'] ?? '',
      fieldType: json['fieldType'] ?? 'text',
      label: json['label'] ?? '',
      placeholder: json['placeholder'],
      description: json['description'],
      required: json['required'] ?? false,
      options: json['options'] != null
          ? List<Map<String, String>>.from(
              json['options'].map((opt) => Map<String, String>.from(opt)))
          : null,
      section: json['section'],
      order: json['order'] ?? 0,
      defaultValue: json['defaultValue'],
      isActive: json['isActive'] ?? true,
    );
  }
}

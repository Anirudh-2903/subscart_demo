class Delivery {
  final String id;
  final String name;
  final String description;
  final int calories;
  final int protein;
  final int fat;
  final int carbs;
  final String image;
  String deliveryDate;
  final String timeSlot;
  final String deliveryType;
  String status;
  final String location;

  Delivery({
    required this.id,
    required this.name,
    required this.description,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.image,
    required this.deliveryDate,
    required this.timeSlot,
    required this.deliveryType,
    required this.status,
    required this.location,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      calories: json['calories'],
      protein: json['protein'],
      fat: json['fat'],
      carbs: json['carbs'],
      image: json['image'],
      deliveryDate: json['deliveryDate'],
      timeSlot: json['timeSlot'],
      deliveryType: json['deliveryType'],
      status: json['status'],
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'calories': calories,
      'protein': protein,
      'fat': fat,
      'carbs': carbs,
      'image': image,
      'deliveryDate': deliveryDate,
      'timeSlot': timeSlot,
      'deliveryType': deliveryType,
      'status': status,
      'location': location,
    };
  }

  Delivery copyWith({
    String? id,
    String? name,
    String? description,
    int? calories,
    int? protein,
    int? fat,
    int? carbs,
    String? image,
    String? deliveryDate,
    String? timeSlot,
    String? deliveryType,
    String? status,
    String? location,
  }) {
    return Delivery(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      fat: fat ?? this.fat,
      carbs: carbs ?? this.carbs,
      image: image ?? this.image,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      timeSlot: timeSlot ?? this.timeSlot,
      deliveryType: deliveryType ?? this.deliveryType,
      status: status ?? this.status,
      location: location ?? this.location,
    );
  }
}

class Location {
  final int id;
  final String name;
  final String address;

  Location({
    required this.id,
    required this.name,
    required this.address,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      name: json['name'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
    };
  }
}
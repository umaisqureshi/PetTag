class Person {
  Person(
      {this.age,
      this.description,
      this.email,
      this.firstname,
      this.images,
      this.petId,
      this.lastname,
      this.location,
      this.interest});

  String firstname;
  String lastname;
  String location;
  int age;
  String description;
  List<dynamic> images;
  String email;
  String petId;
  String interest;

  toMap() {
    Map<String, dynamic> map = Map();
    map['firstname'] = this.firstname;
    map['lastname'] = this.lastname;
    map['location'] = this.location;
    map['age'] = this.age;
    map['description'] = this.description;
    map['email'] = this.email;
    map['interest'] = this.interest;
    map['pet'] = this.petId;
    map['imagePath'] = this.images;
  }
}

class Pet {
  Pet({
    this.type,
    this.name,
    this.age,
    this.behaviour,
    this.breed,
    this.description,
    this.sex,
    this.size,
    this.ownerId,
    this.petId,
    this.images,
    this.longitude,
    this.latitude,
    this.lockStatus,
    this.visible,
  });

  String type;
  bool visible;
  String name;
  String ownerId;
  String petId;
  int age;
  String sex;
  String size;
  String breed;
  String behaviour;
  String description;
  List<dynamic> images;
  double latitude;
  double longitude;
  bool lockStatus;

  toMap() {
    Map<String, dynamic> map = Map();
    map['type'] = this.type;
    map['name'] = this.name;
    map['age'] = this.age;
    map['sex'] = this.sex;
    map['size'] = this.size;
    map['breed'] = this.breed;
    map['behaviour'] = this.behaviour;
    map['description'] = this.description;
    map['ownerId'] = this.ownerId;
    map['images'] = this.images;
    map['petId'] = this.petId;
    map['latitude'] = this.latitude;
    map['longitude'] = this.longitude;
    map['lockStatus'] = this.lockStatus??false;
    map['visible'] = this.visible;
    return map;
  }
}

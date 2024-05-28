class Student{
  final String name;
  final String phone;

  Student(this.name, this.phone);

  Student.fromJson(Map<dynamic,dynamic> json)
  : name = json["nombre"] as String,
  phone = json["telefono"] as String;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
     'nombre' : name,
     'telefono' : phone,
  };

}
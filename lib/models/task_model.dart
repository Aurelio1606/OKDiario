class Task{
  final String name;
  final String description;

  Task(this.name, this.description);

  Task.fromJson(Map<dynamic,dynamic> json)
  : name = json["Nombre"] as String,
  description = json["Descripcion"] as String;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
     'Nombre' : name,
     'Descripcion' : description,
  };

}
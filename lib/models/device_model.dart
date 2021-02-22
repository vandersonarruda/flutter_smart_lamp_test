class Device {
  String id, name;
  bool power;
  int scene, red, green, blue;

  Device({
    this.id,
    this.name,
    this.power = false,
    this.scene = 0,
    this.red = 0,
    this.green = 0,
    this.blue = 0,
  });

  Map toMap() {
    return {
      'id': this.id,
      'name': this.name,
      'power': this.power,
      'scene': this.scene,
      'red': this.red,
      'green': this.green,
      'blue': this.blue,
    };
  }

  Device.fromMap(Map map)
      : this.id = map['id'],
        this.name = map['name'],
        this.power = map['power'],
        this.scene = map['scene'],
        this.red = map['red'],
        this.green = map['green'],
        this.blue = map['blue'];
}

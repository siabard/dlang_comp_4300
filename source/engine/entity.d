module engine.entity;

class Entity {
  int id;


  bool is_alive;

  this(int id) {
    this.id = id;
    this.is_alive = true;
  }

}

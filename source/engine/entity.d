module engine.entity;

class Entity {
  import engine.component.animation_component;
  import engine.component.position_component;
  import engine.component.movement_component;

  MovementComponent* movement;
  PositionComponent* position;
  AnimationComponent* animation;

  int id;
  string name;

  bool is_alive;

  this(int id, stirng name) {
    this.id = id;
    this.name = name;
    this.is_alive = true;
  }

}

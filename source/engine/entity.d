module engine.entity;

class Entity {
  import engine.component.animation_component;
  import engine.component.position_component;
  import engine.component.movement_component;

  MovementComponent* movement;
  PositionComponent* position;
  AnimationComponent* animation;

  int id;


  bool is_alive;

  this(int id) {
    this.id = id;
    this.is_alive = true;
  }

}

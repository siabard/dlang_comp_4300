module engine.entity;

class Entity {
  import engine.components.animation_component;
  import engine.components.position_component;
  import engine.components.movement_component;
  import engine.components.action_component;
  import engine.components.collision_component;
  import engine.components.trigger_component;
  import engine.components.input_component;

  MovementComponent movement;
  PositionComponent position;
  AnimationComponent animation;
  ActionComponent action;
  CollisionComponent collision;
  TriggerComponent trigger;
  InputComponent inputs;

  int id;
  string name;

  bool is_alive;

  this(int id, string name) {
    this.id = id;
    this.name = name;
    this.is_alive = true;
  }

}

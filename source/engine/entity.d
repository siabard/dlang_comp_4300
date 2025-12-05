module engine.entity;

class Entity {
  import engine.component.animation_component;
  import engine.component.position_component;
  import engine.component.movement_component;
  import engine.component.action_component;
  import engine.component.collision_component;
  import engine.component.trigger_component;

  MovementComponent movement;
  PositionComponent position;
  AnimationComponent animation;
  ActionComponent action;
  CollisionComponent collision;
  TriggerComponent trigger;

  int id;
  string name;

  bool is_alive;

  this(int id, string name) {
    this.id = id;
    this.name = name;
    this.is_alive = true;
  }

}

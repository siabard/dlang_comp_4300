module engine.component.movement_component;

struct MovementComponent {
  float delta_x;
  float delta_y;
}

MovementComponent* add_movement(MovementComponent origin, float velocity) {
  import std.math;

  auto vector_length = sqrt( origin.delta_x * origin.delta_x + origin.delta_y * origin.delta_y);
  auto vector = new MovementComponent;

  vector.delta_x = origin.delta_x * velocity / vector_length;
  vector.delta_y = origin.delta_y * velocity / vector_length;
  return vector;
}

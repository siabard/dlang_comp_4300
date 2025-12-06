module engine.components.movement_component;

class MovementComponent {
  float dx;
  float dy;

  this() {
    this.dx = 0;
    this.dy = 0;
  }
}

MovementComponent add_movement(MovementComponent origin, float velocity) {
  import std.math;

  float vector_length = sqrt( origin.dx * origin.dx + origin.dy * origin.dy);
  MovementComponent vector = new MovementComponent();

  vector.dx = origin.dx * velocity / vector_length;
  vector.dy = origin.dy * velocity / vector_length;
  return vector;
}

module engine.components.position_component;

class PositionComponent {
  float x;
  float y;

  float old_x;
  float old_y;

  this() {
    this.x = 0;
    this.y = 0;
    this.old_x = 0;
    this.old_y = 0;
  }
}


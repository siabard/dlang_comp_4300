module engine.component.collision_component;


class CollisionComponent {
  int ox, oy, w, h;

  this(int ox, int oy, int w, int h) {
    this.ox = ox;
    this.oy = oy;
    this.w = w;
    this.h = h;
  }
}


module engine.components.collision_component;


enum CollideType: string {
  BLOCK = "block",
  TRIGGER = "trigger"
}

class CollisionComponent {
  int ox, oy, w, h;
  CollideType collide_type;

  this(int ox, int oy, int w, int h) {
    this.ox = ox;
    this.oy = oy;
    this.w = w;
    this.h = h;
  }
}


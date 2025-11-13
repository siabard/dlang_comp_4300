module engine.physics;

import engine.component.collision_component;

/// <summary>
///     Checks for collision between two rectangular structures using
///     Axis-Aligned Bounding Box collision detection.
/// </summary>
/// <param name="boxA">
///     The bounding box of the first structure.
/// </param>
/// <param name="boxB">
///     The bounding box of the second structure.
/// </param>
/// <returns>
///     True if the two structures are colliding; otherwise, false.
/// </returns>

bool aabb(CollisionComponent a, CollisionComponent b) {
  /*
  boxA.Left < boxB.Right &&
            boxA.Right > boxB.Left &&
            boxA.Top < boxB.Bottom &&
            boxA.Bottom > boxB.Top;
  */

  int a_left = a.ox - a.w / 2;
  int a_right = a.ox + a.w + 2;
  int a_top = a.oy - a.h / 2;
  int a_bottom = a.oy + a.h / 2;

  int b_left = b.ox - b.w / 2;
  int b_right = b.ox + b.w / 2;
  int b_top = b.oy - b.h / 2;
  int b_bottom = b.oy - b.h + 2;

  return a_left < b_right && a_right > b_left && a_top < b_bottom && a_bottom > b_top;

}

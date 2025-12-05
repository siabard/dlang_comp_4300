module engine.physics;

import engine.component.collision_component;
import engine.component.position_component;

import bindbc.sdl;

import engine.camera;

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

bool aabb(PositionComponent pa, CollisionComponent a, PositionComponent pb, CollisionComponent b) {
  import std.conv;
  /*
  boxA.Left < boxB.Right &&
            boxA.Right > boxB.Left &&
            boxA.Top < boxB.Bottom &&
            boxA.Bottom > boxB.Top;
  */

  int a_left   = to!int(pa.x) + a.ox - a.w / 2;
  int a_right  = to!int(pa.x) + a.ox + a.w + 2;
  int a_top    = to!int(pa.y) + a.oy - a.h / 2;
  int a_bottom = to!int(pa.y) + a.oy + a.h / 2;

  int b_left   = to!int(pb.x) + b.ox - b.w / 2;
  int b_right  = to!int(pb.x) + b.ox + b.w / 2;
  int b_top    = to!int(pb.y) + b.oy - b.h / 2;
  int b_bottom = to!int(pb.y) + b.oy - b.h + 2;

  return a_left < b_right && a_right > b_left && a_top < b_bottom && a_bottom > b_top;

}


bool aabb_camera(SDL_Rect a, Camera c) {
  import std.conv;

  int a_left = a.x;
  int a_right = a.x + a.w;
  int a_top = a.y;
  int a_bottom = a.y + a.h;

  int c_left = to!int(c.x);
  int c_right = to!int(c.x + c.width);
  int c_top = to!int(c.y);
  int c_bottom = to!int(c.y + c.height);

  return a_left < c_right && a_right > c_left && a_top < c_bottom && a_bottom > c_top;

}

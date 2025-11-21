module engine.camera;

import bindbc.sdl;

struct Camera {
  float x;
  float y;

  float width;
  float height;
}




// SRC, DST Rect 를 Camera 에 맞게 줄이기
void relative_tgt_rect(ref SDL_Rect source, ref SDL_Rect origin, Camera camera) {
  import std.conv;

  // origin 을 우선 camera x, y 만큼 이동시켜야한다.. (원점을 맞추기)
  
  int camera_x = to!int(camera.x);
  int camera_y = to!int(camera.y);
  int camera_w = to!int(camera.width);
  int camera_h = to!int(camera.height);

  int new_x = origin.x - camera_x;
  int new_y = origin.y - camera_y;
  int new_w = origin.w;
  int new_h = origin.h;

  if(new_w > camera_w) {
    new_w = camera_w;
  }
  
  if(new_h > camera_h) {
    new_h = camera_h;
  }

  if (new_x < 0) {
    // new_x 가 음의 값을 가진 만큼 폭을 줄인다.
    new_w += new_x;
    new_x = 0;

    // 폭을 줄인만큼 source 의 시작 지점도 바꾼다.
    // 폭은 나중에 결정될 것임
    
    source.x = source.x + source.w - new_w;

  } else if(new_x + new_w > camera_w) {
    new_w = camera_w - new_x;
  }

  if (new_y < 0) {
    // new_y 가 음의 값을 가진 만큼 높이를 줄인다.
    new_h += new_y;
    new_y = 0;

    // 높이를 줄인만큼 source 의 시작 지점도 바꾼다.
    source.y = source.y + source.h - new_h;

  } else if(new_y + new_h > camera_h) {
    new_h = camera_h - new_y;
  }


  origin.x = new_x;
  origin.y = new_y;
  origin.w = new_w;
  origin.h = new_h;

  source.w = new_w;
  source.h = new_h;
 
}

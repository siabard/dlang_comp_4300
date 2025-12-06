module engine.input.keyboard;

import bindbc.sdl;
import std.stdio;

class KeyboardHandler {
  bool[int] pressed;
  bool[int] released;
  bool[int] held;

  this() {
    for(int i = 0; i < SDL_NUM_SCANCODES; i++) {
      this.pressed[i] = false;
      this.released[i] = false;
      this.held[i] = false;
    }
  }

  void start_frame() {
    foreach(i; pressed.byKey) {
      this.pressed[i] = false;
    }

    foreach(i; released.byKey) {
      this.released[i] = false;
    }
  }

  void on_press(int keycode) {
    this.pressed[keycode] = true;
    this.released[keycode] = false;
    this.held[keycode] = true;
  }

  void on_release(int keycode) {
    this.pressed[keycode] = false;
    this.released[keycode] = true;
    this.held[keycode] = false;
  }
}

module engine.scene;

import engine.game;

class Scene {
  string name;
  string path;
  Game parent;

  this(string name, string path) {
    this.name = name;
    this.path = path;
  }
}

module engine.scene;

import engine.game;
import engine.config;

// system
import engine.systems.animation_system;
import engine.systems.render_system;

class Scene {
  string name;
  string path;
  Game game;

  this(string name, string path) {
    this.name = name;
    this.path = path;
  }

  void load_setting() {
    open_config(game.renderer, game.entity_manager, game.asset_manager, game.scenes, game.tiles, this.path);
  }

  void update(float dt) {
    animation_system(game.entity_manager, dt);
  }

  void render() {
    
    // entity 노출하기
    render_system(game.renderer, game.entity_manager, game.asset_manager);
      
  }
}

module engine.scene;

import engine.game;
import engine.config;

// system
import engine.systems.animation_system;
import engine.systems.input_system;
import engine.systems.action_system;
import engine.systems.render_system;
import engine.systems.movement_system;

import engine.camera;

class Scene {
  string name;
  string path;
  Game game;
  Camera camera;

  this(string name, string path) {
    this.name = name;
    this.path = path;

    Camera newCamera  = {x: 5, y: 5, width: 400, height: 400};
    this.camera = newCamera;
  }

  void load_setting() {
    open_config(
		game.renderer, 
		game.entity_manager, 
		game.asset_manager, 
		game.action_manager, 
		game.trigger_manager,
		game.input_manager,
		game.scenes, 
		game.tiles, 
		this.path);
  }

  void update(float dt) {
    // entity에 키 입력 세팅 
    input_system(game.entity_manager, game.input_manager, game.keyboard_handler);
    
    // entity 의 움직임을 실제로 설정한다.
    movement_system(game.entity_manager, dt);
    action_system(game.entity_manager);
    animation_system(game.entity_manager, dt);
  }

  void render() {
    
    // entity 노출하기
    render_system(game.renderer, game.entity_manager, game.asset_manager, this.camera);
      
  }
}

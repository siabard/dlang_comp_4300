module engine.game;

import bindbc.sdl;
import std.stdio;
import std.string;
import std.conv;
import std.algorithm;

import engine.asset_manager;
import engine.atlas;
import engine.animation;
import engine.entity;
import engine.entity_manager;
import engine.scene;

import engine.component.position_component;
import engine.component.movement_component;
import engine.component.animation_component;

import engine.input.keyboard;
import engine.config;


class Game {
  SDL_Window* window;
  SDL_Renderer* renderer;
  AssetManager asset_manager;
  KeyboardHandler keyboard_handler;

  SDL_Event event;
  bool is_running;

  SceneSetting[string] scene_settings;
  EntityManager entity_manager;

  this(SDL_Window* window, SDL_Renderer* renderer) {
    this.window = window;
    this.renderer = renderer;
    this.asset_manager = new AssetManager;
    this.entity_manager = new EntityManager;
    this.keyboard_handler = new KeyboardHandler;
  }

  ~this() {
    this.asset_manager.clean_up();

    if(this.renderer != null) {
      SDL_DestroyRenderer(this.renderer);
    }

    if(this.window != null) {
      SDL_DestroyWindow(window);
    }
  }

  void load_setting(string filepath) {
    open_config(this.renderer, this.entity_manager, this.asset_manager, scene_settings, filepath);
  }

  // 게임내에서는 각각의 시스템이 있다. (position, movement, animation 등)

  void update(float dt) {
    
    foreach(entity; this.entity_manager.entities) {
      if( entity.animation.current_animation != "") {
	entity.animation.update(dt);
      }
    }

    this.entity_manager.update();    

  }

  void game_loop() {
    this.is_running = true;

    ulong last_time;
    ulong dt;
    ulong current_time;

    last_time = SDL_GetTicks64();

    while(this.is_running) {
      this.keyboard_handler.start_frame();
      while(SDL_PollEvent(&this.event)) {
	if( this.event.type == SDL_QUIT) {
	  this.is_running = false;
	}

	if( this.event.type == SDL_KEYDOWN) {
	  this.keyboard_handler.on_press( event.key.keysym.scancode );
	}

	if( this.event.type == SDL_KEYUP) {
	  this.keyboard_handler.on_release( event.key.keysym.scancode );
	}
      }

      // 지난 프레임 이 후 얼마나 시간이 지났는지 확인한다.
      current_time = SDL_GetTicks64();
      dt = current_time - last_time;
      last_time = current_time;

      
      // update 한다.
      this.update(dt);

      SDL_RenderClear(this.renderer);

      // entity 노출하기
      foreach(entity; this.entity_manager.entities) {
	if(entity.animation !is null && entity.animation.current_animation != "" && entity.position !is null) {
	  Animation animation = entity.animation.animations[ entity.animation.current_animation ];

	  // 노출 atlas 의 좌표값
	  string atlas_name = animation.atlas_name;
	
	  // 해당 텍스쳐
	  Atlas atlas = this.asset_manager.atlases[ atlas_name ];
	  SDL_Texture* texture = this.asset_manager.textures[ atlas.texture_name ];

	  // atlas의 현재 frame
	  int current_frame = entity.animation.get_animation_frame();
	  
	  // SDL_Rect 값
	  SDL_Rect src_rect = atlas.rects[current_frame];
	  
	  SDL_Rect dst_rect = { x: to!int(entity.position.x), y: to!int(entity.position.y), w: 16, h: 16 };
	  // 그리기
	  SDL_RenderCopy( this.renderer, texture, 
			  &src_rect, &dst_rect);
	  
	}
      }

      
      SDL_RenderPresent(this.renderer);
    }
  }

}

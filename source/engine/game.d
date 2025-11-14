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

// system
import engine.systems.animation_system;
import engine.systems.render_system;

class Game {
  SDL_Window* window;
  SDL_Renderer* renderer;
  AssetManager asset_manager;
  KeyboardHandler keyboard_handler;

  SDL_Event event;
  bool is_running;

  Scene[] scenes;
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
    open_config(this.renderer, this.entity_manager, this.asset_manager, scenes, filepath);
  }

  // 게임내에서는 각각의 시스템이 있다. (position, movement, animation 등)

  void update(float dt) {
    animation_system(this.entity_manager, dt);

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
      render_system(this.renderer, this.entity_manager, this.asset_manager);
      
      SDL_RenderPresent(this.renderer);
    }
  }

}

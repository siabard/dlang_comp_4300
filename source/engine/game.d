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

import engine.drawtext;


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
    open_config(this.renderer, this.entity_manager, this.asset_manager, this.scenes, filepath);
    
    foreach(scene; this.scenes) {
      scene.game = this;
    }
    // 가장 위에 있는 scene을 초기화한다.
    this.scenes[$ - 1].load_setting();
  }

  // 게임내에서는 각각의 시스템이 있다. (position, movement, animation 등)

  void update(float dt) {
    // 가장 최상단의 scene을 update 함.
    this.scenes[$ - 1].update(dt);
    
    this.entity_manager.update();    

  }

  void game_loop() {
    import engine.pixels;

    // 임시 Surface 생성 
    SDL_Surface* surface = IMG_Load("./assets/hangul.png");
    SDL_Texture* texture;

    if(surface != null) {
      writeln("Loading hangul asset");
    }
    for(int x = 0; x < 50; x++) {
      for(int y = 0; y < 50; y++) {
	set_pixel(surface, x, y, 0xccffccff);
      }
    }


    texture = SDL_CreateTextureFromSurface(this.renderer, surface);
    SDL_FreeSurface(surface);
    SDL_Rect src_rect = {x: 0, y: 0, w: 50, h: 50};
    SDL_Rect dst_rect = {x: 120, y: 120, w: 50, h: 50};

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
      
      this.scenes[$ - 1].render();

      // Text 노출처리 
      draw_text(this.renderer, this.asset_manager.fonts, 90, 90, 120, "ABCDEFGHIJKLMN");
      // Text 노출처리 
      draw_text(this.renderer, this.asset_manager.fonts, 90, 126, 120, "아름다운 강산에 금수강산에. 단군 할아버지 터잡으시고.");


      // Surface 노출처리
      SDL_RenderCopy(this.renderer, 
		     texture,
		     &src_rect,
		     &dst_rect);
      
      SDL_RenderPresent(this.renderer);
    }

    SDL_DestroyTexture(texture);
  }

}

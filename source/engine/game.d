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

import engine.component.position_component;
import engine.component.movement_component;
import engine.component.animation_component;

import engine.input.keyboard;

struct SceneSetting {
  string name;
  string path;
}

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
    File file = File(filepath, "r");
    
    while(!file.eof()) {
      string line = strip(file.readln());
  
      // 빈 줄도 무시한다.
      if(line.length == 0) {
	continue;
      }

      // # 으로 시작하면 주석이라 무시한다.
      if(line[0] == '#') {
	continue;
      }


      // line 을 split 하여 각 앞이 어떤 값인지에 따라 각기 다른 형태의 설정을 한다.
      // window w, h : Window의 width와 height를 재설정 
      auto lineArray = line.split;
      
      // split 했는데 한 줄로 쭈욱이어졌다면
      // 그건 잘못된 포맷이다.
      if(lineArray.length  == 0) {
	continue;
      }

      if(lineArray[0] == "window") {
	writeln(" Width :" , lineArray[1], " Height :", lineArray[2]);
      } else if(lineArray[0] == "scene") {
	// scene 정보 등록 
	SceneSetting ss = { name: lineArray[1], path: lineArray[2] };
	scene_settings[ lineArray[1] ] = ss;
      } else  if(lineArray[0] == "texture") {
	SDL_Texture* texture = IMG_LoadTexture(this.renderer, std.string.toStringz(lineArray[2]) );
	this.asset_manager.textures[ lineArray[1] ] = texture;
      } else if( lineArray[0] == "atlas") {
	SDL_Texture* texture = this.asset_manager.textures[ lineArray[2] ];
	if(texture != null) {
	  int width = parse!int( lineArray[3] );
	  int height = parse!int( lineArray[4]);
	  Atlas atlas = new Atlas( lineArray[1], lineArray[2],  width, height, texture);

	  this.asset_manager.atlases[lineArray[1]] = atlas;
	}
      } else if (lineArray[0]  == "animation") {
	int start_frame = parse!int( lineArray[3] );
	int frame_length = parse!int( lineArray[4] );
	float duration = parse!float( lineArray[5] );
	bool is_loop = lineArray[6] == "Y";
	
	Animation anim = new Animation( lineArray[1], lineArray[2], start_frame, frame_length, duration, is_loop);
	this.asset_manager.animations[ lineArray[1] ] = anim;
      } else if (lineArray[0] == "entity") {
	// Entity 생성
	this.entity_manager.new_entity( lineArray[1] );
	this.entity_manager.update();
      } else if (lineArray[0] == "set-entity") {
	string entity_name = lineArray[1];
	
	Entity[] targets = this.entity_manager.entities.find!((ent, name) => ent.name == name)(entity_name);
	if(targets.length > 0) {
	  string component_name = lineArray[2];
	  Entity target = targets[0];

	  // 대상 component 에 따른 조치 
	  if (component_name == "position") {
	    PositionComponent position = new PositionComponent();
	    float x = parse!float( lineArray[3] );
	    float y = parse!float( lineArray[4] );
	    position.x = x;
	    position.y = y;
	    target.position = position;
	  } else if (component_name == "movement") {
	    MovementComponent movement = new MovementComponent();
	    float dx = parse!float( lineArray[3] );
	    float dy = parse!float( lineArray[4] );

	    movement.dx = dx;
	    movement.dy = dy;

	    target.movement = movement;
	  } else if (component_name == "animation") {
	    Animation anim = this.asset_manager.animations[ lineArray[4] ];

	    if( target.animation is null) {
	      target.animation = new AnimationComponent();
	    }
	    target.animation.current_animation = lineArray[3];	    
	    target.animation.animations[ lineArray[3] ] = anim;

	  }
	}
      }
    }
    file.close();

    // Scnene 정보 확인 
    foreach (scene_setting; this.scene_settings.values ) {
      writeln("name :", scene_setting.name , " path : ", scene_setting.path );
    }
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

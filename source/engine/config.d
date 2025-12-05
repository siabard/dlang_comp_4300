module engine.config;


import engine.entity_manager;
import engine.asset_manager;
import engine.scene;
import engine.atlas;
import engine.animation;
import engine.entity;

import engine.component.position_component;
import engine.component.movement_component;
import engine.component.animation_component;
import engine.component.collision_component;
import engine.component.action_component;
import engine.component.trigger_component;

import engine.tile;
import engine.action_manager;
import engine.trigger_manager;

import engine.scene;

import bindbc.sdl;
import std.stdio;
import std.string;
import std.conv;
import std.algorithm;

void open_config(SDL_Renderer* renderer, 
		 EntityManager em, 
		 AssetManager am, 
		 ActionManager actm,
		 TriggerManager tm,
		 ref Scene[] scenes,
		 ref Tile[string] tiles, 
		 string filepath) {
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
	Scene scene = new Scene(lineArray[1], lineArray[2]);
	scenes  ~= scene;
      } else  if(lineArray[0] == "texture") {
	SDL_Texture* texture = IMG_LoadTexture(renderer, std.string.toStringz(lineArray[2]) );
	am.textures[ lineArray[1] ] = texture;
      } else  if(lineArray[0] == "font") {
	SDL_Texture* texture = IMG_LoadTexture(renderer, std.string.toStringz(lineArray[2]) );
	am.fonts[ lineArray[1] ] = texture;
      } else if( lineArray[0] == "atlas") {
	SDL_Texture* texture = am.textures[ lineArray[2] ];
	if(texture != null) {
	  int width = parse!int( lineArray[3] );
	  int height = parse!int( lineArray[4]);
	  Atlas atlas = new Atlas( lineArray[1], lineArray[2],  width, height, texture);

	  am.atlases[lineArray[1]] = atlas;
	}
      } else if (lineArray[0]  == "animation") {
	int start_frame = parse!int( lineArray[3] );
	int frame_length = parse!int( lineArray[4] );
	float duration = parse!float( lineArray[5] );
	bool is_loop = lineArray[6] == "Y";
	
	Animation anim = new Animation( lineArray[1], lineArray[2], start_frame, frame_length, duration, is_loop);
	am.animations[ lineArray[1] ] = anim;
      } else if (lineArray[0] == "entity") {
	// Entity 생성
	em.new_entity( lineArray[1] );
	em.update();
      } else if (lineArray[0] == "set-entity") {
	string entity_name = lineArray[1];
	
	Entity[] targets = em.entities.find!((ent, name) => ent.name == name)(entity_name);
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
	    Animation anim = am.animations[ lineArray[4] ];

	    if( target.animation is null) {
	      target.animation = new AnimationComponent();
	    }
	    target.animation.current_animation = lineArray[3];	    
	    target.animation.animations[ lineArray[3] ] = anim;

	  } else if (component_name == "action") {
	    Action action = actm.actions[ lineArray[3] ];
	    if(target.action is null) {
	      target.action = new ActionComponent();
	    }

	    target.action.actions ~= action;
	  } else if (component_name == "collision") {
	    
	    int ox = parse!int( lineArray[4] );
	    int oy = parse!int( lineArray[5] );
	    int w  = parse!int( lineArray[6] );
	    int h  = parse!int( lineArray[7] );

	    CollisionComponent collision = new CollisionComponent(ox, oy, w, h);
	    collision.collide_type = cast(CollideType) lineArray[3];
	    target.collision = collision;
	  } else if (component_name == "trigger") {
	    if(target.trigger is null) {
	      target.trigger = new TriggerComponent();
	    }
	    Trigger trigger = tm.triggers[ lineArray[3] ];
	    target.trigger.triggers ~= trigger;
	  }

	}
      } else if (lineArray[0] == "map") {
	Tile newTile = new Tile( lineArray[1], am, renderer);
	newTile.load_map( lineArray[2] );
	tiles[ lineArray[1] ] = newTile;
      } else if (lineArray[0] == "action") {
	Action action = { action_type: cast(ActionType) lineArray[2],
	  args: [ lineArray[3], lineArray[4] ], 
	  is_active: true,
	  name: lineArray[1] 
	};
	
	actm.actions[ lineArray[1] ] = action;
	
      } else if(lineArray[0] == "trigger") {
	auto trigger_type = cast(TriggerType) lineArray[2];
	Trigger trigger = new Trigger(trigger_type, lineArray[1], lineArray[3]);
	tm.triggers[ lineArray[1] ] = trigger;
      }
    }
    file.close();  
}

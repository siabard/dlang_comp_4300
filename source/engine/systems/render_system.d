module engine.systems.render_system;

import std.conv;

import bindbc.sdl;

import engine.entity;
import engine.entity_manager;
import engine.animation;

import engine.animation;
import engine.atlas;
import engine.asset_manager;
import engine.camera;

import engine.physics;
/// 주어진 entity 를 노출함
/// entity 는 camera 에 종속됨 

void render_system(SDL_Renderer* renderer, EntityManager em, AssetManager am, Camera camera) {
  
  // entity 노출하기
  foreach(entity; em.entities) {
    if(entity.animation !is null && entity.animation.current_animation != "" && entity.position !is null) {
      Animation animation = entity.animation.animations[ entity.animation.current_animation ];

      // 노출 atlas 의 좌표값
      string atlas_name = animation.atlas_name;
	
      // 해당 텍스쳐
      Atlas atlas = am.atlases[ atlas_name ];
      SDL_Texture* texture = am.textures[ atlas.texture_name ];

      // atlas의 현재 frame
      int current_frame = entity.animation.get_animation_frame();
	  
      // SDL_Rect 값
      SDL_Rect src_rect = atlas.rects[current_frame];  
      SDL_Rect dst_rect = { x: to!int(entity.position.x), y: to!int(entity.position.y), w: 16, h: 16 };


      // 해당 dst_rect가 camera 에 노출가능한지 먼저 평가한다.
      if(aabb_camera( dst_rect, camera)) {
	relative_tgt_rect(src_rect, dst_rect, camera);
      }

      // 그리기
      SDL_RenderCopy( renderer, texture, 
		      &src_rect, &dst_rect);
	  
    }
  }

}

module engine.systems.collision_system;

// collision system 은...
// block 을 할 수도 있고..
// 아니면 trigger 를 발생시킬 수도 있음..

import engine.entity_manager;
import engine.physics;
import engine.component.collision_component;

import std.algorithm;
import std.range;

void collision_system(EntityManager em) {
  // collide : 
  auto entities = em.entities
    .filter!(
	     entity => 
	     ((entity.position !is null) && (entity.collision !is null))
	     )
    .array;

  foreach(source; entities) {
    foreach(target; entities) {
      if(source.id != target.id) {
	bool collided = aabb(source.position, 
			     source.collision,
			     target.position,
			     target.collision);

	// 충돌했다면 target 에 따라 서로 다른 행동을 해야함 
	// BLOCK 이동 중지
	// TRIGGER action 주입 

	auto collide_type = target.collision.collide_type;

	if(collide_type == CollideType.BLOCK) {
	  // 블럭 처리 
	} else if(collide_type == CollideType.TRIGGER) {
	  // 트리거에 정의된 action을 source 에 주입 
	  
	}
      }
    }
  }

}

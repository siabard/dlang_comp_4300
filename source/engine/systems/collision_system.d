module engine.systems.collision_system;

// collision system 은...
// block 을 할 수도 있고..
// 아니면 trigger 를 발생시킬 수도 있음..

import engine.entity_manager;
import engine.physics;
import engine.components.collision_component;
import engine.components.action_component;

import engine.trigger_manager;
import engine.action_manager;

import std.algorithm;
import std.range;
import std.stdio;

void collision_system(EntityManager em, ActionManager am) {
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

	if(collided) {
	  auto collide_type = target.collision.collide_type;
	  if(collide_type == CollideType.BLOCK) {
	    // 블럭 처리 
	  } else if(collide_type == CollideType.TRIGGER) {
	    // 트리거에 정의된 action을 source 에 주입 
	    if(target.trigger !is null) {
	      foreach(trigger; target.trigger.triggers) {
		// on-enter 트리거에 대한 처리 
		if(trigger.trigger_type == TriggerType.ON_ENTER) {
		  auto action_name = trigger.action_name;
		  auto action = am.actions[action_name];
		  
		  if(source.action is null) {
		    source.action = new ActionComponent();
		  }
		  
		  source.action.actions ~= action;
		}
	      }
	    }
	  }
	}	
      }
    }
  }
}

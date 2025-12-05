module engine.systems.action_system;

import engine.action_manager;
import engine.entity_manager;

void action_system(EntityManager em) {

  import std.algorithm;
  import std.range;
  import std.stdio;

  foreach(entity; em.entities) {
    if(entity.action !is null) {
      // actions 리스트를 가져온다.

      auto actions = entity.action.actions;

      foreach(ref act; actions) {
	if(act.is_active) {
	  if(act.action_type == ActionType.TELEPORT) {
	    action_teleport(entity, act);
	    // 한번 사용된 action 은 폐기합니다.
	    act.is_active = false;

	    writeln("act ", act.name, " is acted ");
	  }
	}
      }

      entity.action.actions = entity.action.actions.filter!( action => action.is_active ).array;
    }
  }
}

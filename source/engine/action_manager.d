module engine.action_manager;

import engine.entity;
import engine.component.position_component;

enum ActionType : string {
  TELEPORT = "teleport"
}

struct Action {
  ActionType action_type;
  string[] args;
  string name;
  bool is_active;
}

class ActionManager {
  Action[string] actions;

  this() {
  }
}


void action_teleport(Entity entity, Action action) {
  import std.conv;
  
  // teleport 는 position component 가 반드시 필요함.
  if(entity.position !is null) {
    string[] args = action.args;

    auto x = to!int( args[0] );
    auto y = to!int( args[1] );

    entity.position.x = to!float(x);
    entity.position.y = to!float(y);
  }
}

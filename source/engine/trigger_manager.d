module engine.trigger_manager;

enum TriggerType : string {
  ON_ENTER = "on-enter",
  ON_EXIT = "on-exit" 
}


class Trigger {
  TriggerType trigger_type;
  string name;
  string action_name;

  this(TriggerType trigger_type, string name, string action_name) {
    this.trigger_type = trigger_type;
    this.name = name;
    this.action_name = action_name;
  }

}


class TriggerManager {
  Trigger[string] triggers;
}

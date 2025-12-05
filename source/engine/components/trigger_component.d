module engine.component.trigger_component;

enum TriggerType : string {
  ON_ENTER = "on-enter",
  ON_EXIT = "on-exit" 
}

class TriggerComponent {
  TriggerType trigger_type;
  string name;

  this(TriggerType trigger_type, string name) {
    this.trigger_type = trigger_type;
    this.name = name;
  }

}

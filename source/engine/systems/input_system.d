module engine.systems.input_system;

import engine.entity_manager;
import engine.input_manager;
import engine.components.action_component;
import engine.input.keyboard;

void input_system(EntityManager em, InputManager im, KeyboardHandler kh) {
  import std.algorithm;
  import std.range;

  auto input_entities = em.entities.filter!( entity => entity.inputs !is null).array;

  foreach(entity; input_entities) {
    foreach(k; entity.inputs.input.byKey) {
      entity.inputs.input[k] = false;
    }
  }

  // KeyboardHandler 에서 held 된 항목에 대한 반복을 처리한다.
  foreach(int scancode, bool is_held; kh.held) {
    if(!im.inputs.keys.find(scancode).empty) {
      auto input_key = im.inputs[ scancode ];

      foreach(entity; input_entities) {
	if(!entity.inputs.input.keys.find( input_key ).empty) {
	  entity.inputs.input[ input_key ] |= is_held;
	}
      }
    }
  }
}

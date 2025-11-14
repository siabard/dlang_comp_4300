module engine.systems.animation_system;

import engine.entity;
import engine.entity_manager;
import engine.animation;

void animation_system(EntityManager em, float dt) {
  
  foreach(entity; em.entities) {
    if( entity.animation.current_animation != "") {
      entity.animation.update(dt);
    }
  }
}

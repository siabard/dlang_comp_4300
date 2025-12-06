module engine.systems.movement_system;

import engine.input_manager;
import engine.entity_manager;

enum VELOCITY = 100.0f;

void movement_system(EntityManager em, float dt) { 

  // 키 입력에 따른 이동 설정
  foreach(entity; em.entities) {
    // 키 입력 처리 및 이동이 가능한 경우 처리 
    if((entity.inputs !is null) && (entity.movement !is null)) {
      entity.movement.dx = 0f;
      entity.movement.dy = 0f;
      if(entity.inputs.input[ InputAction.MOVE_UP ]) {
	entity.movement.dy -= VELOCITY * dt / 1000;
      } 

      if(entity.inputs.input[ InputAction.MOVE_DOWN] ) {
	entity.movement.dy += VELOCITY * dt / 1000;
      }

      if(entity.inputs.input[ InputAction.MOVE_LEFT ] ) {
	entity.movement.dx -= VELOCITY * dt / 1000;
      }

      if(entity.inputs.input[ InputAction.MOVE_RIGHT ] ) {
	entity.movement.dx += VELOCITY * dt / 1000;
      }
    }
  }

  // 실제 이동 처리
  foreach(entity; em.entities) {
    // 이동이 가능하려면 position component 와 movement component 가 필요 
    if((entity.position !is null) && (entity.movement !is null)) {
      entity.position.old_x = entity.position.x;
      entity.position.old_y = entity.position.y;

      entity.position.x += entity.movement.dx;
      entity.position.y += entity.movement.dy;
    }
  }
}

module engine.input_manager;


// 이동
enum InputAction: string {
  MOVE_UP    = "move-up",
  MOVE_DOWN  = "move-down",
  MOVE_LEFT  = "move-left",
  MOVE_RIGHT = "move-right"
}

// 입력항목에 대한 설정을 모두 관장하는 곳 

class InputManager {
  InputAction[int] inputs;
}

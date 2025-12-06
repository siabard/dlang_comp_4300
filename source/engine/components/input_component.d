module engine.components.input_component;

import engine.input_manager;


// 엔터티가 사용자 입력을 받아 처리해야한다는 것을 알림 
class InputComponent {

  // 어떤 키에 반응해야할지 정리된 내역 
  // scancode 에 맞추어서 동작 
  bool[InputAction] input;   
}

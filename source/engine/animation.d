module engine.animation;

class Animation {
  import bindbc.sdl;

  string name;
  int x, y;
  int w, h;
  bool is_loop;
  bool is_alive;
  float duration;
  float elapsed_time;
  int current_frame;
  int frame_length;

  int start_x;

  this(string name, int x, int y, int w, int h, int frame_length, float duration, bool is_loop = false) {
    this.name = name;
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.frame_length = frame_length;
    this.duration = duration;
    this.is_loop = is_loop;
    this.is_alive = true;
  }

  void update(float dt) {
    if( this.is_alive == true) {
      this.elapsed_time = this.elapsed_time + dt;

      if(this.elapsed_time >= this.duration) {
	this.elapsed_time = 0;
	this.current_frame = this.current_frame + 1;

	if (this.current_frame >= this.frame_length) {
	  this.current_frame = 0;

	  if (this.is_loop == false) {
	    this.is_alive = false;
	  }
	}
      }
    }
    
  }

  SDL_Rect get_sdl_rect() {
    // w*current_frame 만큼 떨어진 항목을 반환 
    SDL_Rect result = {
      x: this.x + this.w * this.current_frame,
      y: this.y,
      w: this.w,
      h: this.h
    };
    
    return result;
  }  

}

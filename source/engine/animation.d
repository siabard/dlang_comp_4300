module engine.animation;

class Animation {
  import bindbc.sdl;

  string name;
  string atlas_name;
  bool is_loop;
  bool is_alive;
  float duration;
  float elapsed_time;
  int current_frame;
  int start_frame;
  int frame_length;

  int start_x;

  this(string name, string atlas_name, int start_frame, int frame_length, float duration, bool is_loop = false) {
    this.name = name;
    this.atlas_name = atlas_name;
    this.start_frame = start_frame;
    this.frame_length = frame_length;
    this.duration = duration;
    this.is_loop = is_loop;
    this.is_alive = true;
    this.current_frame = start_frame;
    this.elapsed_time = 0.0;
  }

  void update(float dt) {
    import std.stdio;

    if( this.is_alive == true) {
      this.elapsed_time = this.elapsed_time + dt;
      if(this.elapsed_time >= this.duration) {
	this.elapsed_time = 0;
	this.current_frame = this.current_frame + 1;

	if (this.current_frame >= this.frame_length + this.start_frame) {
	  this.current_frame = this.start_frame;

	  if (this.is_loop == false) {
	    this.is_alive = false;
	  }
	}
      }
    }
  }
}

module engine.components.animation_component;

class AnimationComponent {

  import engine.animation;

  string current_animation;
  float elapsed_time;
  int current_frame;
  Animation[string] animations;
  bool is_alive;

  this() {
    this.current_animation = "";
    this.elapsed_time = 0.0;
    this.is_alive = true;
  }

  void update(float dt) {
    if( this.is_alive) {
      Animation current_anim = this.animations[ this.current_animation ];
      float duration = current_anim.duration;
      int frame_length = current_anim.frame_length;

      bool is_loop = current_anim.is_loop;


      this.elapsed_time = this.elapsed_time + dt;
      
      if(this.elapsed_time > duration) {
	this.current_frame = this.current_frame + 1;

	if(this.current_frame >= frame_length) {
	  this.current_frame = 0;

	  if( !is_loop ) {
	    this.is_alive = false;
	  }
	}

	this.elapsed_time = 0;
      }
    }
  }

  int get_animation_frame() {
    Animation current_anim = this.animations[ this.current_animation ];
    int start_frame = current_anim.start_frame;

    return start_frame + this.current_frame;
  }
  
}

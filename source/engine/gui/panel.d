module engine.gui.panel;

class Panel {
  import bindbc.sdl;

  SDL_Texture* texture;
  int width;
  int height;

  int x, y;
  this(SDL_Texture* texture, int x, int y, int width, int height) {
    this.texture = texture;
    this.width = width;
    this.height = height;
    this.x = x;
    this.y = y;
  }

  void render(SDL_Renderer* renderer) {
    // Top Left
    SDL_Rect src_tl = {x: 0, y: 0, w: 3, h: 3};
    SDL_Rect dst_tl = {x: this.x, y: this.y, w: 3, h: 3};

    SDL_RenderCopy(renderer, this.texture, &src_tl, &dst_tl);

    // Top center
    SDL_Rect src_tc = {x: 3, y: 0, w: 3, h: 3};
    SDL_Rect dst_tc = {x: this.x + 3, y: this.y, w: this.width - 3 * 2, h: 3};

    SDL_RenderCopy(renderer, this.texture, &src_tc, &dst_tc);

    // Top Right
    SDL_Rect src_tr = {x: 6, y: 0, w: 3, h: 3};
    SDL_Rect dst_tr = {x: this.x + this.width - 3, y: this.y, w: 3, h: 3};

    SDL_RenderCopy(renderer, this.texture, &src_tr, &dst_tr);

    // Middle left
    SDL_Rect src_ml = {x: 0, y: 3, w: 3, h: 3};
    SDL_Rect dst_ml = {x: this.x, y: this.y + 3, w: 3, h: this.height - 3 * 2};

    SDL_RenderCopy(renderer, this.texture, &src_ml, &dst_ml);

    // Middle center
    SDL_Rect src_mc = {x: 3, y: 3, w: 3, h: 3};
    SDL_Rect dst_mc = {x: this.x + 3, y: this.y + 3, w: this.width - 3 * 2, h: this.height - 3 * 2};

    SDL_RenderCopy(renderer, this.texture, &src_mc, &dst_mc);

    // Middle right
    SDL_Rect src_mr = {x: 6, y: 3, w: 3, h: 3};
    SDL_Rect dst_mr = {x: this.x + this.width - 3, y: this.y + 3, w: 3, h: this.height - 3 * 2};

    SDL_RenderCopy(renderer, this.texture, &src_mr, &dst_mr);

    // Bottom left
    SDL_Rect src_bl = {x: 0, y: 6, w: 3, h: 3};
    SDL_Rect dst_bl = {x: this.x, y: this.y + this.height - 3, w: 3, h: 3};

    SDL_RenderCopy(renderer, this.texture, &src_bl, &dst_bl);

    // bototm center
    SDL_Rect src_bc = {x: 3, y: 6, w: 3, h: 3};
    SDL_Rect dst_bc = {x: this.x + 3, y: this.y + this.height - 3, w: this.width - 3 * 2, h: 3};

    SDL_RenderCopy(renderer, this.texture, &src_bc, &dst_bc);

    // bottom right
    SDL_Rect src_br = {x: 6, y: 6, w: 3, h: 3};
    SDL_Rect dst_br = {x: this.x + this.width - 3, y: this.y + this.height - 3, w: 3, h: 3};

    SDL_RenderCopy(renderer, this.texture, &src_br, &dst_br);

  }
}

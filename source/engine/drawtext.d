module engine.drawtext;

import bindbc.sdl;
import std.algorithm;
import std.conv;
import std.array;
import std.format;
import engine.hangul;


void draw_ascii(SDL_Renderer *renderer, SDL_Texture *texture, int x, int y, uint code) {
  // Texture는 8x16 비트맵 이미지임
  // 가로 16개, 세로 8줄  등록됨

  int row = code / 16;
  int col = code % 16;
  SDL_Rect src = {x: col * 8, y: row * 16, w: 8, h: 16};
  SDL_Rect dst = {x: x, y: y, w: 8, h: 16};
  SDL_RenderCopy(renderer, texture, &src, &dst);
}

void draw_hangul(SDL_Renderer *renderer, SDL_Texture *texture, int x, int y, uint code) {
  // Texture는 16x16비트맵 이미지임
  // bul, jaso 에 맞추어 글자 노출처리

  Jaso jaso = build_jaso(code);
  Bul bul = build_bul(jaso);

  // 초성 - 상단 8벌이 초성 

  int cho_y = (bul.cho - 1) * 16;
  int cho_x = (jaso.cho - 1) * 16;
  SDL_Rect src = {x: cho_x, y: cho_y, w: 16, h: 16};
  SDL_Rect dst = {x: x, y: y, w: 16, h: 16};
  SDL_RenderCopy(renderer, texture, &src, &dst);


  // 중성 - 상단 9~12벌이 중성
  int mid_y = ((bul.mid - 1) + 8) * 16;
  int mid_x = (jaso.mid - 1) * 16;
  src.x = mid_x;
  src.y = mid_y;

  SDL_RenderCopy(renderer, texture, &src, &dst);


  // 종성 - 상담 13~16이 종성
  if(jaso.jong > 0) {
    int jong_y = ((bul.jong - 1) + 12) * 16;
    int jong_x = jaso.jong * 16;
    src.x = jong_x;
    src.y = jong_y;
    SDL_RenderCopy(renderer, texture, &src, &dst);
    
  }
}

void draw_text(SDL_Renderer *renderer, SDL_Texture*[string] textures, int x, int y, int w, string str) {
  import std.stdio;

  // 일단 string 을 ucs2 array (uint array) 로 변환
  auto utf8_array = str.map!(a => a.to!string).array;

  int text_width = 0;
  int text_height = 0;
  foreach(s; utf8_array) {
    uint code = utf8_to_ucs2(s);

    Languages code_language = ucs2_languages(code);

    // 글자에 따른 draw 처리 
    if (code_language == Languages.Ascii) {
      draw_ascii(renderer, textures["asciifont"], x + text_width, y + text_height, code);
    } else if(code_language == Languages.Hangul) {
      draw_hangul(renderer, textures["korfont"], x + text_width, y + text_height, code);
    }

    // code 가 속한 영역에 따른 폭 제어..
    // 한글은 가로가 아스키 폰트의 2배임
    
    if( code_language == Languages.Ascii ) {
      text_width += 8;
    } else if ( code_language == Languages.Hangul || code_language == Languages.HangulJamo) {
      text_width += 16;
    }

    // text_width 가 width 를 넘어갔다면
    // 다음 줄로 넘겨야함 

    if(text_width >= w) {
      text_width = 0;
      text_height += 16;
    }
    
  }
}

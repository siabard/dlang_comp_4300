module engine.bitmap_font;

import bindbc.sdl;
import std.stdio;
import std.format;

/// PNG 파일을 SURFACE로 읽어들여
/// 해당 FNT 내역을 바이너리로 생성하도록 함

void surface_to_fnt(SDL_Surface* surface, string path) 
{
  ubyte[] buffer;

  
}


unittest {

  /// FNT 형식으로 나온 내역을 제대로 풀어낼 수 있는가
  string font_image = "                "
    ~ "      ####      "
    ~ "    ###  ###    "
    ~ "   ##      ##   "
    ~ "   ##      ##   "
    ~ "   ##      ##   "
    ~ "   ##      ##   "
    ~ "   ##########   "
    ~ "   ##########   "
    ~ "   ##      ##   "
    ~ "   ##      ##   "
    ~ "   ##      ##   "
    ~ "   ##      ##   "
    ~ "   ##      ##   "
    ~ "                ";

  
  ubyte[] buffer;
  int multiflier = 128;
  
  ubyte subsum = 0;
  foreach(f; font_image) {
    if(f == '#') {
      subsum += multiflier;
    }

    multiflier /= 2;
    if(multiflier == 0) {
      multiflier = 128;
      buffer ~= subsum;

      subsum = 0;
  
    }
  }

  foreach(buf; buffer) {
    writeln(format("%2x", buf));
  }
}

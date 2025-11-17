module engine.bitmap_font;

import bindbc.sdl;
import std.stdio;
import std.format;
import std.conv;

/// PNG 파일을 SURFACE로 읽어들여
/// 해당 FNT 내역을 바이너리로 생성하도록 함
/// 다만 크기를 따져보면 그냥 PNG쓰는 것이 훨씬 용량도 작음
/// 16K ~ 12K 정도로 극한으로 줄일 수는 있지만.. 압축을 안하기때문에
/// PNG쪽이 훨씬 용량효율적임.
/// 추가로 Surface 에 Font 이미지를 올려야하기때문에 실질적으로 메모리 사용량이
/// 크게 줄어든다고 보기는 어려울 듯 함

void surface_to_fnt(SDL_Surface* surface, string path, int width, int height) 
{
  ubyte[] buffer;

  /**
	SDL_PixelFormat* format;
	int w, h;
	int pitch;

*/
  File file = File(path, "w");
  
  int cols = surface.w / width;
  int rows = surface.h / height;
  int bidx = 0;

  buffer.length = surface.h * (surface.w / 8);

  for(int r = 0; r < rows; r++) {
    for(int c = 0; c < cols; c++) {
      
      for(int h = 0; h < height; h++) {
	// (c, r) 부위의 길이 높이를 해당 16진수로 변환 
	ubyte va = 128u;
	ubyte sum = 0u;
	for(int w = 0; w < width; w++) {
	  int pos = (c * width + w) * surface.format.BytesPerPixel + (r * height + h) * surface.pitch;
	  uint *target_pixel = cast(uint*) (cast(ubyte*) surface.pixels + pos);
	  if(*target_pixel != 0) {
	    sum = cast(ubyte)(sum + va);
	  }
	  va = va / 2u;
	  if(va < 1) {
	    buffer[bidx] = sum;
	    bidx += 1;
	    va = 128u;
	    sum = 0u;
	  }
	}

      }
      
    }
  }
  

  file.rawWrite(buffer);

  file.close();
  
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

module engine.gui.dialog_panel;

import bindbc.sdl;

import std.algorithm;
import std.conv;
import std.range;

import engine.gui.panel;
import engine.hangul;


enum DIALOG_PADDING = 3;

class DialogPanel {
  Panel panel;

  SDL_Texture* avatar;

  string[] dialog;

  this(SDL_Texture* texture, 
       int x, 
       int y, 
       int width, 
       int height, 
       SDL_Texture* avatar, 
       string text) {

    int text_width = width - DIALOG_PADDING * 3;
    int tw, th;

    tw = 0;
    th = 0;

    if(avatar != null) {
      SDL_QueryTexture( avatar, null, null, &tw, &th);
      // avatar 가 존재한다면...
      // 노출할 수 있는 길이가 줄어듬.
      // AVATAR 사이즈 옆으로 다시 PADDING이 붙음
      text_width = text_width - tw - DIALOG_PADDING;
    }


    // text_width 가 줄어들었다면 이제 dialog 를 설정한다.
    int render_width = 0;
    string intermediate_text = "";
    foreach(s; text.map!(a => a.to!string).array) {
      auto lang = ucs2_languages(utf8_to_ucs2(s));

      if(lang == Languages.Ascii) {
	render_width += WIDTH_FNT_ASCII;
      } else if(lang == Languages.Hangul) {
	render_width += WIDTH_FNT_HANGUL;
      }

      if( s == "\n" ) {
	this.dialog ~= intermediate_text;
	intermediate_text = "";
	render_width = 0;
      } else {

	if(render_width > text_width) {
	  this.dialog ~= intermediate_text;
	  intermediate_text = "";
	  render_width = 0;
	}
      
	intermediate_text ~= s;
      }
      
    }

    if(intermediate_text.length > 0) {
      this.dialog ~= intermediate_text;
    }

    this.panel = new Panel(texture, x, y, width, height);
  }

}



unittest {
  import std.stdio;
  import std.algorithm;
  import std.conv;
  import std.range;
  import engine.hangul;

  string sample = "안녕하세요. ABC";

  auto array_utf8 = sample.map!(a => a.to!string).array;
  int idx = 0;
  foreach(s; array_utf8) {
    
    writeln("Sample [", idx, " ] => ", s, " => ", ucs2_languages(utf8_to_ucs2(s)));
    idx++;
  }

  DialogPanel newPanel = new DialogPanel(null, 0, 0, 120, 400, null, "하늘이 노한다. ABCDE EFHG . 한글이 잘\n써집니까? 이게 맞습니까? 어떻게 만들어질까요?");
  writeln(newPanel.dialog);

}

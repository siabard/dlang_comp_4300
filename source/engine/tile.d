module engine.tile;

import engine.asset_manager;
import engine.atlas;

import dtiled;
import jsonizer;
import bindbc.sdl;

import std.path;
import std.string;

class Tile {
  string name;
  AssetManager am;
  SDL_Renderer* renderer;

  uint[][string] map_data;

  this(string name, AssetManager am, SDL_Renderer* renderer) {
    this.name = name;
    this.am = am;
    this.renderer = renderer;
  }
  
  void load_tileset(TilesetData[] tileSetData, string dir_name) {
    import std.stdio;

    foreach(datum; tileSetData) {
      writeln("datum => ", datum);

      // TilesetData 에서는 source 로 tileset path 를 찾을 수 있다.
      auto tileset = datum;
      if(datum.source != "") {
	// source 가 있는 경우는 해당 파일을 읽어서 Texture 와 atlas 를 등록할 수 있어야함.
	tileset = readJSON!TilesetData(buildPath(dir_name, datum.source));
      } 

      
      writeln(" tile texture => ", datum.image);

      string tilename = "tile_" ~ tileset.name;
      // Texture 로 삼을 파일의 경로 + 이름
      SDL_Texture* texture = IMG_LoadTexture(this.renderer, std.string.toStringz(buildPath(dir_name, datum.image)));
      this.am.textures[ tilename ] = texture;
      
      // Texutre를 atlas로 변환하기 위한 티일 크기와 atlas 이름 
      int width = datum.tileWidth;
      int height = datum.tileHeight;
      
      Atlas atlas = new Atlas( tilename, tilename, width, height, texture);
      this.am.atlases[ tilename ] = atlas;
    }
  }

  void load_map(string path) {
    MapData mapData = MapData.load(path);

    // tileset에 대한 분석
    this.load_tileset( mapData.tilesets, dirName(path));

    // layer 에 대한 분석
    foreach(layer; mapData.layers) {
      auto layername= layer.name;

      map_data[ layername ] = layer.data;
    }

  }
}

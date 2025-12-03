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

    foreach(tileset; tileSetData) {
      writeln("tileset =>", tileset);
      string tilename = "tile_" ~ tileset.name;
      // Texture 로 삼을 파일의 경로 + 이름
      SDL_Texture* texture = IMG_LoadTexture(this.renderer, std.string.toStringz(buildPath(dir_name, tileset.image)));
      this.am.textures[ tilename ] = texture;
      
      // Texutre를 atlas로 변환하기 위한 티일 크기와 atlas 이름 
      int width = tileset.tileWidth;
      int height = tileset.tileHeight;
      
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

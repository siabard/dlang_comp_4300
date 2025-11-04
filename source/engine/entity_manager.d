module engine.entity_manager;

class EntityManager {
  import engine.entity;
  import std.algorithm : filter;
  import std.range : array;

  int entity_id;

  Entity[] entities;

  Entity[] added_entities;

  this() {
    this.entity_id = 0;
  }


  ~this() {
    foreach(entity; this.entities) {
      destroy(entity);
    }
  }

  void new_entity() { 
    this.entity_id = this.entity_id + 1;

    Entity new_entity = new Entity(this.entity_id);

    added_entities ~= new_entity;  // cause reallocate
  }

  void update() {
    // is_alive == false 인 entity를 일단 모두 제거 (이후 GC가 처리할 수 있음)
    foreach (entity; this.entities.filter!(e => !e.is_alive)) {
        destroy(entity);
    }

    // 이제 필요없어진 entity는 모두 필터로 거른다.
    this.entities = this.entities.filter!( entity => entity.is_alive).array;
    
    // append 
    this.entities ~= this.added_entities;

    // added_entities는 모두 비운다.

    this.added_entities = [];
    
  }
}

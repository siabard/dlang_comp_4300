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
    // 죽은 것은 모두 없앤다.
    auto alives = this.entities.filter!( entity => entity.is_alive == true);
    this.entities = alives.array;
    
    // append 
    this.entities ~= this.added_entities;


    // added_entities는 모두 비운다.

    this.added_entities = [];
    
  }
}

module engine.entity_manager;

import std.stdio;
import std.traits : fullyQualifiedName;
import std.meta : AliasSeq;
import std.typecons : Nullable;

/// -----------------------
/// Generic Component Pool
/// -----------------------

class ComponentPool(T) {
  T[] data;
  size_t[] freeIndices; // 비어있는 슬롯에 대한 Stack 구현

  size_t add(T val) {
    if (!freeIndices.empty) {
      auto idx = freeIndices[$ - 1];
      freeIndices.length -= 1; // Pop
      data[idx] = val;

      return idx;

    } else {
      data ~= val;
      return data.length - 1;
    }
  }

  
  void remove(size_t idx) {
    // 해당 슬롯을 Free 로 설정한다.
    // 단 오류가 있을 수 있으므로 idx 가 data.length 보다 작아야한다.
    freeIndex ~= idx;
  }

  ref T get(size_t idx) { return data[idx]; }
  size_t length() const { return data.length; }

}

/// ------------------------
/// Util : 컴파일시에 AliasSeq  에 있는 type의 인덱스 찾기
/// ------------------------
template indexOf(T, Types...) {
  enum int indexOf = indexOfImpl!(T, Types, 0);
}


template indexOfImpl(T, Types, int pos) {
  static if (Types.length == 0) 
    enum indexOfImpl = -1;
  else static if (is(Types[0] == T))
    enum indexOfImpl = pos;
  else
    enum indexOfImpl = indexOfImpl!(T, Types[1 .. $], pos + 1);
}


/// --------------------
/// ECS Core
/// --------------------

class ECS(Components...) {
  enum size_t COMP_COUNT = Components.length;
  alias ComponentTypes = AliasSeq!Components;

  // "component"가 없을 때
  enum size_t NONE = size_t.max;

  // Entity 구조체 정의 

  struct Entity {
    bool alive;
    size_t id;
    size_t compIdx[COMP_COUNT]; // 컴포넌트별 ID
    ulong mask;                 // 비트 마스크 : bit i == 1 => 컴포넌트 i를 가지고 있음 
  }

  Entity[] entities;
  size_t[] freeEntities; // 삭제시킨 entities를 다시 재활용하기 위한 곳

  // Component pool
  void*[COMP_COUNT] pools;


  this() {
    // 타입(C)별로 pool을 생성
    foreach(i, C; ComponentTypes) {
      pools[i] = cast(void*) new ComponentPool!C();
    }


  }

  /// Entity 생성 처리 
  size_t createEntity() {
    size_t id;

    if (!freeEntities.empty) {
      id = freeEntities[$ - 1];
      freeEntities.length -= 1;
      ref Entity e = entities[id];

      e.alive = true;
      e.mask = 0;

      // reset compIdx;
      foreach(i; 0 .. COMP_COUNT) e.compIdx[i] = NONE;
    } else {
      id = entities.length;
      Entity e;
      e.alive = true;
      e.id = id;
      e.mask = 0;

      foreach(i; 0 .. COMP_COUNT) e.compidx[i] = NONE;
      entities ~= e;
    }

    return id;
  }

  /// destroy entity: remove all components and mark dead
  void destroyEntity(size_t id) {
    if (id >= entities.length) return;
    ref Entity e = entities[id];
    if (!e.alive) return;

    // remove component present
    foreach(i; 0 .. COMP_COUNT) {
      if ((e.mask & (1UL << i)) != 0) {
	// remove from pool i
	removeComponentByPoolIndex(i, e.compIdx[i]);
	e.compIdx[i] = NONE;
      }
    }

    e.mask = 0;
    e.alive = false;
    freeEntities ~= id;
  }

  /// add component T to entity
  size_t addComponent(T)(size_t entityId, T value) {
    enum int compPos = indexOf!(T, ComponentTypes);
    static if (compPos < 0)
      static assert(false, "Component type " ~ fullyQualifiedName!T ~ " not registered");
    auto pool = cast(ComponentPool!T*) pools[compPos];
    size_t idx = pool.add(value);

    ref Entity e = entities[entityId];
    e.compIdx[compPos] = idx;
    e.mask |= (1UL << compPos);

    return idx;
  }

  /// remove component T from entity
  void removeComponent(T)(size_t entityId) {
    enum int compPos = indexOf!(T, ComponentTypes);
    static if (compPos < 0) 
      static assert(false, "Component type " ~ fullyQuanlifiedName!T ~ " not registered");
    ref Entity e = entities[entityId];
    if ((e.mask & (1UL << compPos)) == 0) return; // not present;

    auto pool = cast(ComponentPool!T*) pools[compPos];
    pool.remove(e.compIdx[compPos]);
    e.compIdx[compPos] = NONE;
    e.mask &= ~(1UL << compPos);
  }

  /// get component reference by type T
  ref T getComponentOfEntity(T)(size_t entityId) {
    enum int compPos = indexOf!(T, ComponentTypes);
    auto pool = cast(ComponentPool!T*) pools[compPos];
    size_t idx = entities[entityId].compIdx[compPos];
    return pool.get(idx);
  }

  /// low-level: remove component slot by pool index
  void removeComponentByPoolIndex(size_t compPos, size_t poolIndex) {
    // dispatch based on compPos
    static foreach (i, C; ComponentTypes) {
      if ( i == compPos ) {
	auto pool = cast(ComponentPool!C*) pools[i];
	pool.remove(poolIndex);
      }
    }
  }

  /// API: Entity가 주어진 component T를 보유하는가?
  bool hasComponent(T)(size_t entityId) const {
    enum int compPos = indexOf!(T, ComponentTypes);
    return (entities[entityId].mask & (1UL << compPos)) != 0;
  }

  /// 다수의 컴포넌트 타입에 대한 마스크 만들기
  ulong makeMask(Ts...)() pure nothrow @safe {
    ulong m = 0;
    static foreach (i, C; ComponentTypes) {
      static foreach (j, Q; Ts) {
	static if (is(C == Q))
	  m |= (1UL << i);
      }
    }
    return m;
  }

  /**
   * each!(QueryComponents...)( callback )
   * callback signature: void delegate(size_t entityId, ref Q1, ref Q2, ...)
   *
   * callback 은 delegate나 파라미터 시그니쳐가 일치하는 함수 포인터
   */
  void each(alias Callback, QueryComponents...)() {
    enum ulong queryMask = makeMask!(QueryComponents)();

    foreach(ref e; entities) {
      if(!e.alive) continue;
      if((e.mask & queryMask) != queryMask) continue; // QueryComponents 가 모두 일치해야만 함

      // QueryComponents 순서대로 각 컴포넌트를 수집
      static if (QueryComponents.length == 0) {
	Callback(e.id);
      } else {
	// 매개변수를 생성한다.
	callCallback!Callback(e, QueryComponents);
      }
      
    }
  }

  /// helper: 주어진 Components 에 대해 entity에 Callback을 호출한다.
  private void callCallback(alias Callback, QueryComponents...)(ref Entity e) {
    // QueryComponents 의 갯수에 맞추어 callback 을 실행한다.
    static if (QueryComponents.length == 1) {
      alias Q0 = QueryComponents[0];
      auto pool0 = cast(ComponentPool!Q0*) pools[indexOf!(Q0, ComponentTypes)];
      ref Q0 c0 = pool0.get(e.compIdx[indexOf!(Q0, ComponentTypes)]);
      Callback(e.id, c0);
    } else static if (QueryComponents.length == 2) {
      alias Q0 = QueryComponents[0];
      alias Q1 = QueryComponents[1];
      auto pool0 = cast(ComponentPool!Q0*) pools[indexOf!(Q0, ComponentTypes)];
      auto pool1 = cast(ComponentPool!Q1*) pools[indexOf!(Q1, ComponentTypes)];
      ref Q0 c0 = pool0.get(e.compIdx[indexOf!(Q0, ComponentTypes)]);
      ref Q1 c1 = pool1.get(e.compIdx[indexOf!(Q1, ComponentTypes)]);
      Callback(e.id, c0, c1);
    } else static if (QueryComponents.length == 3) {
      alias Q0 = QueryComponents[0];
      alias Q1 = QueryComponents[1];
      alias Q2 = QueryComponents[2];
      auto pool0 = cast(ComponentPool!Q0*) pools[indexOf!(Q0, ComponentTypes)];
      auto pool1 = cast(ComponentPool!Q1*) pools[indexOf!(Q1, ComponentTypes)];
      auto pool2 = cast(ComponentPool!Q2*) pools[indexOf!(Q2, ComponentTypes)];
      ref Q0 c0 = pool0.get(e.compIdx[indexOf!(Q0, ComponentTypes)]);
      ref Q1 c1 = pool1.get(e.compIdx[indexOf!(Q1, ComponentTypes)]);
      ref Q1 c2 = pool2.get(e.compIdx[indexOf!(Q2, ComponentTypes)]);
      Callback(e.id, c0, c1, c2);

    } else {
      static assert(false, "each supports up to 3 query components in this ecs ");
    }
  }
  
}


/*




/// -------------------------------
/// Example usage & systems
/// -------------------------------
void main()
{
    alias MyECS = ECS!(Position, Velocity, Health);
    auto ecs = new MyECS();

    // create entities
    size_t e1 = ecs.createEntity();
    size_t e2 = ecs.createEntity();
    size_t e3 = ecs.createEntity();

    // add components (note: components are stored in pools and indexed)
    ecs.addComponent!Position(e1, Position(0, 0));
    ecs.addComponent!Velocity(e1, Velocity(1, 0.2));
    ecs.addComponent!Health(e1, Health(100));

    ecs.addComponent!Position(e2, Position(10, 5));
    // e2 has no velocity

    ecs.addComponent!Velocity(e3, Velocity(-0.5, 0.1));
    // e3 has no position

    writeln("Initial state:");
    // print pos for those with Position
    ecs.each!((size_t id, ref Position p) { writeln("Entity ", id, " pos=", p.x, ",", p.y); })(Position);

    // movement system: only operate on entities having Position+Velocity
    ecs.each!((size_t id, ref Position p, ref Velocity v) {
        p.x += v.dx;
        p.y += v.dy;
    })(Position, Velocity);

    writeln("\nAfter one movement update:");
    ecs.each!((size_t id, ref Position p) { writeln("Entity ", id, " pos=", p.x, ",", p.y); })(Position);

    // damage system: reduce health for all with Health
    ecs.each!((size_t id, ref Health h) {
        h.hp -= 10;
        writeln("Damaged entity ", id, " hp=", h.hp);
        if (h.hp <= 0) ecs.destroyEntity(id);
    })(Health);

    writeln("\nAfter damage:");
    ecs.each!((size_t id, ref Health h) { writeln("Entity ", id, " hp=", h.hp); })(Health);

    // destroy an entity explicitly
    ecs.destroyEntity(e2);
    writeln("\nAfter destroying e2, remaining entities with Pos:");
    ecs.each!((size_t id, ref Position p) { writeln("Entity ", id, " pos=", p.x, ",", p.y); })(Position);

    // Done
    writeln("\nFinish.");
}

*/

#ifndef ENEMY_H
#define ENEMY_H

#include <godot_cpp/classes/node2d.hpp>

namespace godot {

class Enemy : public Node2D {
	GDCLASS(Enemy, Node2D)

protected:
	static void _bind_methods();
	

public:
	Enemy();
	~Enemy();
	void Prevent();
};

}

#endif

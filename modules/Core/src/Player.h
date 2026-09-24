#ifndef PLAYER_H
#define PLAYER_H

#include <godot_cpp/classes/node2d.hpp>

namespace godot {

class Player : public Node2D {
	GDCLASS(Player, Node2D)

protected:
	static void _bind_methods();

public:
	void take_damage(int amount);
};

}

#endif
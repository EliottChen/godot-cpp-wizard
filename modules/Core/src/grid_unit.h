#ifndef GRID_UNIT_H
#define GRID_UNIT_H

#include <godot_cpp/classes/node2d.hpp>

namespace godot {

class GridUnit : public Node2D {
	GDCLASS(GridUnit, Node2D)

protected:
	static void _bind_methods();
	
public:
	GridUnit();
	~GridUnit();
	void Unity(); 	
	void _ready() override;
};

}

#endif

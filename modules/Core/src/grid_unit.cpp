#include "grid_unit.h"
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;

void GridUnit::_bind_methods() {
    ClassDB::bind_method(D_METHOD("Unity"), &GridUnit::Unity);
}

GridUnit::GridUnit() {
}

GridUnit::~GridUnit() {
}

void GridUnit::Unity(){
    UtilityFunctions::print("Unit instanced !");
}

void GridUnit::_ready(){
    Node2D::_ready();
    Unity();
}
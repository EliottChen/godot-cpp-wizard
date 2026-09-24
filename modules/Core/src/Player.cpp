#include "player.h"
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;

void Player::_bind_methods() {
	ClassDB::bind_method(D_METHOD("take_damage", "amount"), &Player::take_damage);
}

void Player::take_damage(int amount) {
	UtilityFunctions::print("Player took ", amount, " damage");
}
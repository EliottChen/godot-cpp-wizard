#include "enemy.h"
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;

void Enemy::_bind_methods() {
    ClassDB::bind_method(D_METHOD("Prevent"), &Enemy::Prevent);
}

Enemy::Enemy() {
}

Enemy::~Enemy() {
}

void Enemy::Prevent(){
    UtilityFunctions::print("Hi i am an enemy built with cpp wizard");
}
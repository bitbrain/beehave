#include "beehave_blackboard.h"
#include <godot_cpp/core/class_db.hpp>

using namespace godot;

BeehaveBlackboard::BeehaveBlackboard()
{

}

BeehaveBlackboard::~BeehaveBlackboard()
{
    
}

void BeehaveBlackboard::test()
{
    
}

void BeehaveBlackboard::_bind_methods()
{
    ClassDB::bind_method(D_METHOD("test"), &BeehaveBlackboard::test);
}

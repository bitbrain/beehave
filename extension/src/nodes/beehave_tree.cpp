#include "beehave_tree.h"
#include <godot_cpp/core/class_db.hpp>

using namespace godot;

BeehaveTree::BeehaveTree()
{

}

BeehaveTree::~BeehaveTree()
{
    
}

void BeehaveTree::test() {

}

void BeehaveTree::_bind_methods()
{
    ClassDB::bind_method(D_METHOD("test"), &BeehaveTree::test);
}

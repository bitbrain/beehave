#include "beehave_tree_node.h"
#include <core/class_db.hpp>

using namespace godot;

BeehaveTreeNode::BeehaveTreeNode()
{

}

BeehaveTreeNode::~BeehaveTreeNode()
{
    
}

void BeehaveTreeNode::test() {

}

void BeehaveTreeNode::_bind_methods()
{
    ClassDB::bind_method(D_METHOD("test"), &BeehaveTreeNode::test);
}

#ifndef BEEHAVE_TREE_H
#define BEEHAVE_TREE_H

#include <godot_cpp/classes/node.hpp>

using namespace godot;

class BeehaveTree : public Node
{
    GDCLASS(BeehaveTree, Node);

protected:
    static void _bind_methods();

public:
    BeehaveTree();
    ~BeehaveTree();
};

#endif // BEEHAVE_TREE_H
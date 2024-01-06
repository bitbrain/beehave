#ifndef BEEHAVE_NODE_H
#define BEEHAVE_NODE_H

#include <godot_cpp/classes/node.hpp>

using namespace godot;

class BeehaveNode : public Node
{
    GDCLASS(BeehaveNode, Node);

protected:
    static void _bind_methods();

public:
    BeehaveNode();
    ~BeehaveNode();
};

#endif // BEEHAVE_NODE_H
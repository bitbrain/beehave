#ifndef BEEHAVE_BLACKBOARD_H
#define BEEHAVE_BLACKBOARD_H

#include <godot_cpp/classes/node.hpp>

using namespace godot;

class BeehaveBlackboard : public Node
{
    GDCLASS(BeehaveBlackboard, Node);

protected:
    static void _bind_methods();

public:
    BeehaveBlackboard();
    ~BeehaveBlackboard();
};

#endif // BEEHAVE_BLACKBOARD_H
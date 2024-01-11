#ifndef BEEHAVE_BLACKBOARD_H
#define BEEHAVE_BLACKBOARD_H

#include <classes/node.hpp>

namespace godot {

class BeehaveBlackboard : public Node
{
    GDCLASS(BeehaveBlackboard, Node);

protected:
    static void _bind_methods();

public:
    BeehaveBlackboard();
    ~BeehaveBlackboard();

    void test();
};

}

#endif // BEEHAVE_BLACKBOARD_H

#ifndef BEEHAVE_TREE_H
#define BEEHAVE_TREE_H

#include <classes/node.hpp>

namespace godot {

class BeehaveTree : public Node
{
    GDCLASS(BeehaveTree, Node);

protected:
    static void _bind_methods();

public:
    BeehaveTree();
    ~BeehaveTree();

    void test();
};

}

#endif // BEEHAVE_TREE_H

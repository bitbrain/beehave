#ifndef BEEHAVE_TREE_NODE_H
#define BEEHAVE_TREE_NODE_H

#include <classes/node.hpp>

namespace godot {

class BeehaveTreeNode : public Node
{
    GDCLASS(BeehaveTreeNode, Node);

protected:
    static void _bind_methods();

public:
    BeehaveTreeNode();
    ~BeehaveTreeNode();

    void test();
};

}

#endif // BEEHAVE_TREE_NODE_H

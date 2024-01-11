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

    enum Status {
        SUCCESS = 0,
        FAILURE = 1,
        RUNNING = 2
    };

    BeehaveTreeNode();
    ~BeehaveTreeNode();

    void test();
};

}

VARIANT_ENUM_CAST(BeehaveTreeNode::Status);

#endif // BEEHAVE_TREE_NODE_H

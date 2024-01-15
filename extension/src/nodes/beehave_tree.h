/**************************************************************************/
/*  beehave_tree.h                                                        */
/**************************************************************************/
/*                         This file is part of:                          */
/*                               BEEHAVE                                  */
/*                      https://bitbra.in/beehave                         */
/**************************************************************************/
/* Copyright (c) 2024-present Beehave Contributors.                       */
/*                                                                        */
/* Permission is hereby granted, free of charge, to any person obtaining  */
/* a copy of this software and associated documentation files (the        */
/* "Software"), to deal in the Software without restriction, including    */
/* without limitation the rights to use, copy, modify, merge, publish,    */
/* distribute, sublicense, and/or sell copies of the Software, and to     */
/* permit persons to whom the Software is furnished to do so, subject to  */
/* the following conditions:                                              */
/*                                                                        */
/* The above copyright notice and this permission notice shall be         */
/* included in all copies or substantial portions of the Software.        */
/*                                                                        */
/* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,        */
/* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF     */
/* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. */
/* IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY   */
/* CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,   */
/* TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE      */
/* SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                 */
/**************************************************************************/

#ifndef BEEHAVE_TREE_H
#define BEEHAVE_TREE_H

#include "beehave_blackboard.h"
#include "beehave_context.h"
#include "beehave_tree_node.h"
#include <classes/node.hpp>

namespace godot {

class BeehaveTree : public Node {
	GDCLASS(BeehaveTree, Node);

public:
	enum ProcessThread {
		IDLE = 0,
		PHYSICS = 1
	};

private:
	int tick_rate;
	bool enabled;
	Node *actor;
	BeehaveBlackboard *blackboard;
	Ref<BeehaveContext> context;
	BeehaveTreeNode::TickStatus tick_status;
	ProcessThread process_thread = ProcessThread::PHYSICS;

	int _last_tick;

	void process_internally(double delta);

protected:
	static void _bind_methods();

public:
	BeehaveTree();
	~BeehaveTree();

	void _ready();
	void _process(double delta);
	void _physics_process(double delta);
	void enable();
	void disable();
	BeehaveTreeNode::TickStatus tick();
};

} //namespace godot

VARIANT_ENUM_CAST(BeehaveTree::ProcessThread);

#endif // BEEHAVE_TREE_H

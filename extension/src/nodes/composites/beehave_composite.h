/**************************************************************************/
/*  beehave_composite.h                                                   */
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

#ifndef BEEHAVE_COMPOSITE_H
#define BEEHAVE_COMPOSITE_H

#include "nodes/beehave_tree_node.h"

namespace godot {

class BeehaveComposite : public BeehaveTreeNode {
	GDCLASS(BeehaveComposite, BeehaveTreeNode);

protected:
	BeehaveTreeNode *running_child;

public:
	BeehaveComposite();
	~BeehaveComposite();

	void after_run(Ref<BeehaveContext> context);

	void interrupt(Ref<BeehaveContext> context);

protected:
	/*
	*Interrupt all children between from_index and to_index (non-inclusive)
	*For example, `interrupt_children(context, 2, 6)` will interrupt children at indices 2, 3, 4 and 5, but not 6
	*/
	void interrupt_children(Ref<BeehaveContext> context, int from_index, int to_index);
};
} //namespace godot

#endif //BEEHAVE_COMPOSITE_H
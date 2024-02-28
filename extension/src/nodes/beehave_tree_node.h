/**************************************************************************/
/*  beehave_tree_node.h                                                   */
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

#ifndef BEEHAVE_TREE_NODE_H
#define BEEHAVE_TREE_NODE_H

#include "beehave_context.h"
#include <classes/node.hpp>
#include <classes/global_constants.hpp>
#include <classes/ref.hpp>
#include <core/binder_common.hpp>
#include <variant/variant.hpp>
#include <core/gdvirtual.gen.inc>


namespace godot {
	class BeehaveTreeNodeEnums : public Node {
		GDCLASS(BeehaveTreeNodeEnums, Node);

	public:
		enum TickStatus {
			PENDING = -1,
			SUCCESS = 0,
			FAILURE = 1,
			RUNNING = 2
		};

	protected:
		static void _bind_methods() {
			BIND_ENUM_CONSTANT(PENDING);
			BIND_ENUM_CONSTANT(SUCCESS);
			BIND_ENUM_CONSTANT(FAILURE);
			BIND_ENUM_CONSTANT(RUNNING);
		}
	};

} //namespace godot


VARIANT_ENUM_CAST(BeehaveTreeNodeEnums::TickStatus);


namespace godot {

class BeehaveTreeNode : public Node {
	GDCLASS(BeehaveTreeNode, Node);

protected:
	static void _bind_methods();

public:
	using TickStatus = BeehaveTreeNodeEnums::TickStatus;

	static const TickStatus PENDING = BeehaveTreeNodeEnums::PENDING;
	static const TickStatus SUCCESS = BeehaveTreeNodeEnums::SUCCESS;
	static const TickStatus FAILURE = BeehaveTreeNodeEnums::FAILURE;
	static const TickStatus RUNNING = BeehaveTreeNodeEnums::RUNNING;

	BeehaveTreeNode();
	~BeehaveTreeNode();

	virtual TickStatus tick(Ref<BeehaveContext> context);

	GDVIRTUAL1RC(TickStatus, _tick, Ref<BeehaveContext>);
};

} //namespace godot

#endif // BEEHAVE_TREE_NODE_H

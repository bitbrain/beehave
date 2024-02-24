/**************************************************************************/
/*  beehave_blackboard.h                                                  */
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

#ifndef BEEHAVE_BLACKBOARD_H
#define BEEHAVE_BLACKBOARD_H

#include <classes/node.hpp>
#include <variant/dictionary.hpp>

namespace godot {

class BeehaveBlackboard : public Node {
	GDCLASS(BeehaveBlackboard, Node);

	Dictionary values = Dictionary();

protected:
	static void _bind_methods();

public:
	BeehaveBlackboard();
	~BeehaveBlackboard();

	void set_value(const String &key, Variant value);
	Variant get_value(const String &key, Variant default_value) const;
	bool has_value(const String &key) const;
	bool erase_value(const String &key);
	int get_size() const;

	Dictionary get_values() const;
	void set_values(Dictionary values);
};

} //namespace godot

#endif // BEEHAVE_BLACKBOARD_H

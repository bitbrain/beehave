/**************************************************************************/
/*  beehave_cooldown.h                                                    */
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

#ifndef BEEHAVE_COOLDOWN_H
#define BEEHAVE_COOLDOWN_H

#include "nodes/decorators/beehave_decorator.h"

namespace godot {

class BeehaveCooldown : public BeehaveDecorator {
	GDCLASS(BeehaveCooldown, BeehaveDecorator);

	float wait_time;
	double passed_time;

protected:
	static void _bind_methods();

public:
	BeehaveCooldown();
	~BeehaveCooldown();

	void set_wait_time(float wait_time);
	float get_wait_time() const;

	BeehaveTickStatus tick(Ref<BeehaveContext> context);

};

}

#endif//BEEHAVE_COOLDOWN_H
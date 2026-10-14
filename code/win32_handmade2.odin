package main

import "core:fmt"
import win "core:sys/windows"

// On windows WinMain is used for application entry point.
// When using and compiling with C, the C runtime library will call WinMain function.
// C runtime library is not part of the windows(not in the OS) but it is the part of standard library that everyone
// has to support when they ship C compiler
main :: proc() {
	// TODO: learn more about bitwise operators
	win.MessageBoxW(nil, "This is test message", "This is test caption", win.MB_OK|win.MB_ICONINFORMATION)
}

package main

import "base:runtime"
import "core:fmt"
import win "core:sys/windows"

// window - A handle to a window. It is a opaque piece of data that can be passed back to a windows that allows it to know which window we are talking about.
// message - The message that windows is asking us to handle. The windows uses these messages to control the operations of applications and to provide input and other information for applications to process.
// w_param -
// l_param -
Wndproc :: proc "stdcall" (
	window: win.HWND,
	message: u32,
	w_param: uintptr,
	l_param: int,
) -> win.LRESULT {
	context = runtime.default_context()
	result: win.LRESULT = 0

	switch (message) {
	// When window size is changed
	case win.WM_SIZE:
		fmt.println("WM_SIZE")

		break
	// When windows deletes the window
	case win.WM_DESTROY:
		fmt.println("WM_DESTROY")

		break
	// When window is terminated
	case win.WM_CLOSE:
		fmt.println("WM_CLOSE")

		break
	// When window is being activated(when user switched to this window)
	case win.WM_ACTIVATEAPP:
		fmt.println("WM_ACTIVATEAPP")

		break
	case:
		fmt.println("default")

		// DefWindowProcW - Calls the default windows procedure to provide default processing for any window messages that the application does not process.
		result = win.DefWindowProcW(window, message, w_param, l_param)

		break
	}

	return result
}

// On windows WinMain is used for application entry point.
// When using and compiling with C, the C runtime library will call WinMain function.
// C runtime library is not part of the windows(not in the OS) but it is the part of standard library that everyone
// has to support when they ship C compiler
main :: proc() {
	// TODO: learn more about bitwise operators

	instance: win.HINSTANCE = win.HANDLE(win.GetModuleHandleW(nil))

	// WNDCLASS is a standard C structure used in the Win32 API to define the properties of a window before it is created.
	// Initializing like this will set everything to zero
	window_class := win.WNDCLASSW{}

	// The style is the set of binary flags(bit field) that are properties that we want our window to have.
	// CS_OWNDC - Allocates a unique device context for each window in the class.
	// CS_HREDRAW - Redraws the entire window if a movement or size adjustment changes the width of the client area.
	// CS_VREDRAW - Redraws the entire window if a movement or size adjustment changes the height of the client area.
	window_class.style = win.CS_OWNDC | win.CS_HREDRAW | win.CS_VREDRAW

	// lpfnWndProc is a pointer to a function and it defines how window responds to events.
	window_class.lpfnWndProc = Wndproc

	// A handle to the instance that contains the windows procedure for the class.
	// NOTE: because main method doesn't get hInstance like in the c, use GetModuleHandleEx function to retrieve a module handle for the specified module.
	window_class.hInstance = instance

	// A handle for the window class
	window_class.lpszClassName = "Handmade Hero with Odin"

	// Registers a window class for subsequent use in calls to the CreateWindow or CreateWindowEx function
	win.RegisterClassW(&window_class)

	// Creates an overlapped, pop-up, or child window with an extended window style.
	// dwStyle - The style of the window being created.
	window_handle: win.HWND = win.CreateWindowExW(
		0,
		window_class.lpszClassName,
		"Handmade Hero with Odin",
		win.WS_OVERLAPPEDWINDOW | win.WS_VISIBLE,
		win.CW_USEDEFAULT,
		win.CW_USEDEFAULT,
		win.CW_USEDEFAULT,
		win.CW_USEDEFAULT,
		nil,
		nil,
		instance,
		nil,
	)

	if (window_handle != nil) {

	}

}

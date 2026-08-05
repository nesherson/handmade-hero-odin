package main

import "base:runtime"
import "core:fmt"
import win "core:sys/windows"

running: bool;

WNDPROC :: proc "stdcall" (window: win.HWND, message: u32, w_param: uintptr, l_param: int) -> int {
	context = runtime.default_context()

	result: win.LRESULT = 0

	switch message {
	case win.WM_SIZE:
		fmt.println("WM_SIZE")
		break
	case win.WM_CLOSE:
		running = false;
		break
	case win.WM_DESTROY:
		running = false;
		break
	case win.WM_ACTIVATEAPP:
		fmt.println("WM_SIZE")
		break
	case win.WM_PAINT:
		paint: win.PAINTSTRUCT = {}
		device_context: win.HDC = win.BeginPaint(window, &paint)
		x: i32 = paint.rcPaint.left
		y: i32 = paint.rcPaint.top
		width: i32 = paint.rcPaint.right - paint.rcPaint.left
		height: i32 = paint.rcPaint.bottom - paint.rcPaint.top
		@(static) operation: win.DWORD = win.WHITENESS
		win.PatBlt(device_context, 0, 0, width, height, operation)

		if operation == win.WHITENESS {
			operation = win.BLACKNESS
		} else {
			operation = win.WHITENESS
		}

		win.EndPaint(window, &paint)
		break
	case:
		fmt.println("default")

		result = win.DefWindowProcW(window, message, w_param, l_param)

		break
	}

	return result
}

main :: proc() {
	instance: win.HINSTANCE = win.HANDLE(win.GetModuleHandleW(nil))

	window_class := win.WNDCLASSW {
		style         = win.CS_OWNDC | win.CS_HREDRAW | win.CS_VREDRAW,
		lpfnWndProc   = WNDPROC,
		hInstance     = instance,
		lpszClassName = "Handmade Hero with Odin",
	}

	win.RegisterClassW(&window_class)

	window_handle: win.HWND = win.CreateWindowExW(
		0,
		window_class.lpszClassName,
		"Handmade Hero",
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

	if window_handle != nil {
		message: win.MSG

		running = true

		for running {
			if win.GetMessageW(&message, nil, 0, 0) > 0 {
				win.TranslateMessage(&message)
				win.DispatchMessageW(&message)
			} else {
				break
			}
		}
	}
}

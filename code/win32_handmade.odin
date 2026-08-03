package main

import "base:runtime"
import "core:fmt"
import win "core:sys/windows"

WNDPROC :: proc "stdcall" (window: win.HWND, message: u32, w_param: uintptr, l_param: int) -> int {
	context = runtime.default_context()


	switch message {
	case win.WM_SIZE:
		fmt.println("WM_SIZE")
		break
	case win.WM_DESTROY:
		fmt.println("WM_SIZE")
		break
	case win.WM_ACTIVATEAPP:
		fmt.println("WM_SIZE")
		break
	case:
		fmt.println("default")
		break
	}


	return 0
}

main :: proc() {
	window_class := win.WNDCLASSW {
		style         = win.CS_OWNDC | win.CS_HREDRAW | win.CS_VREDRAW,
		lpfnWndProc   = WNDPROC,
		hInstance     = win.HANDLE(win.GetModuleHandleW(nil)),
		lpszClassName = "Handmade Hero with Odin",
	}
}

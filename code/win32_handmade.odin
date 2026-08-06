package main

import "base:runtime"
import "core:fmt"
import win "core:sys/windows"

running: bool
bitmap_info: win.BITMAPINFO = {}
bitmap_memory: ^win.PVOID
bitmap_handle: win.HBITMAP

win32_resize_dib_section :: proc(width: i32, height: i32) {
	if bitmap_handle != nil {
		win.DeleteObject(bitmap_handle)
	}
	bitmap_info.bmiHeader.biSize = size_of(bitmap_info.bmiHeader)
	bitmap_info.bmiHeader.biWidth = width
	bitmap_info.bmiHeader.biHeight = height
	bitmap_info.bmiHeader.biPlanes = 1
	bitmap_info.bmiHeader.biBitCount = 32
	bitmap_info.bmiHeader.biCompression = win.BI_RGB
	bitmap_info.bmiHeader.biSizeImage = 0
	bitmap_info.bmiHeader.biXPelsPerMeter = 0
	bitmap_info.bmiHeader.biYPelsPerMeter = 0
	bitmap_info.bmiHeader.biClrUsed = 0
	bitmap_info.bmiHeader.biClrImportant = 0

	device_context: win.HDC = win.CreateCompatibleDC(0)
	bitmap_handle = win.CreateDIBSection(
		device_context,
		&bitmap_info,
		win.DIB_RGB_COLORS,
		&bitmap_memory,
		nil,
		0
	)

	win.ReleaseDC(device_context)
}

win32_update_window :: proc(device_context: win.HDC, x: i32, y: i32, width: i32, height: i32) {
	win.StretchDIBits(device_context,
		x, y, width, y,
	 	x, y, width, y,
		nil, nil,
		win.DIB_RGB_COLORS, win.SRCCOPY)
}

WNDPROC :: proc "stdcall" (window: win.HWND, message: u32, w_param: uintptr, l_param: int) -> int {
	context = runtime.default_context()

	result: win.LRESULT = 0

	switch message {
	case win.WM_SIZE:
		client_rect: win.RECT = {}

		win.GetClientRect(window, &client_rect)

		width: i32 = client_rect.right - client_rect.left
		height: i32 = client_rect.bottom - client_rect.top

		win32_resize_dib_section(width, height)

		break
	case win.WM_CLOSE:
		running = false
		break
	case win.WM_DESTROY:
		running = false
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

		win32_update_window(device_context, x, y, width, height)
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

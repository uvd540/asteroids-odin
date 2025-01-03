/*
This file implements logger and temp allocator for the web build. The logger
is based on the one found here: https://github.com/Aronicu/Raylib-WASM/tree/main
*/

#+build wasm32, wasm64p32

package raylib_wasm

import "base:runtime"
import "core:c"
import "core:fmt"
import "core:log"
import "core:strings"
import "core:mem"
import rl "vendor:raylib"


// WASM logger

WASM_Logger_Opts :: log.Options{.Level, .Short_File_Path, .Line}

create_wasm_logger :: proc (lowest := log.Level.Debug, opt := WASM_Logger_Opts) -> log.Logger {
	return log.Logger{data = nil, procedure = wasm_logger_proc, lowest_level = lowest, options = opt}
}

@(private="file")
wasm_logger_proc :: proc(
	logger_data: rawptr,
	level: log.Level,
	text: string,
	options: log.Options,
	location := #caller_location
) {
	b := strings.builder_make(context.temp_allocator)
	strings.write_string(&b, Wasm_Logger_Level_Headers[level])
	do_location_header(options, &b, location)
	fmt.sbprint(&b, text)
	puts(strings.to_cstring(&b))
}

@(private="file")
Wasm_Logger_Level_Headers := [?]string {
	0 ..< 10 = "[DEBUG] --- ",
	10 ..< 20 = "[INFO ] --- ",
	20 ..< 30 = "[WARN ] --- ",
	30 ..< 40 = "[ERROR] --- ",
	40 ..< 50 = "[FATAL] --- ",
}

@(private="file")
do_location_header :: proc(opts: log.Options, buf: ^strings.Builder, location := #caller_location) {
	if log.Location_Header_Opts & opts == nil {
		return
	}
	fmt.sbprint(buf, "[")
	file := location.file_path
	if .Short_File_Path in opts {
		last := 0
		for r, i in location.file_path {
			if r == '/' {
				last = i + 1
			}
		}
		file = location.file_path[last:]
	}

	if log.Location_File_Opts & opts != nil {
		fmt.sbprint(buf, file)
	}
	if .Line in opts {
		if log.Location_File_Opts & opts != nil {
			fmt.sbprint(buf, ":")
		}
		fmt.sbprint(buf, location.line)
	}

	if .Procedure in opts {
		if (log.Location_File_Opts | {.Line}) & opts != nil {
			fmt.sbprint(buf, ":")
		}
		fmt.sbprintf(buf, "%s()", location.procedure)
	}

	fmt.sbprint(buf, "] ")
}

@(default_calling_convention = "c")
foreign {
	puts :: proc(buffer: cstring) -> c.int ---
}

// Allocator

web_allocator :: proc "contextless" () -> mem.Allocator {
	return mem.Allocator{web_allocator_proc, nil}
}

web_allocator_proc :: proc(
	allocator_data: rawptr,
	mode: mem.Allocator_Mode,
	size, alignment: int,
	old_memory: rawptr,
	old_size: int,
	location := #caller_location
) -> (data: []byte, err: mem.Allocator_Error)  {
	// These aligned alloc procs are almost indentical those in
	// `_heap_allocator_proc` in `core:os`. Without the proper alignment you
	// cannot use maps and simd features.

	aligned_alloc :: proc(size, alignment: int, zero_memory: bool, old_ptr: rawptr = nil) -> ([]byte, mem.Allocator_Error) {
		a := max(alignment, align_of(rawptr))
		space := size + a - 1

		allocated_mem: rawptr
		if old_ptr != nil {
			original_old_ptr := mem.ptr_offset((^rawptr)(old_ptr), -1)^
			allocated_mem = rl.MemRealloc(original_old_ptr, u32(space+size_of(rawptr)))
		} else {
			allocated_mem = rl.MemAlloc(u32(space+size_of(rawptr)))
		}
		aligned_mem := rawptr(mem.ptr_offset((^u8)(allocated_mem), size_of(rawptr)))

		ptr := uintptr(aligned_mem)
		aligned_ptr := (ptr - 1 + uintptr(a)) & -uintptr(a)
		diff := int(aligned_ptr - ptr)
		if (size + diff) > space || allocated_mem == nil {
			return nil, .Out_Of_Memory
		}

		aligned_mem = rawptr(aligned_ptr)
		mem.ptr_offset((^rawptr)(aligned_mem), -1)^ = allocated_mem

		return mem.byte_slice(aligned_mem, size), nil
	}

	aligned_free :: proc(p: rawptr) {
		if p != nil {
			rl.MemFree(mem.ptr_offset((^rawptr)(p), -1)^)
		}
	}

	aligned_resize :: proc(p: rawptr, old_size: int, new_size: int, new_alignment: int) -> ([]byte, mem.Allocator_Error) {
		if p == nil {
			return nil, nil
		}
		return aligned_alloc(new_size, new_alignment, true, p)
	}

	switch mode {
	case .Alloc:
		return aligned_alloc(size, alignment, true)

	case .Alloc_Non_Zeroed:
		return aligned_alloc(size, alignment, false)

	case .Free:
		aligned_free(old_memory)
		return nil, nil
	
	case .Resize, .Resize_Non_Zeroed:
		if old_memory == nil {
			return aligned_alloc(size, alignment, true)
		}
		return aligned_resize(old_memory, old_size, size, alignment)

	case .Query_Features:
		set := (^mem.Allocator_Mode_Set)(old_memory)
		if set != nil {
			set^ = {.Alloc, .Free, .Resize, .Query_Features}
		}
		return nil, nil

	case .Free_All, .Query_Info:
		return nil, .Mode_Not_Implemented
	}
	return nil, .Mode_Not_Implemented
}


// Temp Allocator
// More or less a copy from base:runtime (that one is disabled in freestanding
// build mode).

WASM_Temp_Allocator :: struct {
	arena: runtime.Arena,
}

wasm_temp_allocator_init :: proc(s: ^WASM_Temp_Allocator, size: int, backing_allocator := context.allocator) {
	_ = runtime.arena_init(&s.arena, uint(size), backing_allocator)
}

wasm_temp_allocator_proc :: proc(
	allocator_data: rawptr,
	mode: runtime.Allocator_Mode,
	size, alignment: int,
	old_memory: rawptr,
	old_size: int,
	loc := #caller_location) -> (data: []byte, err: runtime.Allocator_Error) {
	s := (^WASM_Temp_Allocator)(allocator_data)
	return runtime.arena_allocator_proc(&s.arena, mode, size, alignment, old_memory, old_size, loc)
}

wasm_temp_allocator :: proc(allocator: ^WASM_Temp_Allocator) -> runtime.Allocator {
	return runtime.Allocator{
		procedure = wasm_temp_allocator_proc,
		data      = allocator,
	}
}
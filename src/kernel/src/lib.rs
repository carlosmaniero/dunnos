#![no_std]
#![no_main]

use core::panic::PanicInfo;

static HELLO: &[u8] = b"Welcome to DunnOS! With Rust and love!";
static VGA_ROWS: u16 = 80;
static VGA_LINES: u16 = 25;

#[no_mangle]
fn write_char(the_char: u8, color: u8, pos_x: u16, pos_y: u16) {
    let vga_buffer = 0xb8000 as *mut u8;

    unsafe {
        *vga_buffer.offset((pos_x + pos_y * VGA_ROWS) as isize * 2) = the_char;
        *vga_buffer.offset((pos_x + pos_y * VGA_ROWS) as isize * 2 + 1) = color;
    }
}

#[no_mangle]
fn screen_clear() {
    for line in 0..VGA_LINES {
        for row in 0..VGA_ROWS {
            write_char(' ' as u8, 0x02, row, line)
        }
    }
}

#[no_mangle]
pub extern "C" fn kmain() -> ! {
    screen_clear();
    let x_base = (VGA_ROWS - HELLO.len() as u16) / 2;

    for (i, &byte) in HELLO.iter().enumerate() {
        write_char(byte, 0x02, x_base + i as u16, 11)
    }

    loop {}
}

/// This function is called on panic.
#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    loop {}
}

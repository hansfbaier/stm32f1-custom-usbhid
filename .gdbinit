define flags
if (($xpsr >> 31) & 1 )
printf "N "
else
printf "n "
end
if (($xpsr >> 30) & 1 )
printf "Z "
else
printf "z "
end
if (($xpsr >> 29) & 1 )
printf "C "
else
printf "c "
end
if (($xpsr >> 28) & 1 )
printf "V "
else
printf "V "
end
if (($xpsr >> 9) & 1 )
printf "E "
else
printf "e "
end
if (($xpsr >> 7) & 1 )
printf "I "
else
printf "i "
end
if (($xpsr >> 6) & 1 )
printf "F "
else
printf "f "
end
if (($xpsr >> 5) & 1 )
printf "T "
else
printf "t "
end
printf "\n"
end
document flags
Print flags register
end

define ascii_char
set $_c=*(unsigned char *)($arg0)
if ( $_c < 0x20 || $_c > 0x7E )
printf "."
else
printf "%c", $_c
end
end
document ascii_char
Print the ASCII value of arg0 or '.' if value is unprintable
end

set $LITTLE_ENDIAN = 0

define hex_quad
if $LITTLE_ENDIAN
printf "%02x %02x %02x %02x  %02x %02x %02x %02x",                          \
               *(unsigned char*)($arg0), *(unsigned char*)($arg0 + 1),      \
               *(unsigned char*)($arg0 + 2), *(unsigned char*)($arg0 + 3),  \
               *(unsigned char*)($arg0 + 4), *(unsigned char*)($arg0 + 5),  \
               *(unsigned char*)($arg0 + 6), *(unsigned char*)($arg0 + 7)
else
printf "%02x%02x%02x%02x  %02x%02x%02x%02x",                          \
               *(unsigned char*)($arg0 + 3), *(unsigned char*)($arg0 + 2),      \
               *(unsigned char*)($arg0 + 1), *(unsigned char*)($arg0 + 0),  \
               *(unsigned char*)($arg0 + 7), *(unsigned char*)($arg0 + 6),  \
               *(unsigned char*)($arg0 + 5), *(unsigned char*)($arg0 + 4)
end
end
document hex_quad
Print eight hexadecimal bytes starting at arg0
end

define hexdump
printf "%08x : ", $arg0
hex_quad $arg0
printf " - "
hex_quad ($arg0+8)
printf " "

ascii_char ($arg0)
ascii_char ($arg0+1)
ascii_char ($arg0+2)
ascii_char ($arg0+3)
ascii_char ($arg0+4)
ascii_char ($arg0+5)
ascii_char ($arg0+6)
ascii_char ($arg0+7)
ascii_char ($arg0+8)
ascii_char ($arg0+9)
ascii_char ($arg0+0xA)
ascii_char ($arg0+0xB)
ascii_char ($arg0+0xC)
ascii_char ($arg0+0xD)
ascii_char ($arg0+0xE)
ascii_char ($arg0+0xF)

printf "\n"
end
document hexdump
Display a 16-byte hex/ASCII dump of arg0
end

define reg
printf "     r0:%08x r1:%08x  r2:%08x  r3:%08x ",  $r0, $r1, $r2, $r3
printf "     msp:%08x psp:%08x\n", $msp, $psp
printf "     r4:%08x r5:%08x  r6:%08x  r7:%08x ",  $r4, $r5, $r6, $r7
printf "      lr:%08x\n", $lr
printf "     r8:%08x r9:%08x r10:%08x ",  $r8, $r9, $r10
printf "r11:%08x     xpsr:%08x\n",  $r11, $xpsr
printf "                                          r12:%08x     ",  $r12
flags
end
document reg
Print CPU registers
end

define code
printf "[%08x]------------------------", $pc
printf "---------------------------------[ code]\n"
x /6i $pc
printf "---------------------------------------"
printf "---------------------------------------\n"
end
document code
show current code location
end

define code-on
set $SHOW_CODE = 1
end
define code-off
set $SHOW_CODE = 0
end

define context
if $SHOW_CONTEXT
if $SHOW_CODE
code
else
x /1i $pc
end
printf "_______________________________________"
printf "______________________________________________\n"
reg

printf "[%08x]------------------------", $sp
printf "--------------------------------------------[stack]\n"
hexdump $sp
hexdump $sp+0x10
hexdump $sp+0x20
hexdump $sp+0x30
end
end
document context
Print regs, stack, and disassemble pc
end

define context-on
set $SHOW_CONTEXT = 1
end
document context-on
Enable display of context on every program stop
end

define context-off
set $SHOW_CONTEXT = 1
end
document context-on
Disable display of context on every program stop
end

# Calls "context" at every breakpoint.
define hook-stop
  context
end

file main.elf
target extended-remote /dev/ttyACM0
monitor swdp_scan
attach 1
context-on

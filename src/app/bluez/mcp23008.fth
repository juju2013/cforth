\ Interface to MCP23008 I2C GPIO expander

\needs read-i2c  fload i2c.fth

$24 value mcp8-i2c-slave
: select-mcp8  ( 0..3 -- )  $24 + to mcp8-i2c-slave  ;

4 buffer: mcp8-buf
: mcp8-reg-setup  ( reg# -- )  mcp8-i2c-slave set-i2c-slave  mcp8-buf c!  ;
: mcp8-b@  ( reg# -- b )
   mcp8-reg-setup
   mcp8-buf 1 write-i2c
   mcp8-buf 1 read-i2c  mcp8-buf c@
;
: mcp8-b!  ( b reg# -- )
   mcp8-reg-setup       ( b )
   mcp8-buf 1+ c!       ( )
   mcp8-buf 2 write-i2c
;

: mcp8-set  ( gpio# reg# -- )
   >r  1 swap lshift   r@ mcp8-b@  or  r> mcp8-b!
;
: mcp8-clr  ( gpio# reg# -- )
   >r  1 swap lshift invert  r@ mcp8-b@  and  r> mcp8-b!
;
: mcp8-gpio-is-output  ( gpio# -- )  0 mcp8-clr  ;
: mcp8-gpio-is-input  ( gpio# -- )  0 mcp8-set  ;
: mcp8-gpio-pullup-off  ( gpio# -- )  6 mcp8-clr  ;
: mcp8-gpio-pullup-on  ( gpio# -- )  6 mcp8-set  ;
: mcp8-gpio-clr  ( gpio# -- )  9 mcp8-clr  ;
: mcp8-gpio-set  ( gpio# -- )  9 mcp8-set  ;
: mcp8-gpio-pin@  ( gpio# -- flag )  1 swap lshift  9 mcp8-b@  and  0<>  ;

# Log uploader

A small Toit program that uploads the log of one or more devices
  to a Supabase instance.

The ESP32 that runs this program is connected through UART to one or more
  devices, and listens for their UART0 output.

All received output is uploaded.

## Setup
Create a new Supabase project, and link it to this repository by
running `supabase link --project-ref <project-ref>`. You will need
the master password to do this.

Then run `supabase db push` to create the tables.

In the supabase dashboard add a new device (any UUID will do). That
UUID is fundamentally the password for the device.

Take the `esp32-example.toit` file and copy/rename it to
`esp32.toit` (or `esp32_*.toit` if you want more than one).

Edit it and set the `SUPABASE_PROJECT`, `SUPABASE_ANON`, `DEVICE_ID`, and
  `PIN_RX1`/`PIN_RX2` variables. The second RX can be null.

Flash the program. It will then upload any data that it receives on the
serial port.

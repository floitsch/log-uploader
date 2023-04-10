// Copyright (C) 2023 Florian Loitsch
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import .main as real_main

SUPABASE_PROJECT ::= "<YOUR PROJECT REF>"
SUPABASE_ANON ::= "<YOUR ANON KEY>"

// The device id is used to identify the device in the database.
// A simple approach for multiple devices is to have different esp32-files.
DEVICE_ID ::= "<YOUR DEVICE ID>"

PIN_RX1 ::= null // YOUR PIN.
PIN_RX2 ::= null // YOUR PIN.

main:
  real_main.main
      --supabase_project=SUPABASE_PROJECT
      --supabase_anon=SUPABASE_ANON
      --device_id=DEVICE_ID
      --pin_rx1=PIN_RX1
      --pin_rx2=PIN_RX2

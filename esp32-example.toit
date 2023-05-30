// Copyright (C) 2023 Florian Loitsch
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import .main as real_main

SUPABASE_PROJECT ::= "<YOUR PROJECT REF>"
SUPABASE_ANON ::= "<YOUR ANON KEY>"

PIN_RX1 ::= null // YOUR PIN.
PIN_RX2 ::= null // YOUR PIN.

main:
  real_main.main
      --supabase_project=SUPABASE_PROJECT
      --supabase_anon=SUPABASE_ANON
      --pin_rx1=PIN_RX1
      --pin_rx2=PIN_RX2

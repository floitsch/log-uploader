// Copyright (C) 2023 Florian Loitsch
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import certificate_roots
import gpio
import monitor
import uart
import supabase

// After 5s offload the data. Even if the device is not quiet.
MAX_OFFLOAD_DELAY ::= Duration --s=5
// Offload if we accumulate more than 2kb of data.
MAX_BUFFERED_DATA ::= 2000
// Offload if we have not received any data for 500ms.
MAX_QUIET_FOR_OFFLOAD ::= Duration --ms=500

LOGS_TABLE ::= "logs"

class LogForwarder:
  pin_/gpio.Pin
  port_/uart.Port

  constructor pin_number/int:
    pin_ = gpio.Pin pin_number
    port_ = uart.Port --rx=pin_ --tx=null --baud_rate=115200

  listen [block]:
    chunks := []
    total_size := 0

    offload := :
      total := ByteArray total_size
      offset := 0
      chunks.do:
        total.replace offset it
        offset += it.size
      block.call total.to_string_non_throwing
      chunks.clear
      total_size = 0

    last_offload := Time.now
    while true:
      exception := catch:
        // Try to offload
        with_timeout --ms=500:
          chunk := port_.read
          print "received: $chunk.to_string_non_throwing"
          chunks.add chunk
          total_size += chunks.last.size
          if total_size > 1000:
            offload.call
          else if (Duration.since last_offload) > MAX_OFFLOAD_DELAY:
            offload.call

      if exception == DEADLINE_EXCEEDED_ERROR:
        if chunks.size > 0:
          offload.call

main
    --supabase_project/string
    --supabase_anon/string
    --device_id/string
    --pin_rx1/int
    --pin_rx2/int?:

  client/supabase.Client? := null

  while true:
    catch --trace:
      client = supabase.Client.tls
          --host="$(supabase_project).supabase.co"
          --anon=supabase_anon
          --root_certificates=[certificate_roots.BALTIMORE_CYBERTRUST_ROOT]

      print (client.rest.select LOGS_TABLE)
      mutex := monitor.Mutex

      offload := :: | uart_pin/int data/string |
        mutex.do:
          client.rest.insert --no-return_inserted LOGS_TABLE {
            "device_id": device_id,
            "uart_pin": uart_pin,
            "data": data,
          }

      if pin_rx2:
        task::
          forwarder := LogForwarder pin_rx2
          forwarder.listen: | data/string |
            offload.call pin_rx2 data

      forwarder := LogForwarder pin_rx1
      forwarder.listen: | data/string |
        offload.call pin_rx1 data

    client.close

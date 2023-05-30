-- Copyright (C) 2023 Florian Loitsch. All rights reserved.
-- Use of this source code is governed by a MIT-style license that can be found
-- in the LICENSE file.

-- We use a table of device-ids to keep track of the devices that are
-- allowed to send logs to us.
-- Fundamentally we use the device-id as authentication token, since we
-- don't have any other restriction on the log table.

CREATE TABLE public.devices (
    id uuid PRIMARY KEY,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    description text
);

ALTER TABLE public.devices ENABLE ROW LEVEL SECURITY;

CREATE POLICY "auth has full access" ON public.devices
    FOR ALL
    TO authenticated
    USING (true)
    WITH CHECK (true);

CREATE TABLE public.logs (
    id SERIAL PRIMARY KEY,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    uart_pin integer NOT NULL,
    device_id uuid NOT NULL REFERENCES public.devices(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    data text NOT NULL
);

ALTER TABLE public.logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "auth has full access" ON public.logs
    FOR ALL
    TO authenticated
    USING (true)
    WITH CHECK (true);

CREATE POLICY "anyone can insert"
    ON public.logs
    FOR INSERT
    TO anon
    WITH CHECK (true);

-- Add an index on the logs table, so time-based queries are fast.
CREATE INDEX logs_created_at_idx ON public.logs (created_at, device_id);

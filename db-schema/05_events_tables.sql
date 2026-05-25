--
-- Events Tables
-- This file contains all tables from the events schema
--

CREATE TABLE events.comm_logs (
    id bigint NOT NULL,
    profile_id character varying NOT NULL,
    channel smallint NOT NULL,
    event character varying NOT NULL,
    param character varying,
    created timestamp without time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    brand_id smallint NOT NULL,
    error jsonb,
    introduction_id character varying
);

-- Row direction follows scoring session (e.g. suggestion user→partner), which may differ from
-- introductions.initiator_profile_id / responder_profile_id for the same pair. Backoffice aligns reads.
CREATE TABLE events.match_scores (
    initiator_profile_id uuid NOT NULL,
    responder_profile_id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    initiator_bio_score smallint,
    responder_bio_score smallint,
    predictor_score smallint,
    deal_breaker_reason jsonb,
    error character varying,
    is_deal_breaker smallint DEFAULT 0 NOT NULL,
    initiator_dealbrakers_count smallint DEFAULT 0,
    responder_dealbrakers_count smallint DEFAULT 0
);

CREATE TABLE events.profile_events (
    profile_id uuid NOT NULL,
    categories_clicks json
);

CREATE TABLE events.usage_events (
    id bigint NOT NULL,
    profile_id uuid NOT NULL,
    type character varying NOT NULL,
    count bigint DEFAULT 1 NOT NULL
); 
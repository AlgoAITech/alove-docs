--
-- Introductions and Matching Tables
-- This file contains introduction and matching related tables
--

CREATE TABLE public.introduction_history (
    introduction_history_id bigint NOT NULL,
    introduction_id bigint NOT NULL,
    status_id smallint NOT NULL,
    created timestamp without time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    event_uid uuid
);

CREATE TABLE public.groups (
    id bigint NOT NULL,
    name character varying NOT NULL,
    description character varying,
    type smallint DEFAULT 0 NOT NULL,
    created timestamp without time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    status_id smallint DEFAULT 0 NOT NULL,
    brand_id smallint NOT NULL
);

COMMENT ON COLUMN public.groups.type IS '0 = Inclusive
1 = Exclusive';

CREATE TABLE public.batch_distribution (
    id bigint NOT NULL,
    batch_id bigint NOT NULL,
    is_controlgroup boolean NOT NULL,
    weight numeric(5,4) NOT NULL,
    batch_type_id smallint NOT NULL
);

CREATE TABLE public.batch_languages (
    batch_id bigint NOT NULL,
    language_id character varying(5),
    created timestamp without time zone DEFAULT timezone('utc'::text, now()),
    created_by integer
);

CREATE TABLE public.batch_question_adjustments (
    batch_id bigint NOT NULL,
    question_id bigint NOT NULL,
    response_id bigint NOT NULL,
    score numeric
);

CREATE TABLE public.batch_question_segments (
    batch_id bigint NOT NULL,
    question_id bigint NOT NULL,
    segment_id integer NOT NULL,
    is_visible boolean NOT NULL
);

CREATE TABLE public.batch_triggers (
    id bigint NOT NULL,
    batch_id bigint NOT NULL,
    type smallint,
    ordinal smallint DEFAULT 0
);

CREATE TABLE public.tag_rules (
    id bigint NOT NULL,
    name character varying NOT NULL,
    description character varying,
    condition jsonb,
    status_id smallint DEFAULT 0 NOT NULL,
    tagged_expiration_days smallint,
    created character varying DEFAULT now() NOT NULL,
    updated character varying DEFAULT now(),
    brand_id smallint NOT NULL,
    key character varying NOT NULL,
    profile_statuses jsonb NOT NULL,
    invert boolean,
    operator character varying NOT NULL,
    -- Dynamic (AI-generated/admin-authored SQL) rule config + run state; a rule is dynamic
    -- when dynamic_config->>'rawQuery' is present, otherwise the legacy `condition` column
    -- drives it. See docs/dynamic-tag-rules-plan.md in the meta-repo.
    dynamic_config jsonb
); 
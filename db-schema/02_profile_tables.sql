--
-- Profile Tables
-- This file contains all profile-related tables and their dependencies
--

CREATE TABLE public.profile_attributes (
    id bigint NOT NULL,
    name character varying NOT NULL,
    default_policy integer DEFAULT 1 NOT NULL,
    attribute_group character varying,
    is_sensitive boolean DEFAULT false NOT NULL,
    created timestamp without time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    created_by integer,
    updated timestamp without time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_by integer,
    txt_id character varying,
    editing_question_id bigint,
    user_editable boolean DEFAULT false NOT NULL,
    asset_id character varying,
    sensitive_alternative_exp character varying,
    attribute_category character varying,
    ordinal smallint DEFAULT 0 NOT NULL,
    extended_info_txt_id character varying,
    pre_validation jsonb,
    user_toggleable boolean DEFAULT false NOT NULL,
    related_batch_id smallint,
    is_featured boolean,
    brand_id smallint NOT NULL,
    collapsed boolean,
    settings jsonb,
    ai_category character varying,
    ai_title character varying
);

COMMENT ON COLUMN public.profile_attributes.default_policy IS '1=public,2=private,3=semi,4=hidden';

CREATE TABLE public.profile_assets (
    asset_id bigint NOT NULL,
    profile_id uuid NOT NULL,
    created timestamp without time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated timestamp without time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    asset_type_id smallint NOT NULL,
    uri character varying,
    validation_status_id smallint DEFAULT 1 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    upload_etag character varying NOT NULL,
    ordinal smallint,
    asset_status_id integer,
    moderation_result jsonb,
    brand_id smallint
);

COMMENT ON COLUMN public.profile_assets.validation_status_id IS '1=pending validation, 2=validation failed, 3=validated successfully';

CREATE TABLE public.profile_cards (
    id integer NOT NULL,
    profile_id uuid NOT NULL,
    brand character varying NOT NULL,
    last4digits character varying NOT NULL,
    exp_month smallint NOT NULL,
    exp_year smallint NOT NULL,
    holder_name character varying NOT NULL,
    stripe_payment_method_id character varying NOT NULL,
    created timestamp without time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE public.profile_deletion_requests (
    request_id bigint NOT NULL,
    profile_id uuid NOT NULL,
    created timestamp without time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    deletion_reason_id smallint NOT NULL,
    executed_at timestamp without time zone,
    is_cancelled boolean DEFAULT false NOT NULL,
    comment character varying(100)
);

CREATE TABLE public.profile_external_info (
    profile_id uuid NOT NULL,
    created timestamp without time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated timestamp without time zone DEFAULT timezone('utc'::text, now()),
    attribute_name character varying(100) NOT NULL,
    attribute_value text,
    source character varying NOT NULL
);

CREATE TABLE public.profile_lora_messages (
    id integer NOT NULL,
    profile_id uuid NOT NULL,
    from_lora boolean DEFAULT true NOT NULL,
    content jsonb,
    type smallint NOT NULL,
    created timestamp without time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    replyto integer,
    introduction_id integer,
    text character varying
);

CREATE TABLE public.profile_reminders (
    id bigint NOT NULL,
    profile_id character varying NOT NULL,
    type character varying NOT NULL,
    created timestamp without time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    brand_id smallint NOT NULL,
    introduction_id character varying
);

CREATE TABLE public.profile_reports (
    profile_report_id bigint NOT NULL,
    profile_id uuid NOT NULL,
    reported_by uuid NOT NULL,
    reason_id smallint NOT NULL,
    comment character varying,
    created timestamp without time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    ticket_id bigint
);

CREATE TABLE public.profile_sessions (
    profile_id uuid NOT NULL,
    is_online boolean NOT NULL,
    last_ping timestamp without time zone NOT NULL,
    login_at timestamp without time zone,
    logged_out_at timestamp without time zone,
    platfrom_version character varying,
    platform jsonb,
    brand_id smallint DEFAULT 102 NOT NULL
);

CREATE TABLE public.profile_status_history (
    id integer NOT NULL,
    profile_id uuid NOT NULL,
    old_status_id integer,
    new_status_id integer,
    changed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    reason text
);

CREATE TABLE public.profile_tokens_history (
    id integer NOT NULL,
    profile_id uuid NOT NULL,
    token_amout numeric NOT NULL,
    goods numeric,
    units character varying,
    type character varying NOT NULL,
    partner_name character varying,
    created timestamp without time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    partner_id character varying
);

CREATE TABLE public.profiles_groups (
    profile_id uuid NOT NULL,
    group_id bigint NOT NULL,
    created character varying DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE public.assets_verification (
    task_id character varying NOT NULL,
    verified_by character varying NOT NULL,
    verification_sent_date timestamp without time zone NOT NULL,
    verification_response_date timestamp without time zone,
    verification_status character varying,
    vendor_id character varying NOT NULL,
    profile_id uuid NOT NULL,
    verification_description character varying,
    asset_id bigint,
    id bigint NOT NULL
);

CREATE TABLE public.inspections (
    id bigint NOT NULL,
    profile_id uuid NOT NULL,
    openedprofile_id uuid NOT NULL,
    created timestamp without time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated timestamp without time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    introduction_id bigint,
    type character varying
);

CREATE TABLE public.bio_pref_relations (
    id bigint NOT NULL,
    type smallint DEFAULT 1 NOT NULL,
    bio_attr_id character varying NOT NULL,
    bio_response_id character varying,
    pref_attr_id character varying NOT NULL,
    pref_response_id character varying,
    score smallint DEFAULT 10,
    condition jsonb,
    created timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    brand_id smallint DEFAULT 102 NOT NULL
); 
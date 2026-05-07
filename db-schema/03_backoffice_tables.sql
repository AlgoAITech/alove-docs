--
-- Backoffice (BO) Tables
-- This file contains all backoffice/admin related tables
--

CREATE TABLE public.bo_brand_contacts (
    id integer NOT NULL,
    function character varying,
    first_name character varying,
    last_name character varying,
    phone character varying,
    email character varying,
    "position" character varying,
    brand integer
);

CREATE TABLE public."bo_customer_support_SLA_settings" (
    id smallint DEFAULT nextval('public.bo_customer_support_sla_settings_id_seq'::regclass) NOT NULL,
    sla_first smallint,
    sla_completion smallint,
    assignee jsonb,
    topic_id smallint,
    created timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    brand_id smallint
);

CREATE TABLE public.bo_customer_support_statuses (
    id smallint NOT NULL,
    name character varying NOT NULL
);

CREATE TABLE public.bo_customer_support_sub_topics (
    id smallint NOT NULL,
    name character varying,
    key character varying
);

CREATE TABLE public.bo_customer_support_tickets (
    id smallint DEFAULT nextval('public.bo_customer_support_tickets_seq'::regclass) NOT NULL,
    assigned_to jsonb,
    created timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    status smallint DEFAULT 1 NOT NULL,
    "SLA" numeric,
    topic smallint NOT NULL,
    last_update timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    profile_id character varying,
    screenshot character varying,
    title character varying,
    content character varying,
    reportee character varying,
    sub_topic smallint,
    brand_id smallint DEFAULT 102 NOT NULL,
    user_agent jsonb,
    priority smallint DEFAULT 3 NOT NULL,
    source smallint DEFAULT 0 NOT NULL,
    internal boolean DEFAULT false NOT NULL,
    introduction_id bigint,
    extra jsonb
);

COMMENT ON COLUMN public.bo_customer_support_tickets.priority IS '1-5';
COMMENT ON COLUMN public.bo_customer_support_tickets.source IS '0 - Mobile app
1 - Admin panel';

CREATE TABLE public.bo_customer_support_tickets_activity_log (
    id smallint DEFAULT nextval('public.bo_customer_support_tickets_activity_log_seq'::regclass) NOT NULL,
    ticket_id smallint NOT NULL,
    log character varying,
    created timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    user_id bigint NOT NULL,
    type smallint DEFAULT 0 NOT NULL
);

CREATE TABLE public.bo_customer_support_topics (
    id smallint NOT NULL,
    name character varying NOT NULL,
    key character varying NOT NULL
);

CREATE TABLE public.bo_roles (
    id integer NOT NULL,
    role_name character varying(50) NOT NULL,
    permissions jsonb,
    description character varying,
    created timestamp without time zone DEFAULT timezone('UTC'::text, now()),
    type smallint,
    created_by integer,
    brand_id integer,
    is_manager boolean DEFAULT false
);

CREATE TABLE public.bo_sessions (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    created timestamp without time zone NOT NULL,
    last_ping timestamp without time zone NOT NULL,
    ip character varying NOT NULL
);

CREATE TABLE public.bo_settings_pages (
    id bigint NOT NULL,
    title character varying NOT NULL,
    settings jsonb DEFAULT '[]'::jsonb NOT NULL,
    brand_id smallint NOT NULL,
    publish character varying,
    page_id character varying DEFAULT '1'::character varying NOT NULL,
    status_id smallint
);

CREATE TABLE public.bo_system_users (
    email character varying NOT NULL,
    password character varying,
    created timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated timestamp without time zone,
    first_name character varying NOT NULL,
    last_name character varying,
    phone character varying,
    lang character varying,
    id integer NOT NULL,
    role jsonb,
    avatar character varying,
    is_active boolean DEFAULT true,
    brands jsonb,
    is_online boolean,
    pages_access jsonb,
    test character varying,
    last_active timestamp without time zone,
    hidden_from_cs boolean DEFAULT false NOT NULL,
    notifications jsonb
);

-- record_id: see jlov-backend db-scripts/audit_trigger.sql (coalesce id, uuid, composite keys).
CREATE TABLE public.audit_log (
    id bigint NOT NULL,
    old_row jsonb NOT NULL,
    new_row jsonb,
    created timestamp without time zone DEFAULT timezone('UTC'::text, now()) NOT NULL,
    logged_user character varying NOT NULL,
    change_type character(1) NOT NULL,
    table_name character varying(255),
    record_id text
);

CREATE TABLE public."user" (
    id integer NOT NULL,
    login character varying NOT NULL,
    first_name character varying NOT NULL,
    last_name character varying NOT NULL,
    password character varying NOT NULL,
    brand_id smallint NOT NULL
);

CREATE TABLE public.user_roles (
    brand_id smallint NOT NULL,
    user_id smallint NOT NULL,
    role_id smallint NOT NULL,
    created timestamp without time zone DEFAULT timezone('utc'::text, now()),
    updated timestamp without time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    created_by smallint NOT NULL,
    updated_by smallint NOT NULL
); 
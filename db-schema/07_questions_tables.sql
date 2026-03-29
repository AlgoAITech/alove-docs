--
-- Questions and Responses Tables
-- This file contains all question and response related tables
--

CREATE TABLE public.question_category (
    id smallint NOT NULL,
    name character varying NOT NULL,
    created timestamp without time zone DEFAULT timezone('UTC'::text, now()) NOT NULL,
    question_type_id smallint NOT NULL,
    ordinal smallint NOT NULL,
    description character varying,
    icon_url character varying,
    is_negative boolean,
    factor_id smallint,
    brand_id character varying DEFAULT '101'::character varying NOT NULL
);

CREATE TABLE public.question_correlations (
    q_response_id bigint NOT NULL,
    q_response2_id bigint NOT NULL,
    created timestamp without time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    created_by integer NOT NULL,
    updated timestamp without time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_by integer NOT NULL
);

CREATE TABLE public.question_responses (
    id bigint NOT NULL,
    txt_id character varying NOT NULL,
    score numeric,
    question_id bigint NOT NULL,
    group_txt_id character varying,
    asset_url character varying,
    ordinal smallint DEFAULT 0 NOT NULL,
    is_core boolean DEFAULT false NOT NULL,
    pre_validation jsonb,
    attibute_id bigint DEFAULT '-1'::integer,
    column5 integer,
    additional_ids character varying,
    type smallint,
    action jsonb
);

CREATE TABLE public.question_responses_automatic (
    id integer DEFAULT nextval('public.bo_logs_id_seq'::regclass) NOT NULL,
    created timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    question_id integer NOT NULL,
    answer_id integer NOT NULL,
    created_by integer,
    relay_to_reponse_id integer NOT NULL,
    relay_to_question_id integer NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    value character varying,
    overwrite boolean DEFAULT false NOT NULL
);

CREATE TABLE public.predictors_relations (
    id bigint NOT NULL,
    predictor1 character varying NOT NULL,
    level1 character varying NOT NULL,
    predictor2 character varying NOT NULL,
    level2 character varying NOT NULL,
    grade smallint DEFAULT 0 NOT NULL,
    relation_group character varying(255)
);

COMMENT ON COLUMN public.predictors_relations.relation_group IS 'Optional label to group multiple predictor relations; exposed as "group" in API JSON.';

COMMENT ON COLUMN public.predictors_relations.level1 IS 'Low
Mid
High';

COMMENT ON COLUMN public.predictors_relations.level2 IS 'Low
Mid
High'; 
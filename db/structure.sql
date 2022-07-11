SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: audit; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA audit;


--
-- Name: btree_gist; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS btree_gist WITH SCHEMA public;


--
-- Name: EXTENSION btree_gist; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION btree_gist IS 'support for indexing common datatypes in GiST';


--
-- Name: citext; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;


--
-- Name: EXTENSION citext; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: invoice_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.invoice_status AS ENUM (
    'issued',
    'paid',
    'cancelled'
);


--
-- Name: payment_order_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.payment_order_status AS ENUM (
    'issued',
    'in_progress',
    'paid',
    'cancelled'
);


--
-- Name: result_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.result_status AS ENUM (
    'no_bids',
    'awaiting_payment',
    'payment_received',
    'payment_not_received',
    'domain_registered',
    'domain_not_registered'
);


--
-- Name: process_auction_audit(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.process_auction_audit() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    INSERT INTO audit.auctions
    (object_id, action, recorded_at, old_value, new_value)
    VALUES (NEW.id, 'INSERT', now(), '{}', to_json(NEW)::jsonb);
    RETURN NEW;
  ELSEIF (TG_OP = 'UPDATE') THEN
    INSERT INTO audit.auctions
    (object_id, action, recorded_at, old_value, new_value)
    VALUES (NEW.id, 'UPDATE', now(), to_json(OLD)::jsonb, to_json(NEW)::jsonb);
    RETURN NEW;
  ELSEIF (TG_OP = 'DELETE') THEN
    INSERT INTO audit.auctions
    (object_id, action, recorded_at, old_value, new_value)
    VALUES (OLD.id, 'DELETE', now(), to_json(OLD)::jsonb, '{}');
    RETURN OLD;
  END IF;
  RETURN NULL;
END
$$;


--
-- Name: process_ban_audit(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.process_ban_audit() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    INSERT INTO audit.bans
    (object_id, action, recorded_at, old_value, new_value)
    VALUES (NEW.id, 'INSERT', now(), '{}', to_json(NEW)::jsonb);
    RETURN NEW;
  ELSEIF (TG_OP = 'UPDATE') THEN
    INSERT INTO audit.bans
    (object_id, action, recorded_at, old_value, new_value)
    VALUES (NEW.id, 'UPDATE', now(), to_json(OLD)::jsonb, to_json(NEW)::jsonb);
    RETURN NEW;
  ELSEIF (TG_OP = 'DELETE') THEN
    INSERT INTO audit.bans
    (object_id, action, recorded_at, old_value, new_value)
    VALUES (OLD.id, 'DELETE', now(), to_json(OLD)::jsonb, '{}');
    RETURN OLD;
  END IF;
  RETURN NULL;
END
$$;


--
-- Name: process_billing_profile_audit(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.process_billing_profile_audit() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    INSERT INTO audit.billing_profiles
    (object_id, action, recorded_at, old_value, new_value)
    VALUES (NEW.id, 'INSERT', now(), '{}', to_json(NEW)::jsonb);
    RETURN NEW;
  ELSEIF (TG_OP = 'UPDATE') THEN
    INSERT INTO audit.billing_profiles
    (object_id, action, recorded_at, old_value, new_value)
    VALUES (NEW.id, 'UPDATE', now(), to_json(OLD)::jsonb, to_json(NEW)::jsonb);
    RETURN NEW;
  ELSEIF (TG_OP = 'DELETE') THEN
    INSERT INTO audit.billing_profiles
    (object_id, action, recorded_at, old_value, new_value)
    VALUES (OLD.id, 'DELETE', now(), to_json(OLD)::jsonb, '{}');
    RETURN OLD;
  END IF;
  RETURN NULL;
END
$$;


--
-- Name: process_invoice_audit(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.process_invoice_audit() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    INSERT INTO audit.invoices
    (object_id, action, recorded_at, old_value, new_value)
    VALUES (NEW.id, 'INSERT', now(), '{}', to_json(NEW)::jsonb);
    RETURN NEW;
  ELSEIF (TG_OP = 'UPDATE') THEN
    INSERT INTO audit.invoices
    (object_id, action, recorded_at, old_value, new_value)
    VALUES (NEW.id, 'UPDATE', now(), to_json(OLD)::jsonb, to_json(NEW)::jsonb);
    RETURN NEW;
  ELSEIF (TG_OP = 'DELETE') THEN
    INSERT INTO audit.invoices
    (object_id, action, recorded_at, old_value, new_value)
    VALUES (OLD.id, 'DELETE', now(), to_json(OLD)::jsonb, '{}');
    RETURN OLD;
  END IF;
  RETURN NULL;
END
$$;


--
-- Name: process_invoice_item_audit(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.process_invoice_item_audit() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    INSERT INTO audit.invoice_items
    (object_id, action, recorded_at, old_value, new_value)
    VALUES (NEW.id, 'INSERT', now(), '{}', to_json(NEW)::jsonb);
    RETURN NEW;
  ELSEIF (TG_OP = 'UPDATE') THEN
    INSERT INTO audit.invoice_items
    (object_id, action, recorded_at, old_value, new_value)
    VALUES (NEW.id, 'UPDATE', now(), to_json(OLD)::jsonb, to_json(NEW)::jsonb);
    RETURN NEW;
  ELSEIF (TG_OP = 'DELETE') THEN
    INSERT INTO audit.invoice_items
    (object_id, action, recorded_at, old_value, new_value)
    VALUES (OLD.id, 'DELETE', now(), to_json(OLD)::jsonb, '{}');
    RETURN OLD;
  END IF;
  RETURN NULL;
END
$$;


--
-- Name: process_invoice_payment_order_audit(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.process_invoice_payment_order_audit() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    INSERT INTO audit.invoice_payment_orders
    (object_id, action, recorded_at, old_value, new_value)
    VALUES (NEW.id, 'INSERT', now(), '{}', to_json(NEW)::jsonb);
    RETURN NEW;
  ELSEIF (TG_OP = 'UPDATE') THEN
    INSERT INTO audit.invoice_payment_orders
    (object_id, action, recorded_at, old_value, new_value)
    VALUES (NEW.id, 'UPDATE', now(), to_json(OLD)::jsonb, to_json(NEW)::jsonb);
    RETURN NEW;
  ELSEIF (TG_OP = 'DELETE') THEN
    INSERT INTO audit.invoice_payment_orders
    (object_id, action, recorded_at, old_value, new_value)
    VALUES (OLD.id, 'DELETE', now(), to_json(OLD)::jsonb, '{}');
    RETURN OLD;
  END IF;
  RETURN NULL;
END
$$;


--
-- Name: process_offer_audit(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.process_offer_audit() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    INSERT INTO audit.offers
    (object_id, action, recorded_at, old_value, new_value)
    VALUES (NEW.id, 'INSERT', now(), '{}', to_json(NEW)::jsonb);
    RETURN NEW;
  ELSEIF (TG_OP = 'UPDATE') THEN
    INSERT INTO audit.offers
    (object_id, action, recorded_at, old_value, new_value)
    VALUES (NEW.id, 'UPDATE', now(), to_json(OLD)::jsonb, to_json(NEW)::jsonb);
    RETURN NEW;
  ELSEIF (TG_OP = 'DELETE') THEN
    INSERT INTO audit.offers
    (object_id, action, recorded_at, old_value, new_value)
    VALUES (OLD.id, 'DELETE', now(), to_json(OLD)::jsonb, '{}');
    RETURN OLD;
  END IF;
  RETURN NULL;
END
$$;


--
-- Name: process_payment_order_audit(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.process_payment_order_audit() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    INSERT INTO audit.payment_orders
    (object_id, action, recorded_at, old_value, new_value)
    VALUES (NEW.id, 'INSERT', now(), '{}', to_json(NEW)::jsonb);
    RETURN NEW;
  ELSEIF (TG_OP = 'UPDATE') THEN
    INSERT INTO audit.payment_orders
    (object_id, action, recorded_at, old_value, new_value)
    VALUES (NEW.id, 'UPDATE', now(), to_json(OLD)::jsonb, to_json(NEW)::jsonb);
    RETURN NEW;
  ELSEIF (TG_OP = 'DELETE') THEN
    INSERT INTO audit.payment_orders
    (object_id, action, recorded_at, old_value, new_value)
    VALUES (OLD.id, 'DELETE', now(), to_json(OLD)::jsonb, '{}');
    RETURN OLD;
  END IF;
  RETURN NULL;
END
$$;


--
-- Name: process_result_audit(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.process_result_audit() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    INSERT INTO audit.results
    (object_id, action, recorded_at, old_value, new_value)
    VALUES (NEW.id, 'INSERT', now(), '{}', to_json(NEW)::jsonb);
    RETURN NEW;
  ELSEIF (TG_OP = 'UPDATE') THEN
    INSERT INTO audit.results
    (object_id, action, recorded_at, old_value, new_value)
    VALUES (NEW.id, 'UPDATE', now(), to_json(OLD)::jsonb, to_json(NEW)::jsonb);
    RETURN NEW;
  ELSEIF (TG_OP = 'DELETE') THEN
    INSERT INTO audit.results
    (object_id, action, recorded_at, old_value, new_value)
    VALUES (OLD.id, 'DELETE', now(), to_json(OLD)::jsonb, '{}');
    RETURN OLD;
  END IF;
  RETURN NULL;
END
$$;


--
-- Name: process_setting_audit(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.process_setting_audit() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    INSERT INTO audit.settings
    (object_id, action, recorded_at, old_value, new_value)
    VALUES (NEW.id, 'INSERT', now(), '{}', to_json(NEW)::jsonb);
    RETURN NEW;
  ELSEIF (TG_OP = 'UPDATE') THEN
    INSERT INTO audit.settings
    (object_id, action, recorded_at, old_value, new_value)
    VALUES (NEW.id, 'UPDATE', now(), to_json(OLD)::jsonb, to_json(NEW)::jsonb);
    RETURN NEW;
  ELSEIF (TG_OP = 'DELETE') THEN
    INSERT INTO audit.settings
    (object_id, action, recorded_at, old_value, new_value)
    VALUES (OLD.id, 'DELETE', now(), to_json(OLD)::jsonb, '{}');
    RETURN OLD;
  END IF;
  RETURN NULL;
END
$$;


--
-- Name: process_user_audit(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.process_user_audit() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    INSERT INTO audit.users
    (object_id, action, recorded_at, old_value, new_value)
    VALUES (NEW.id, 'INSERT', now(), '{}', to_json(NEW)::jsonb);
    RETURN NEW;
  ELSEIF (TG_OP = 'UPDATE') THEN
    INSERT INTO audit.users
    (object_id, action, recorded_at, old_value, new_value)
    VALUES (NEW.id, 'UPDATE', now(), to_json(OLD)::jsonb, to_json(NEW)::jsonb);
    RETURN NEW;
  ELSEIF (TG_OP = 'DELETE') THEN
    INSERT INTO audit.users
    (object_id, action, recorded_at, old_value, new_value)
    VALUES (OLD.id, 'DELETE', now(), to_json(OLD)::jsonb, '{}');
    RETURN OLD;
  END IF;
  RETURN NULL;
END
$$;


--
-- Name: process_wishlist_item_audit(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.process_wishlist_item_audit() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    INSERT INTO audit.wishlist_items
    (object_id, action, recorded_at, old_value, new_value)
    VALUES (NEW.id, 'INSERT', now(), '{}', to_json(NEW)::jsonb);
    RETURN NEW;
  ELSEIF (TG_OP = 'UPDATE') THEN
    INSERT INTO audit.wishlist_items
    (object_id, action, recorded_at, old_value, new_value)
    VALUES (NEW.id, 'UPDATE', now(), to_json(OLD)::jsonb, to_json(NEW)::jsonb);
    RETURN NEW;
  ELSEIF (TG_OP = 'DELETE') THEN
    INSERT INTO audit.wishlist_items
    (object_id, action, recorded_at, old_value, new_value)
    VALUES (OLD.id, 'DELETE', now(), to_json(OLD)::jsonb, '{}');
    RETURN OLD;
  END IF;
  RETURN NULL;
END
$$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: auctions; Type: TABLE; Schema: audit; Owner: -
--

CREATE TABLE audit.auctions (
    id integer NOT NULL,
    object_id bigint,
    action text NOT NULL,
    recorded_at timestamp without time zone,
    old_value jsonb,
    new_value jsonb,
    CONSTRAINT auctions_action_check CHECK ((action = ANY (ARRAY['INSERT'::text, 'UPDATE'::text, 'DELETE'::text, 'TRUNCATE'::text])))
);


--
-- Name: auctions_id_seq; Type: SEQUENCE; Schema: audit; Owner: -
--

CREATE SEQUENCE audit.auctions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: auctions_id_seq; Type: SEQUENCE OWNED BY; Schema: audit; Owner: -
--

ALTER SEQUENCE audit.auctions_id_seq OWNED BY audit.auctions.id;


--
-- Name: bans; Type: TABLE; Schema: audit; Owner: -
--

CREATE TABLE audit.bans (
    id integer NOT NULL,
    object_id bigint,
    action text NOT NULL,
    recorded_at timestamp without time zone,
    old_value jsonb,
    new_value jsonb,
    CONSTRAINT bans_action_check CHECK ((action = ANY (ARRAY['INSERT'::text, 'UPDATE'::text, 'DELETE'::text, 'TRUNCATE'::text])))
);


--
-- Name: bans_id_seq; Type: SEQUENCE; Schema: audit; Owner: -
--

CREATE SEQUENCE audit.bans_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bans_id_seq; Type: SEQUENCE OWNED BY; Schema: audit; Owner: -
--

ALTER SEQUENCE audit.bans_id_seq OWNED BY audit.bans.id;


--
-- Name: billing_profiles; Type: TABLE; Schema: audit; Owner: -
--

CREATE TABLE audit.billing_profiles (
    id integer NOT NULL,
    object_id bigint,
    action text NOT NULL,
    recorded_at timestamp without time zone,
    old_value jsonb,
    new_value jsonb,
    CONSTRAINT billing_profiles_action_check CHECK ((action = ANY (ARRAY['INSERT'::text, 'UPDATE'::text, 'DELETE'::text, 'TRUNCATE'::text])))
);


--
-- Name: billing_profiles_id_seq; Type: SEQUENCE; Schema: audit; Owner: -
--

CREATE SEQUENCE audit.billing_profiles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: billing_profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: audit; Owner: -
--

ALTER SEQUENCE audit.billing_profiles_id_seq OWNED BY audit.billing_profiles.id;


--
-- Name: invoice_items; Type: TABLE; Schema: audit; Owner: -
--

CREATE TABLE audit.invoice_items (
    id integer NOT NULL,
    object_id bigint,
    action text NOT NULL,
    recorded_at timestamp without time zone,
    old_value jsonb,
    new_value jsonb,
    CONSTRAINT invoice_items_action_check CHECK ((action = ANY (ARRAY['INSERT'::text, 'UPDATE'::text, 'DELETE'::text, 'TRUNCATE'::text])))
);


--
-- Name: invoice_items_id_seq; Type: SEQUENCE; Schema: audit; Owner: -
--

CREATE SEQUENCE audit.invoice_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invoice_items_id_seq; Type: SEQUENCE OWNED BY; Schema: audit; Owner: -
--

ALTER SEQUENCE audit.invoice_items_id_seq OWNED BY audit.invoice_items.id;


--
-- Name: invoice_payment_orders; Type: TABLE; Schema: audit; Owner: -
--

CREATE TABLE audit.invoice_payment_orders (
    id integer NOT NULL,
    object_id bigint,
    action text NOT NULL,
    recorded_at timestamp without time zone,
    old_value jsonb,
    new_value jsonb,
    CONSTRAINT invoice_payment_orders_action_check CHECK ((action = ANY (ARRAY['INSERT'::text, 'UPDATE'::text, 'DELETE'::text, 'TRUNCATE'::text])))
);


--
-- Name: invoice_payment_orders_id_seq; Type: SEQUENCE; Schema: audit; Owner: -
--

CREATE SEQUENCE audit.invoice_payment_orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invoice_payment_orders_id_seq; Type: SEQUENCE OWNED BY; Schema: audit; Owner: -
--

ALTER SEQUENCE audit.invoice_payment_orders_id_seq OWNED BY audit.invoice_payment_orders.id;


--
-- Name: invoices; Type: TABLE; Schema: audit; Owner: -
--

CREATE TABLE audit.invoices (
    id integer NOT NULL,
    object_id bigint,
    action text NOT NULL,
    recorded_at timestamp without time zone,
    old_value jsonb,
    new_value jsonb,
    CONSTRAINT invoices_action_check CHECK ((action = ANY (ARRAY['INSERT'::text, 'UPDATE'::text, 'DELETE'::text, 'TRUNCATE'::text])))
);


--
-- Name: invoices_id_seq; Type: SEQUENCE; Schema: audit; Owner: -
--

CREATE SEQUENCE audit.invoices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invoices_id_seq; Type: SEQUENCE OWNED BY; Schema: audit; Owner: -
--

ALTER SEQUENCE audit.invoices_id_seq OWNED BY audit.invoices.id;


--
-- Name: offers; Type: TABLE; Schema: audit; Owner: -
--

CREATE TABLE audit.offers (
    id integer NOT NULL,
    object_id bigint,
    action text NOT NULL,
    recorded_at timestamp without time zone,
    old_value jsonb,
    new_value jsonb,
    CONSTRAINT offers_action_check CHECK ((action = ANY (ARRAY['INSERT'::text, 'UPDATE'::text, 'DELETE'::text, 'TRUNCATE'::text])))
);


--
-- Name: offers_id_seq; Type: SEQUENCE; Schema: audit; Owner: -
--

CREATE SEQUENCE audit.offers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: offers_id_seq; Type: SEQUENCE OWNED BY; Schema: audit; Owner: -
--

ALTER SEQUENCE audit.offers_id_seq OWNED BY audit.offers.id;


--
-- Name: payment_orders; Type: TABLE; Schema: audit; Owner: -
--

CREATE TABLE audit.payment_orders (
    id integer NOT NULL,
    object_id bigint,
    action text NOT NULL,
    recorded_at timestamp without time zone,
    old_value jsonb,
    new_value jsonb,
    CONSTRAINT payment_orders_action_check CHECK ((action = ANY (ARRAY['INSERT'::text, 'UPDATE'::text, 'DELETE'::text, 'TRUNCATE'::text])))
);


--
-- Name: payment_orders_id_seq; Type: SEQUENCE; Schema: audit; Owner: -
--

CREATE SEQUENCE audit.payment_orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payment_orders_id_seq; Type: SEQUENCE OWNED BY; Schema: audit; Owner: -
--

ALTER SEQUENCE audit.payment_orders_id_seq OWNED BY audit.payment_orders.id;


--
-- Name: results; Type: TABLE; Schema: audit; Owner: -
--

CREATE TABLE audit.results (
    id integer NOT NULL,
    object_id bigint,
    action text NOT NULL,
    recorded_at timestamp without time zone,
    old_value jsonb,
    new_value jsonb,
    CONSTRAINT results_action_check CHECK ((action = ANY (ARRAY['INSERT'::text, 'UPDATE'::text, 'DELETE'::text, 'TRUNCATE'::text])))
);


--
-- Name: results_id_seq; Type: SEQUENCE; Schema: audit; Owner: -
--

CREATE SEQUENCE audit.results_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: results_id_seq; Type: SEQUENCE OWNED BY; Schema: audit; Owner: -
--

ALTER SEQUENCE audit.results_id_seq OWNED BY audit.results.id;


--
-- Name: settings; Type: TABLE; Schema: audit; Owner: -
--

CREATE TABLE audit.settings (
    id integer NOT NULL,
    object_id bigint,
    action text NOT NULL,
    recorded_at timestamp without time zone,
    old_value jsonb,
    new_value jsonb,
    CONSTRAINT settings_action_check CHECK ((action = ANY (ARRAY['INSERT'::text, 'UPDATE'::text, 'DELETE'::text, 'TRUNCATE'::text])))
);


--
-- Name: settings_id_seq; Type: SEQUENCE; Schema: audit; Owner: -
--

CREATE SEQUENCE audit.settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: settings_id_seq; Type: SEQUENCE OWNED BY; Schema: audit; Owner: -
--

ALTER SEQUENCE audit.settings_id_seq OWNED BY audit.settings.id;


--
-- Name: users; Type: TABLE; Schema: audit; Owner: -
--

CREATE TABLE audit.users (
    id integer NOT NULL,
    object_id bigint,
    action text NOT NULL,
    recorded_at timestamp without time zone,
    old_value jsonb,
    new_value jsonb,
    CONSTRAINT users_action_check CHECK ((action = ANY (ARRAY['INSERT'::text, 'UPDATE'::text, 'DELETE'::text, 'TRUNCATE'::text])))
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: audit; Owner: -
--

CREATE SEQUENCE audit.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: audit; Owner: -
--

ALTER SEQUENCE audit.users_id_seq OWNED BY audit.users.id;


--
-- Name: wishlist_items; Type: TABLE; Schema: audit; Owner: -
--

CREATE TABLE audit.wishlist_items (
    id integer NOT NULL,
    object_id bigint,
    action text NOT NULL,
    recorded_at timestamp without time zone,
    old_value jsonb,
    new_value jsonb,
    CONSTRAINT wishlist_items_action_check CHECK ((action = ANY (ARRAY['INSERT'::text, 'UPDATE'::text, 'DELETE'::text, 'TRUNCATE'::text])))
);


--
-- Name: wishlist_items_id_seq; Type: SEQUENCE; Schema: audit; Owner: -
--

CREATE SEQUENCE audit.wishlist_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: wishlist_items_id_seq; Type: SEQUENCE OWNED BY; Schema: audit; Owner: -
--

ALTER SEQUENCE audit.wishlist_items_id_seq OWNED BY audit.wishlist_items.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: authentications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.authentications (
    id bigint NOT NULL,
    service_id bigint,
    session_id character varying NOT NULL,
    principal_code character varying,
    first_name character varying,
    last_name character varying,
    channel character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: authentications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.authentications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: authentications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.authentications_id_seq OWNED BY public.authentications.id;


--
-- Name: contacts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.contacts (
    id bigint NOT NULL,
    name character varying,
    email character varying,
    mobile_phone character varying,
    identity_code character varying,
    "default" boolean DEFAULT false,
    main boolean DEFAULT false,
    user_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.contacts_id_seq OWNED BY public.contacts.id;


--
-- Name: delayed_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.delayed_jobs (
    id bigint NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    attempts integer DEFAULT 0 NOT NULL,
    handler text NOT NULL,
    last_error text,
    run_at timestamp without time zone,
    locked_at timestamp without time zone,
    failed_at timestamp without time zone,
    locked_by character varying,
    queue character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.delayed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.delayed_jobs_id_seq OWNED BY public.delayed_jobs.id;


--
-- Name: invoice_payment_orders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.invoice_payment_orders (
    id bigint NOT NULL,
    invoice_id bigint NOT NULL,
    payment_order_id bigint NOT NULL
);


--
-- Name: invoice_payment_orders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.invoice_payment_orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invoice_payment_orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.invoice_payment_orders_id_seq OWNED BY public.invoice_payment_orders.id;


--
-- Name: invoices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.invoices (
    id bigint NOT NULL,
    user_id integer,
    issue_date date NOT NULL,
    due_date date NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    cents integer NOT NULL,
    paid_at timestamp without time zone,
    status public.invoice_status DEFAULT 'issued'::public.invoice_status,
    number_old integer NOT NULL,
    uuid uuid DEFAULT public.gen_random_uuid(),
    vat_rate numeric,
    paid_amount numeric,
    updated_by character varying,
    notes character varying,
    paid_with_payment_order_id bigint,
    recipient character varying,
    vat_code character varying,
    legal_entity boolean,
    street character varying,
    city character varying,
    state character varying,
    postal_code character varying,
    alpha_two_country_code character varying,
    in_directo boolean DEFAULT false NOT NULL,
    description character varying NOT NULL,
    number integer,
    payment_link character varying,
    CONSTRAINT invoices_cents_are_positive CHECK ((cents > 0)),
    CONSTRAINT invoices_due_date_is_not_before_issue_date CHECK ((issue_date <= due_date)),
    CONSTRAINT paid_at_is_filled_when_status_is_paid CHECK ((NOT ((status = 'paid'::public.invoice_status) AND (paid_at IS NULL)))),
    CONSTRAINT paid_at_is_not_filled_when_status_is_not_paid CHECK ((NOT ((status <> 'paid'::public.invoice_status) AND (paid_at IS NOT NULL))))
);


--
-- Name: invoices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.invoices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invoices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.invoices_id_seq OWNED BY public.invoices.id;


--
-- Name: invoices_number_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.invoices_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invoices_number_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.invoices_number_seq OWNED BY public.invoices.number_old;


--
-- Name: payment_orders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payment_orders (
    id bigint NOT NULL,
    type character varying NOT NULL,
    invoice_id integer,
    user_id integer,
    response jsonb,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    status public.payment_order_status DEFAULT 'issued'::public.payment_order_status,
    uuid uuid DEFAULT public.gen_random_uuid()
);


--
-- Name: payment_orders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.payment_orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payment_orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.payment_orders_id_seq OWNED BY public.payment_orders.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: services; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.services (
    id bigint NOT NULL,
    user_id bigint,
    archived boolean DEFAULT false,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    callback_url character varying,
    approval_description text,
    name character varying,
    short_description character varying,
    rejected boolean DEFAULT false,
    password character varying,
    environment character varying,
    auth_methods text[] DEFAULT '{}'::text[],
    client_id character varying,
    tech_email character varying,
    interrupt_email character varying,
    contact_id bigint,
    approved boolean DEFAULT false,
    suspended boolean DEFAULT false
);


--
-- Name: services_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.services_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: services_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.services_id_seq OWNED BY public.services.id;


--
-- Name: transactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.transactions (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    authentication_id bigint NOT NULL,
    cents integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: transactions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.transactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: transactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.transactions_id_seq OWNED BY public.transactions.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    email character varying NOT NULL,
    encrypted_password character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    confirmation_token character varying,
    confirmed_at timestamp without time zone,
    confirmation_sent_at timestamp without time zone,
    unconfirmed_email character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    alpha_two_country_code character varying(2) NOT NULL,
    identity_code character varying,
    given_names character varying NOT NULL,
    surname character varying NOT NULL,
    mobile_phone character varying,
    roles character varying[] DEFAULT '{customer}'::character varying[],
    terms_and_conditions_accepted_at timestamp without time zone,
    uuid uuid DEFAULT public.gen_random_uuid(),
    locale character varying DEFAULT 'en'::character varying NOT NULL,
    provider character varying,
    uid character varying,
    updated_by character varying,
    discarded_at timestamp without time zone,
    balance_cents integer DEFAULT 0,
    billing_recipient character varying,
    billing_vat_code character varying,
    billing_street character varying,
    billing_city character varying,
    billing_zip character varying,
    billing_alpha_two_country_code character varying,
    CONSTRAINT users_roles_are_known CHECK ((roles <@ ARRAY['customer'::character varying, 'administrator'::character varying]))
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: auctions id; Type: DEFAULT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.auctions ALTER COLUMN id SET DEFAULT nextval('audit.auctions_id_seq'::regclass);


--
-- Name: bans id; Type: DEFAULT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.bans ALTER COLUMN id SET DEFAULT nextval('audit.bans_id_seq'::regclass);


--
-- Name: billing_profiles id; Type: DEFAULT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.billing_profiles ALTER COLUMN id SET DEFAULT nextval('audit.billing_profiles_id_seq'::regclass);


--
-- Name: invoice_items id; Type: DEFAULT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.invoice_items ALTER COLUMN id SET DEFAULT nextval('audit.invoice_items_id_seq'::regclass);


--
-- Name: invoice_payment_orders id; Type: DEFAULT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.invoice_payment_orders ALTER COLUMN id SET DEFAULT nextval('audit.invoice_payment_orders_id_seq'::regclass);


--
-- Name: invoices id; Type: DEFAULT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.invoices ALTER COLUMN id SET DEFAULT nextval('audit.invoices_id_seq'::regclass);


--
-- Name: offers id; Type: DEFAULT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.offers ALTER COLUMN id SET DEFAULT nextval('audit.offers_id_seq'::regclass);


--
-- Name: payment_orders id; Type: DEFAULT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.payment_orders ALTER COLUMN id SET DEFAULT nextval('audit.payment_orders_id_seq'::regclass);


--
-- Name: results id; Type: DEFAULT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.results ALTER COLUMN id SET DEFAULT nextval('audit.results_id_seq'::regclass);


--
-- Name: settings id; Type: DEFAULT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.settings ALTER COLUMN id SET DEFAULT nextval('audit.settings_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.users ALTER COLUMN id SET DEFAULT nextval('audit.users_id_seq'::regclass);


--
-- Name: wishlist_items id; Type: DEFAULT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.wishlist_items ALTER COLUMN id SET DEFAULT nextval('audit.wishlist_items_id_seq'::regclass);


--
-- Name: authentications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.authentications ALTER COLUMN id SET DEFAULT nextval('public.authentications_id_seq'::regclass);


--
-- Name: contacts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contacts ALTER COLUMN id SET DEFAULT nextval('public.contacts_id_seq'::regclass);


--
-- Name: delayed_jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delayed_jobs ALTER COLUMN id SET DEFAULT nextval('public.delayed_jobs_id_seq'::regclass);


--
-- Name: invoice_payment_orders id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice_payment_orders ALTER COLUMN id SET DEFAULT nextval('public.invoice_payment_orders_id_seq'::regclass);


--
-- Name: invoices id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoices ALTER COLUMN id SET DEFAULT nextval('public.invoices_id_seq'::regclass);


--
-- Name: invoices number_old; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoices ALTER COLUMN number_old SET DEFAULT nextval('public.invoices_number_seq'::regclass);


--
-- Name: payment_orders id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_orders ALTER COLUMN id SET DEFAULT nextval('public.payment_orders_id_seq'::regclass);


--
-- Name: services id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.services ALTER COLUMN id SET DEFAULT nextval('public.services_id_seq'::regclass);


--
-- Name: transactions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions ALTER COLUMN id SET DEFAULT nextval('public.transactions_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: auctions auctions_pkey; Type: CONSTRAINT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.auctions
    ADD CONSTRAINT auctions_pkey PRIMARY KEY (id);


--
-- Name: bans bans_pkey; Type: CONSTRAINT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.bans
    ADD CONSTRAINT bans_pkey PRIMARY KEY (id);


--
-- Name: billing_profiles billing_profiles_pkey; Type: CONSTRAINT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.billing_profiles
    ADD CONSTRAINT billing_profiles_pkey PRIMARY KEY (id);


--
-- Name: invoice_items invoice_items_pkey; Type: CONSTRAINT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.invoice_items
    ADD CONSTRAINT invoice_items_pkey PRIMARY KEY (id);


--
-- Name: invoice_payment_orders invoice_payment_orders_pkey; Type: CONSTRAINT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.invoice_payment_orders
    ADD CONSTRAINT invoice_payment_orders_pkey PRIMARY KEY (id);


--
-- Name: invoices invoices_pkey; Type: CONSTRAINT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.invoices
    ADD CONSTRAINT invoices_pkey PRIMARY KEY (id);


--
-- Name: offers offers_pkey; Type: CONSTRAINT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.offers
    ADD CONSTRAINT offers_pkey PRIMARY KEY (id);


--
-- Name: payment_orders payment_orders_pkey; Type: CONSTRAINT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.payment_orders
    ADD CONSTRAINT payment_orders_pkey PRIMARY KEY (id);


--
-- Name: results results_pkey; Type: CONSTRAINT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.results
    ADD CONSTRAINT results_pkey PRIMARY KEY (id);


--
-- Name: settings settings_pkey; Type: CONSTRAINT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: wishlist_items wishlist_items_pkey; Type: CONSTRAINT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.wishlist_items
    ADD CONSTRAINT wishlist_items_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: authentications authentications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.authentications
    ADD CONSTRAINT authentications_pkey PRIMARY KEY (id);


--
-- Name: contacts contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contacts
    ADD CONSTRAINT contacts_pkey PRIMARY KEY (id);


--
-- Name: delayed_jobs delayed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delayed_jobs
    ADD CONSTRAINT delayed_jobs_pkey PRIMARY KEY (id);


--
-- Name: invoice_payment_orders invoice_payment_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice_payment_orders
    ADD CONSTRAINT invoice_payment_orders_pkey PRIMARY KEY (id);


--
-- Name: invoices invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_pkey PRIMARY KEY (id);


--
-- Name: payment_orders payment_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_orders
    ADD CONSTRAINT payment_orders_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: services services_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_pkey PRIMARY KEY (id);


--
-- Name: transactions transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: auctions_object_id_idx; Type: INDEX; Schema: audit; Owner: -
--

CREATE INDEX auctions_object_id_idx ON audit.auctions USING btree (object_id);


--
-- Name: auctions_recorded_at_idx; Type: INDEX; Schema: audit; Owner: -
--

CREATE INDEX auctions_recorded_at_idx ON audit.auctions USING btree (recorded_at);


--
-- Name: bans_object_id_idx; Type: INDEX; Schema: audit; Owner: -
--

CREATE INDEX bans_object_id_idx ON audit.bans USING btree (object_id);


--
-- Name: bans_recorded_at_idx; Type: INDEX; Schema: audit; Owner: -
--

CREATE INDEX bans_recorded_at_idx ON audit.bans USING btree (recorded_at);


--
-- Name: billing_profiles_object_id_idx; Type: INDEX; Schema: audit; Owner: -
--

CREATE INDEX billing_profiles_object_id_idx ON audit.billing_profiles USING btree (object_id);


--
-- Name: billing_profiles_recorded_at_idx; Type: INDEX; Schema: audit; Owner: -
--

CREATE INDEX billing_profiles_recorded_at_idx ON audit.billing_profiles USING btree (recorded_at);


--
-- Name: invoice_items_object_id_idx; Type: INDEX; Schema: audit; Owner: -
--

CREATE INDEX invoice_items_object_id_idx ON audit.invoice_items USING btree (object_id);


--
-- Name: invoice_items_recorded_at_idx; Type: INDEX; Schema: audit; Owner: -
--

CREATE INDEX invoice_items_recorded_at_idx ON audit.invoice_items USING btree (recorded_at);


--
-- Name: invoice_payment_orders_object_id_idx; Type: INDEX; Schema: audit; Owner: -
--

CREATE INDEX invoice_payment_orders_object_id_idx ON audit.invoice_payment_orders USING btree (object_id);


--
-- Name: invoice_payment_orders_recorded_at_idx; Type: INDEX; Schema: audit; Owner: -
--

CREATE INDEX invoice_payment_orders_recorded_at_idx ON audit.invoice_payment_orders USING btree (recorded_at);


--
-- Name: invoices_object_id_idx; Type: INDEX; Schema: audit; Owner: -
--

CREATE INDEX invoices_object_id_idx ON audit.invoices USING btree (object_id);


--
-- Name: invoices_recorded_at_idx; Type: INDEX; Schema: audit; Owner: -
--

CREATE INDEX invoices_recorded_at_idx ON audit.invoices USING btree (recorded_at);


--
-- Name: offers_object_id_idx; Type: INDEX; Schema: audit; Owner: -
--

CREATE INDEX offers_object_id_idx ON audit.offers USING btree (object_id);


--
-- Name: offers_recorded_at_idx; Type: INDEX; Schema: audit; Owner: -
--

CREATE INDEX offers_recorded_at_idx ON audit.offers USING btree (recorded_at);


--
-- Name: payment_orders_object_id_idx; Type: INDEX; Schema: audit; Owner: -
--

CREATE INDEX payment_orders_object_id_idx ON audit.payment_orders USING btree (object_id);


--
-- Name: payment_orders_recorded_at_idx; Type: INDEX; Schema: audit; Owner: -
--

CREATE INDEX payment_orders_recorded_at_idx ON audit.payment_orders USING btree (recorded_at);


--
-- Name: results_object_id_idx; Type: INDEX; Schema: audit; Owner: -
--

CREATE INDEX results_object_id_idx ON audit.results USING btree (object_id);


--
-- Name: results_recorded_at_idx; Type: INDEX; Schema: audit; Owner: -
--

CREATE INDEX results_recorded_at_idx ON audit.results USING btree (recorded_at);


--
-- Name: settings_object_id_idx; Type: INDEX; Schema: audit; Owner: -
--

CREATE INDEX settings_object_id_idx ON audit.settings USING btree (object_id);


--
-- Name: settings_recorded_at_idx; Type: INDEX; Schema: audit; Owner: -
--

CREATE INDEX settings_recorded_at_idx ON audit.settings USING btree (recorded_at);


--
-- Name: users_object_id_idx; Type: INDEX; Schema: audit; Owner: -
--

CREATE INDEX users_object_id_idx ON audit.users USING btree (object_id);


--
-- Name: users_recorded_at_idx; Type: INDEX; Schema: audit; Owner: -
--

CREATE INDEX users_recorded_at_idx ON audit.users USING btree (recorded_at);


--
-- Name: wishlist_items_object_id_idx; Type: INDEX; Schema: audit; Owner: -
--

CREATE INDEX wishlist_items_object_id_idx ON audit.wishlist_items USING btree (object_id);


--
-- Name: wishlist_items_recorded_at_idx; Type: INDEX; Schema: audit; Owner: -
--

CREATE INDEX wishlist_items_recorded_at_idx ON audit.wishlist_items USING btree (recorded_at);


--
-- Name: delayed_jobs_priority; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX delayed_jobs_priority ON public.delayed_jobs USING btree (priority, run_at);


--
-- Name: index_authentications_on_service_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_authentications_on_service_id ON public.authentications USING btree (service_id);


--
-- Name: index_contacts_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contacts_on_user_id ON public.contacts USING btree (user_id);


--
-- Name: index_invoice_payment_orders_on_invoice_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_invoice_payment_orders_on_invoice_id ON public.invoice_payment_orders USING btree (invoice_id);


--
-- Name: index_invoice_payment_orders_on_payment_order_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_invoice_payment_orders_on_payment_order_id ON public.invoice_payment_orders USING btree (payment_order_id);


--
-- Name: index_invoices_on_paid_with_payment_order_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_invoices_on_paid_with_payment_order_id ON public.invoices USING btree (paid_with_payment_order_id);


--
-- Name: index_invoices_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_invoices_on_user_id ON public.invoices USING btree (user_id);


--
-- Name: index_invoices_on_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_invoices_on_uuid ON public.invoices USING btree (uuid);


--
-- Name: index_payment_orders_on_invoice_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_payment_orders_on_invoice_id ON public.payment_orders USING btree (invoice_id);


--
-- Name: index_payment_orders_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_payment_orders_on_user_id ON public.payment_orders USING btree (user_id);


--
-- Name: index_payment_orders_on_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_payment_orders_on_uuid ON public.payment_orders USING btree (uuid);


--
-- Name: index_services_on_client_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_services_on_client_id ON public.services USING btree (client_id);


--
-- Name: index_services_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_services_on_user_id ON public.services USING btree (user_id);


--
-- Name: index_transactions_on_authentication_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_transactions_on_authentication_id ON public.transactions USING btree (authentication_id);


--
-- Name: index_transactions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_transactions_on_user_id ON public.transactions USING btree (user_id);


--
-- Name: index_users_on_confirmation_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_confirmation_token ON public.users USING btree (confirmation_token);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_provider_and_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_provider_and_uid ON public.users USING btree (provider, uid);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- Name: index_users_on_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_uuid ON public.users USING btree (uuid);


--
-- Name: users_by_identity_code_and_country; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_by_identity_code_and_country ON public.users USING btree (alpha_two_country_code, identity_code) WHERE ((alpha_two_country_code)::text = 'EE'::text);


--
-- Name: invoices process_invoice_audit; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER process_invoice_audit AFTER INSERT OR DELETE OR UPDATE ON public.invoices FOR EACH ROW EXECUTE PROCEDURE public.process_invoice_audit();


--
-- Name: invoice_payment_orders process_invoice_payment_order_audit; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER process_invoice_payment_order_audit AFTER INSERT OR DELETE OR UPDATE ON public.invoice_payment_orders FOR EACH ROW EXECUTE PROCEDURE public.process_invoice_payment_order_audit();


--
-- Name: payment_orders process_payment_order_audit; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER process_payment_order_audit AFTER INSERT OR DELETE OR UPDATE ON public.payment_orders FOR EACH ROW EXECUTE PROCEDURE public.process_payment_order_audit();


--
-- Name: users process_user_audit; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER process_user_audit AFTER INSERT OR DELETE OR UPDATE ON public.users FOR EACH ROW EXECUTE PROCEDURE public.process_user_audit();


--
-- Name: transactions fk_rails_34b0be2412; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT fk_rails_34b0be2412 FOREIGN KEY (authentication_id) REFERENCES public.authentications(id);


--
-- Name: invoices fk_rails_3d1522a0d8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT fk_rails_3d1522a0d8 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: transactions fk_rails_77364e6416; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT fk_rails_77364e6416 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: payment_orders fk_rails_79beebc2e9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_orders
    ADD CONSTRAINT fk_rails_79beebc2e9 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: contacts fk_rails_8d2134e55e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contacts
    ADD CONSTRAINT fk_rails_8d2134e55e FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: payment_orders fk_rails_f9dc5857c3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_orders
    ADD CONSTRAINT fk_rails_f9dc5857c3 FOREIGN KEY (invoice_id) REFERENCES public.invoices(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20210318134350'),
('20210322152413'),
('20210323123333'),
('20210921143330'),
('20211001112212'),
('20220210141259'),
('20220214110646'),
('20220214143035'),
('20220711071642'),
('20220711071734');



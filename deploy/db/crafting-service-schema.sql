--
-- PostgreSQL database dump
--

\restrict A23P1n8PzwYOoH3QwXlHhdqmxOLOmLHdVWG4KV07N3F6ugSaFcGpCJIIpun45hj

-- Dumped from database version 16.15
-- Dumped by pg_dump version 16.15

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.jobs (
    id text NOT NULL,
    player_id text NOT NULL,
    recipe_id text NOT NULL,
    quantity integer DEFAULT 1 NOT NULL,
    status text DEFAULT 'in_progress'::text NOT NULL,
    consumed text DEFAULT '[]'::text NOT NULL,
    produced text,
    base_id text,
    created_at timestamp without time zone NOT NULL,
    completes_at timestamp without time zone
);


--
-- Name: processed_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.processed_events (
    event_id text NOT NULL,
    scope text NOT NULL,
    response text NOT NULL,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: recipes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.recipes (
    id text NOT NULL,
    name text NOT NULL,
    inputs text DEFAULT '[]'::text NOT NULL,
    output text DEFAULT '{}'::text NOT NULL,
    craft_time_seconds integer DEFAULT 0 NOT NULL,
    requires text DEFAULT '{}'::text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: schema_info; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_info (
    version integer DEFAULT 0 NOT NULL
);


--
-- Name: unlocks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.unlocks (
    id text NOT NULL,
    player_id text NOT NULL,
    recipe_id text NOT NULL,
    unlocked_by text,
    unlocked_at timestamp without time zone NOT NULL
);


--
-- Name: jobs jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT jobs_pkey PRIMARY KEY (id);


--
-- Name: processed_events processed_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.processed_events
    ADD CONSTRAINT processed_events_pkey PRIMARY KEY (event_id);


--
-- Name: recipes recipes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipes
    ADD CONSTRAINT recipes_pkey PRIMARY KEY (id);


--
-- Name: unlocks unlocks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.unlocks
    ADD CONSTRAINT unlocks_pkey PRIMARY KEY (id);


--
-- Name: unlocks unlocks_player_id_recipe_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.unlocks
    ADD CONSTRAINT unlocks_player_id_recipe_id_key UNIQUE (player_id, recipe_id);


--
-- Name: jobs_player_id_status_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX jobs_player_id_status_index ON public.jobs USING btree (player_id, status);


--
-- Name: unlocks unlocks_recipe_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.unlocks
    ADD CONSTRAINT unlocks_recipe_id_fkey FOREIGN KEY (recipe_id) REFERENCES public.recipes(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict A23P1n8PzwYOoH3QwXlHhdqmxOLOmLHdVWG4KV07N3F6ugSaFcGpCJIIpun45hj


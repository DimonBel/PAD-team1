--
-- PostgreSQL database dump
--

\restrict ElMqUq4NBkPbm2Ybn8G4hyecA344hTn7cfFkmhlSfVW7ptImbwogOEm56XxJviT

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
-- Name: base_rooms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.base_rooms (
    id text NOT NULL,
    base_id text NOT NULL,
    room_id text NOT NULL,
    reinforced boolean DEFAULT false NOT NULL,
    is_home boolean DEFAULT false NOT NULL,
    barricade_level integer DEFAULT 0 NOT NULL,
    hp integer DEFAULT 0 NOT NULL,
    max_hp integer DEFAULT 0 NOT NULL,
    annexed_at timestamp without time zone NOT NULL
);


--
-- Name: bases; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bases (
    id text NOT NULL,
    lobby_id text NOT NULL,
    map_id text,
    name text DEFAULT 'FAF Cab'::text NOT NULL,
    level integer DEFAULT 1 NOT NULL,
    storage_capacity integer DEFAULT 50 NOT NULL,
    storage_used integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: decorations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.decorations (
    id text NOT NULL,
    base_id text NOT NULL,
    item_id text NOT NULL,
    slot text NOT NULL,
    placed_by text,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: facilities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.facilities (
    id text NOT NULL,
    base_id text NOT NULL,
    facility_type text NOT NULL,
    room_id text NOT NULL,
    level integer DEFAULT 1 NOT NULL,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: kiki_states; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.kiki_states (
    base_id text NOT NULL,
    mood text DEFAULT 'hungry'::text NOT NULL,
    times_fed_today integer DEFAULT 0 NOT NULL,
    cooldown_until timestamp without time zone,
    last_reward text,
    fed_on timestamp without time zone
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
-- Name: schema_info; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_info (
    version integer DEFAULT 0 NOT NULL
);


--
-- Name: upgrades; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.upgrades (
    id text NOT NULL,
    category text NOT NULL,
    name text NOT NULL,
    cost text DEFAULT '[]'::text NOT NULL,
    requires text DEFAULT '{}'::text NOT NULL,
    effect text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: base_rooms base_rooms_base_id_room_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_rooms
    ADD CONSTRAINT base_rooms_base_id_room_id_key UNIQUE (base_id, room_id);


--
-- Name: base_rooms base_rooms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_rooms
    ADD CONSTRAINT base_rooms_pkey PRIMARY KEY (id);


--
-- Name: bases bases_lobby_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bases
    ADD CONSTRAINT bases_lobby_id_key UNIQUE (lobby_id);


--
-- Name: bases bases_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bases
    ADD CONSTRAINT bases_pkey PRIMARY KEY (id);


--
-- Name: decorations decorations_base_id_slot_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.decorations
    ADD CONSTRAINT decorations_base_id_slot_key UNIQUE (base_id, slot);


--
-- Name: decorations decorations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.decorations
    ADD CONSTRAINT decorations_pkey PRIMARY KEY (id);


--
-- Name: facilities facilities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.facilities
    ADD CONSTRAINT facilities_pkey PRIMARY KEY (id);


--
-- Name: kiki_states kiki_states_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kiki_states
    ADD CONSTRAINT kiki_states_pkey PRIMARY KEY (base_id);


--
-- Name: processed_events processed_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.processed_events
    ADD CONSTRAINT processed_events_pkey PRIMARY KEY (event_id);


--
-- Name: upgrades upgrades_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upgrades
    ADD CONSTRAINT upgrades_pkey PRIMARY KEY (id);


--
-- Name: base_rooms base_rooms_base_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_rooms
    ADD CONSTRAINT base_rooms_base_id_fkey FOREIGN KEY (base_id) REFERENCES public.bases(id) ON DELETE CASCADE;


--
-- Name: decorations decorations_base_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.decorations
    ADD CONSTRAINT decorations_base_id_fkey FOREIGN KEY (base_id) REFERENCES public.bases(id) ON DELETE CASCADE;


--
-- Name: facilities facilities_base_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.facilities
    ADD CONSTRAINT facilities_base_id_fkey FOREIGN KEY (base_id) REFERENCES public.bases(id) ON DELETE CASCADE;


--
-- Name: kiki_states kiki_states_base_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kiki_states
    ADD CONSTRAINT kiki_states_base_id_fkey FOREIGN KEY (base_id) REFERENCES public.bases(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict ElMqUq4NBkPbm2Ybn8G4hyecA344hTn7cfFkmhlSfVW7ptImbwogOEm56XxJviT


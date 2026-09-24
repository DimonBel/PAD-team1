--
-- PostgreSQL database dump
--

\restrict OyJZ3DCVxGPnwoQXUwBC0tnPnjFGwBUxCpQD4cbdPahPWdfZEF8Nm2nLeXtlvrk

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

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: actions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.actions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    session_id uuid,
    lobby_id uuid NOT NULL,
    player_id uuid NOT NULL,
    actor_type character varying(255) DEFAULT 'player'::character varying NOT NULL,
    action_type character varying(255) NOT NULL,
    target character varying(255),
    duration_seconds integer NOT NULL,
    status character varying(255) DEFAULT 'in_progress'::character varying NOT NULL,
    started_at timestamp without time zone NOT NULL,
    completes_at timestamp without time zone NOT NULL,
    reward jsonb,
    meta jsonb DEFAULT '{}'::jsonb NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: encounters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.encounters (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    session_id uuid,
    lobby_id uuid NOT NULL,
    player_id uuid NOT NULL,
    zombie_type character varying(255) NOT NULL,
    room_id character varying(255),
    exam_requested boolean DEFAULT false NOT NULL,
    exam_id uuid,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: lobbies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lobbies (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(255) NOT NULL,
    university character varying(255) NOT NULL,
    host_id uuid NOT NULL,
    max_players integer DEFAULT 8 NOT NULL,
    status character varying(255) DEFAULT 'open'::character varying NOT NULL,
    day_cycle integer DEFAULT 1 NOT NULL,
    phase character varying(255) DEFAULT 'day'::character varying NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: lobby_players; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lobby_players (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    lobby_id uuid NOT NULL,
    player_id uuid NOT NULL,
    joined_at timestamp without time zone NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


--
-- Name: session_players; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.session_players (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    session_id uuid NOT NULL,
    player_id uuid NOT NULL,
    health integer DEFAULT 100 NOT NULL,
    current_room_id uuid,
    alive boolean DEFAULT true NOT NULL,
    xp integer DEFAULT 0 NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sessions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    lobby_id uuid NOT NULL,
    status character varying(255) DEFAULT 'RUNNING'::character varying NOT NULL,
    cycle character varying(255) DEFAULT 'DAY'::character varying NOT NULL,
    cycle_number integer DEFAULT 1 NOT NULL,
    cycle_duration_seconds integer DEFAULT 300 NOT NULL,
    semester_length_cycles integer DEFAULT 14 NOT NULL,
    map_id uuid,
    cycle_ends_at timestamp without time zone,
    started_at timestamp without time zone,
    ended_at timestamp without time zone,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: trades; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trades (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    lobby_id uuid NOT NULL,
    from_player_id uuid NOT NULL,
    to_player_id uuid NOT NULL,
    offer jsonb[] DEFAULT ARRAY[]::jsonb[] NOT NULL,
    request jsonb[] DEFAULT ARRAY[]::jsonb[] NOT NULL,
    cross_university boolean DEFAULT false NOT NULL,
    status character varying(255) DEFAULT 'completed'::character varying NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: zombies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.zombies (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    session_id uuid NOT NULL,
    zombie_type character varying(255) NOT NULL,
    room_id uuid,
    health integer DEFAULT 50 NOT NULL,
    damage integer DEFAULT 10 NOT NULL,
    cycle_number integer NOT NULL,
    alive boolean DEFAULT true NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: actions actions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.actions
    ADD CONSTRAINT actions_pkey PRIMARY KEY (id);


--
-- Name: encounters encounters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.encounters
    ADD CONSTRAINT encounters_pkey PRIMARY KEY (id);


--
-- Name: lobbies lobbies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lobbies
    ADD CONSTRAINT lobbies_pkey PRIMARY KEY (id);


--
-- Name: lobby_players lobby_players_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lobby_players
    ADD CONSTRAINT lobby_players_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: session_players session_players_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.session_players
    ADD CONSTRAINT session_players_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: trades trades_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trades
    ADD CONSTRAINT trades_pkey PRIMARY KEY (id);


--
-- Name: zombies zombies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.zombies
    ADD CONSTRAINT zombies_pkey PRIMARY KEY (id);


--
-- Name: actions_lobby_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX actions_lobby_id_index ON public.actions USING btree (lobby_id);


--
-- Name: actions_one_active_per_player; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX actions_one_active_per_player ON public.actions USING btree (player_id) WHERE (((status)::text = 'in_progress'::text) AND ((actor_type)::text = 'player'::text));


--
-- Name: actions_session_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX actions_session_id_index ON public.actions USING btree (session_id);


--
-- Name: actions_status_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX actions_status_index ON public.actions USING btree (status);


--
-- Name: encounters_lobby_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX encounters_lobby_id_index ON public.encounters USING btree (lobby_id);


--
-- Name: lobbies_status_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lobbies_status_index ON public.lobbies USING btree (status);


--
-- Name: lobby_players_lobby_id_player_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX lobby_players_lobby_id_player_id_index ON public.lobby_players USING btree (lobby_id, player_id);


--
-- Name: session_players_session_id_player_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX session_players_session_id_player_id_index ON public.session_players USING btree (session_id, player_id);


--
-- Name: sessions_lobby_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sessions_lobby_id_index ON public.sessions USING btree (lobby_id);


--
-- Name: sessions_status_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sessions_status_index ON public.sessions USING btree (status);


--
-- Name: trades_lobby_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX trades_lobby_id_index ON public.trades USING btree (lobby_id);


--
-- Name: zombies_session_id_alive_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX zombies_session_id_alive_index ON public.zombies USING btree (session_id, alive);


--
-- Name: zombies_session_id_cycle_number_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX zombies_session_id_cycle_number_index ON public.zombies USING btree (session_id, cycle_number);


--
-- Name: actions actions_lobby_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.actions
    ADD CONSTRAINT actions_lobby_id_fkey FOREIGN KEY (lobby_id) REFERENCES public.lobbies(id) ON DELETE CASCADE;


--
-- Name: actions actions_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.actions
    ADD CONSTRAINT actions_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.sessions(id) ON DELETE CASCADE;


--
-- Name: encounters encounters_lobby_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.encounters
    ADD CONSTRAINT encounters_lobby_id_fkey FOREIGN KEY (lobby_id) REFERENCES public.lobbies(id) ON DELETE CASCADE;


--
-- Name: encounters encounters_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.encounters
    ADD CONSTRAINT encounters_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.sessions(id) ON DELETE SET NULL;


--
-- Name: lobby_players lobby_players_lobby_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lobby_players
    ADD CONSTRAINT lobby_players_lobby_id_fkey FOREIGN KEY (lobby_id) REFERENCES public.lobbies(id) ON DELETE CASCADE;


--
-- Name: session_players session_players_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.session_players
    ADD CONSTRAINT session_players_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.sessions(id) ON DELETE CASCADE;


--
-- Name: sessions sessions_lobby_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_lobby_id_fkey FOREIGN KEY (lobby_id) REFERENCES public.lobbies(id) ON DELETE CASCADE;


--
-- Name: trades trades_lobby_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trades
    ADD CONSTRAINT trades_lobby_id_fkey FOREIGN KEY (lobby_id) REFERENCES public.lobbies(id) ON DELETE CASCADE;


--
-- Name: zombies zombies_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.zombies
    ADD CONSTRAINT zombies_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.sessions(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict OyJZ3DCVxGPnwoQXUwBC0tnPnjFGwBUxCpQD4cbdPahPWdfZEF8Nm2nLeXtlvrk


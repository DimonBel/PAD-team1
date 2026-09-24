--
-- PostgreSQL database dump
--

\restrict r6jMgcJ2zNgckrk8mXNVHfg6kVHHnMTnkBWd8D5OdsWFaZvL5eXpH9mBfCoGeTT

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
-- Name: citext; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;


--
-- Name: EXTENSION citext; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: friendships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.friendships (
    id uuid NOT NULL,
    requester_id uuid NOT NULL,
    addressee_id uuid NOT NULL,
    status character varying(255) DEFAULT 'pending'::character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    responded_at timestamp without time zone
);


--
-- Name: idempotency_keys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.idempotency_keys (
    operation_id character varying(255) NOT NULL,
    scope character varying(255) NOT NULL,
    response jsonb NOT NULL,
    status_code integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    expires_at timestamp without time zone NOT NULL
);


--
-- Name: inventory_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.inventory_items (
    id uuid NOT NULL,
    player_id uuid NOT NULL,
    code character varying(255) NOT NULL,
    type character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    quantity integer DEFAULT 1 NOT NULL,
    locked_in_trade_id uuid,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: mock_invocations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mock_invocations (
    id uuid NOT NULL,
    mock_name character varying(255) NOT NULL,
    payload jsonb NOT NULL,
    result jsonb NOT NULL,
    inserted_at timestamp without time zone NOT NULL
);


--
-- Name: player_levels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.player_levels (
    player_id uuid NOT NULL,
    xp integer DEFAULT 0 NOT NULL,
    level integer DEFAULT 1 NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: players; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.players (
    id uuid NOT NULL,
    username public.citext NOT NULL,
    email public.citext NOT NULL,
    password_hash character varying(255) NOT NULL,
    university character varying(255) DEFAULT 'FAF'::character varying,
    title character varying(255) DEFAULT 'Survivor of the Pumpkin'::character varying,
    avatar character varying(255) DEFAULT 'axe_wielding'::character varying,
    status character varying(255) DEFAULT 'active'::character varying NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: presence; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.presence (
    player_id uuid NOT NULL,
    status character varying(255) DEFAULT 'offline'::character varying NOT NULL,
    lobby_id character varying(255),
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
-- Name: trades; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trades (
    id uuid NOT NULL,
    from_player_id uuid NOT NULL,
    to_player_id uuid NOT NULL,
    status character varying(255) DEFAULT 'pending'::character varying NOT NULL,
    offered_items jsonb NOT NULL,
    requested_items jsonb NOT NULL,
    created_at timestamp without time zone NOT NULL,
    expires_at timestamp without time zone NOT NULL,
    completed_at timestamp without time zone
);


--
-- Name: xp_ledger; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.xp_ledger (
    id uuid NOT NULL,
    player_id uuid NOT NULL,
    delta integer NOT NULL,
    reason character varying(255) NOT NULL,
    source_service character varying(255) NOT NULL,
    operation_id character varying(255) NOT NULL,
    xp_after integer NOT NULL,
    level_after integer NOT NULL,
    leveled_up boolean DEFAULT false NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: friendships friendships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.friendships
    ADD CONSTRAINT friendships_pkey PRIMARY KEY (id);


--
-- Name: idempotency_keys idempotency_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.idempotency_keys
    ADD CONSTRAINT idempotency_keys_pkey PRIMARY KEY (operation_id);


--
-- Name: inventory_items inventory_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_items
    ADD CONSTRAINT inventory_items_pkey PRIMARY KEY (id);


--
-- Name: mock_invocations mock_invocations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mock_invocations
    ADD CONSTRAINT mock_invocations_pkey PRIMARY KEY (id);


--
-- Name: player_levels player_levels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.player_levels
    ADD CONSTRAINT player_levels_pkey PRIMARY KEY (player_id);


--
-- Name: players players_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.players
    ADD CONSTRAINT players_pkey PRIMARY KEY (id);


--
-- Name: presence presence_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.presence
    ADD CONSTRAINT presence_pkey PRIMARY KEY (player_id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: trades trades_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trades
    ADD CONSTRAINT trades_pkey PRIMARY KEY (id);


--
-- Name: xp_ledger xp_ledger_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.xp_ledger
    ADD CONSTRAINT xp_ledger_pkey PRIMARY KEY (id);


--
-- Name: friendships_addressee_id_status_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX friendships_addressee_id_status_index ON public.friendships USING btree (addressee_id, status);


--
-- Name: friendships_requester_id_addressee_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX friendships_requester_id_addressee_id_index ON public.friendships USING btree (requester_id, addressee_id);


--
-- Name: friendships_requester_id_status_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX friendships_requester_id_status_index ON public.friendships USING btree (requester_id, status);


--
-- Name: idempotency_keys_expires_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idempotency_keys_expires_at_index ON public.idempotency_keys USING btree (expires_at);


--
-- Name: inventory_items_code_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX inventory_items_code_index ON public.inventory_items USING btree (code);


--
-- Name: inventory_items_locked_in_trade_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX inventory_items_locked_in_trade_id_index ON public.inventory_items USING btree (locked_in_trade_id);


--
-- Name: inventory_items_player_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX inventory_items_player_id_index ON public.inventory_items USING btree (player_id);


--
-- Name: mock_invocations_mock_name_inserted_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mock_invocations_mock_name_inserted_at_index ON public.mock_invocations USING btree (mock_name, inserted_at);


--
-- Name: players_email_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX players_email_index ON public.players USING btree (email);


--
-- Name: players_status_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX players_status_index ON public.players USING btree (status);


--
-- Name: players_username_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX players_username_index ON public.players USING btree (username);


--
-- Name: trades_from_player_id_status_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX trades_from_player_id_status_index ON public.trades USING btree (from_player_id, status);


--
-- Name: trades_status_expires_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX trades_status_expires_at_index ON public.trades USING btree (status, expires_at);


--
-- Name: trades_to_player_id_status_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX trades_to_player_id_status_index ON public.trades USING btree (to_player_id, status);


--
-- Name: xp_ledger_operation_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX xp_ledger_operation_id_index ON public.xp_ledger USING btree (operation_id);


--
-- Name: xp_ledger_player_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX xp_ledger_player_id_index ON public.xp_ledger USING btree (player_id);


--
-- Name: friendships friendships_addressee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.friendships
    ADD CONSTRAINT friendships_addressee_id_fkey FOREIGN KEY (addressee_id) REFERENCES public.players(id) ON DELETE CASCADE;


--
-- Name: friendships friendships_requester_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.friendships
    ADD CONSTRAINT friendships_requester_id_fkey FOREIGN KEY (requester_id) REFERENCES public.players(id) ON DELETE CASCADE;


--
-- Name: inventory_items inventory_items_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_items
    ADD CONSTRAINT inventory_items_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.players(id) ON DELETE CASCADE;


--
-- Name: player_levels player_levels_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.player_levels
    ADD CONSTRAINT player_levels_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.players(id) ON DELETE CASCADE;


--
-- Name: presence presence_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.presence
    ADD CONSTRAINT presence_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.players(id) ON DELETE CASCADE;


--
-- Name: trades trades_from_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trades
    ADD CONSTRAINT trades_from_player_id_fkey FOREIGN KEY (from_player_id) REFERENCES public.players(id) ON DELETE CASCADE;


--
-- Name: trades trades_to_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trades
    ADD CONSTRAINT trades_to_player_id_fkey FOREIGN KEY (to_player_id) REFERENCES public.players(id) ON DELETE CASCADE;


--
-- Name: xp_ledger xp_ledger_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.xp_ledger
    ADD CONSTRAINT xp_ledger_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.players(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict r6jMgcJ2zNgckrk8mXNVHfg6kVHHnMTnkBWd8D5OdsWFaZvL5eXpH9mBfCoGeTT


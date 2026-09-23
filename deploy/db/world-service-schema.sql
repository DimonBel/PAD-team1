--
-- PostgreSQL database dump
--

\restrict ad9uaLU22DHTYzbsqCUMmyoO3536dvhWKtmRlCeOAShfkF0bPVTHjxkc6qiOP4y

-- Dumped from database version 16.14
-- Dumped by pg_dump version 16.14

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
-- Name: maps; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.maps (
    id uuid NOT NULL,
    name character varying(255) NOT NULL,
    version integer DEFAULT 1 NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: resource_nodes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.resource_nodes (
    id uuid NOT NULL,
    room_id character varying(255) NOT NULL,
    resource character varying(255) NOT NULL,
    remaining integer NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: rooms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rooms (
    id character varying(255) NOT NULL,
    zone_id character varying(255) NOT NULL,
    type character varying(255) NOT NULL,
    resource character varying(255) NOT NULL,
    barricade_level integer DEFAULT 0 NOT NULL,
    barricade_event_id character varying(255),
    x integer,
    y integer,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


--
-- Name: zombie_spawns; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.zombie_spawns (
    id uuid NOT NULL,
    room_id character varying(255) NOT NULL,
    zombie_type character varying(255) NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: zones; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.zones (
    id character varying(255) NOT NULL,
    map_id uuid,
    name character varying(255) NOT NULL,
    unlocked boolean DEFAULT false NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    unlock_event_id character varying(255)
);


--
-- Name: maps maps_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maps
    ADD CONSTRAINT maps_pkey PRIMARY KEY (id);


--
-- Name: resource_nodes resource_nodes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resource_nodes
    ADD CONSTRAINT resource_nodes_pkey PRIMARY KEY (id);


--
-- Name: rooms rooms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT rooms_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: zombie_spawns zombie_spawns_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.zombie_spawns
    ADD CONSTRAINT zombie_spawns_pkey PRIMARY KEY (id);


--
-- Name: zones zones_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.zones
    ADD CONSTRAINT zones_pkey PRIMARY KEY (id);


--
-- Name: resource_nodes_room_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX resource_nodes_room_id_index ON public.resource_nodes USING btree (room_id);


--
-- Name: rooms_zone_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX rooms_zone_id_index ON public.rooms USING btree (zone_id);


--
-- Name: zombie_spawns_room_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX zombie_spawns_room_id_index ON public.zombie_spawns USING btree (room_id);


--
-- Name: zones_map_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX zones_map_id_index ON public.zones USING btree (map_id);


--
-- Name: zones_unlock_event_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX zones_unlock_event_id_index ON public.zones USING btree (unlock_event_id);


--
-- Name: resource_nodes resource_nodes_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resource_nodes
    ADD CONSTRAINT resource_nodes_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(id) ON DELETE CASCADE;


--
-- Name: rooms rooms_zone_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT rooms_zone_id_fkey FOREIGN KEY (zone_id) REFERENCES public.zones(id) ON DELETE RESTRICT;


--
-- Name: zombie_spawns zombie_spawns_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.zombie_spawns
    ADD CONSTRAINT zombie_spawns_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(id) ON DELETE CASCADE;


--
-- Name: zones zones_map_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.zones
    ADD CONSTRAINT zones_map_id_fkey FOREIGN KEY (map_id) REFERENCES public.maps(id) ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--

\unrestrict ad9uaLU22DHTYzbsqCUMmyoO3536dvhWKtmRlCeOAShfkF0bPVTHjxkc6qiOP4y


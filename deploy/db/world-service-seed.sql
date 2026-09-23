--
-- PostgreSQL database dump
--

\restrict WRdFikLgKfEcHzVPdVir5za4CrDLBdJD6KRjSRDpDxxgVTPDgeeUxdTEyN9guXp

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

--
-- Data for Name: maps; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.maps (id, name, version, inserted_at, updated_at) FROM stdin;
11111111-1111-1111-1111-111111111111	FAF Campus	1	2026-09-23 21:03:21	2026-09-23 21:03:21
\.


--
-- Data for Name: zones; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.zones (id, map_id, name, unlocked, inserted_at, updated_at, unlock_event_id) FROM stdin;
zone-cab	11111111-1111-1111-1111-111111111111	FAF Cab	t	2026-09-23 21:03:21	2026-09-23 21:03:21	\N
zone-math-wing	11111111-1111-1111-1111-111111111111	Math Wing	f	2026-09-23 21:03:21	2026-09-23 21:03:21	\N
\.


--
-- Data for Name: rooms; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.rooms (id, zone_id, type, resource, barricade_level, barricade_event_id, x, y, inserted_at, updated_at) FROM stdin;
faf-cab	zone-cab	canteen	food	0	\N	0	0	2026-09-23 21:03:21	2026-09-23 21:03:21
lab-a1	zone-cab	laboratory	metal_scraps	1	seed-barricade-lab-a1	1	0	2026-09-23 21:03:21	2026-09-23 21:03:21
library-b1	zone-cab	library	paper	0	\N	2	0	2026-09-23 21:03:21	2026-09-23 21:03:21
canteen-b1	zone-cab	canteen	food	0	\N	0	1	2026-09-23 21:03:21	2026-09-23 21:03:21
classroom-a1	zone-cab	classroom	textbooks	0	\N	1	1	2026-09-23 21:03:21	2026-09-23 21:03:21
classroom-b2	zone-cab	classroom	textbooks	2	seed-barricade-classroom-b2	2	1	2026-09-23 21:03:21	2026-09-23 21:03:21
\.


--
-- Data for Name: resource_nodes; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.resource_nodes (id, room_id, resource, remaining, inserted_at, updated_at) FROM stdin;
22222222-2222-2222-2222-222222222221	faf-cab	food	30	2026-09-23 21:03:21	2026-09-23 21:03:21
22222222-2222-2222-2222-222222222222	lab-a1	metal_scraps	40	2026-09-23 21:03:21	2026-09-23 21:03:21
22222222-2222-2222-2222-222222222223	library-b1	paper	50	2026-09-23 21:03:21	2026-09-23 21:03:21
22222222-2222-2222-2222-222222222224	canteen-b1	food	25	2026-09-23 21:03:21	2026-09-23 21:03:21
22222222-2222-2222-2222-222222222225	classroom-a1	textbooks	35	2026-09-23 21:03:21	2026-09-23 21:03:21
22222222-2222-2222-2222-222222222226	classroom-b2	textbooks	20	2026-09-23 21:03:21	2026-09-23 21:03:21
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.schema_migrations (version, inserted_at) FROM stdin;
20260920221926	2026-09-23 21:03:10
20260920221927	2026-09-23 21:03:10
20260920221928	2026-09-23 21:03:10
20260921183618	2026-09-23 21:03:10
20260921184610	2026-09-23 21:03:10
20260921185035	2026-09-23 21:03:10
\.


--
-- Data for Name: zombie_spawns; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.zombie_spawns (id, room_id, zombie_type, inserted_at, updated_at) FROM stdin;
33333333-3333-3333-3333-333333333331	lab-a1	professor_zombie	2026-09-23 21:03:21	2026-09-23 21:03:21
33333333-3333-3333-3333-333333333332	classroom-a1	professor_zombie	2026-09-23 21:03:21	2026-09-23 21:03:21
33333333-3333-3333-3333-333333333333	classroom-b2	professor_zombie	2026-09-23 21:03:21	2026-09-23 21:03:21
33333333-3333-3333-3333-333333333334	library-b1	tourist_zombie	2026-09-23 21:03:21	2026-09-23 21:03:21
33333333-3333-3333-3333-333333333335	canteen-b1	tourist_zombie	2026-09-23 21:03:21	2026-09-23 21:03:21
33333333-3333-3333-3333-333333333336	faf-cab	tourist_zombie	2026-09-23 21:03:21	2026-09-23 21:03:21
33333333-3333-3333-3333-333333333337	lab-a1	tourist_zombie	2026-09-23 21:03:21	2026-09-23 21:03:21
\.


--
-- PostgreSQL database dump complete
--

\unrestrict WRdFikLgKfEcHzVPdVir5za4CrDLBdJD6KRjSRDpDxxgVTPDgeeUxdTEyN9guXp


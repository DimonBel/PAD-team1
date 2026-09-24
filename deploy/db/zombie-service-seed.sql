--
-- PostgreSQL database dump
--

\restrict zxI363GFEwhcC7cJ5RpsNeuC3kS8reeSNWaUVKcNjYR8XHbB4QFpuNjxQt67QXX

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
-- Data for Name: schema_info; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.schema_info (version) FROM stdin;
1
\.


--
-- Data for Name: zombie_types; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.zombie_types (type_id, name, health, damage, speed, loot_table_id, behaviours, created_at, updated_at) FROM stdin;
professor_zombie	Professor Zombie	100	15	1.2	loot-professor-01	[{"trigger":"player_nearby","action":"chase","range_tiles":5},{"trigger":"player_in_room","action":"steal","max_items":2},{"trigger":"day_phase","action":"hide","location":"exam_hall"}]	2026-09-23 21:09:35.441983	2026-09-23 21:09:35.441983
fast_zombie	Caffeinated Sprinter	60	10	3	loot-sprinter-01	[{"trigger":"player_nearby","action":"chase","range_tiles":8}]	2026-09-23 21:09:35.44742	2026-09-23 21:09:35.44742
tourist_zombie	Tourist Zombie	80	12	1.5	loot-tourist-01	[{"trigger":"player_nearby","action":"chase","range_tiles":5}]	2026-09-23 21:09:35.450225	2026-09-23 21:09:35.450225
\.


--
-- Data for Name: zombie_instances; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.zombie_instances (zombie_id, type_id, lobby_id, health, room_id, status, phase, target_player_id, created_at, updated_at) FROM stdin;
zombie-uuid-001	professor_zombie	lobby-uuid-789	60	canteen	stealing	day	player-uuid-123	2026-09-23 21:09:35.453508	2026-09-23 21:09:35.453508
zombie-uuid-002	fast_zombie	lobby-uuid-789	60	exam-hall-3	idle	day	\N	2026-09-23 21:09:35.462104	2026-09-23 21:09:35.462104
\.


--
-- Data for Name: zombie_inventory_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.zombie_inventory_items (id, zombie_id, item_id, count) FROM stdin;
1	zombie-uuid-001	coffee-01	1
2	zombie-uuid-001	metal-01	3
\.


--
-- Name: zombie_inventory_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.zombie_inventory_items_id_seq', 2, true);


--
-- PostgreSQL database dump complete
--

\unrestrict zxI363GFEwhcC7cJ5RpsNeuC3kS8reeSNWaUVKcNjYR8XHbB4QFpuNjxQt67QXX


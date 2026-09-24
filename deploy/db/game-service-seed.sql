--
-- PostgreSQL database dump
--

\restrict aGBHdkYdftGlY3aaInGdthqETnh4lQZ3FxcS9Dt6fxBhhDg2bBhRMF6ehmtrhCL

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
-- Data for Name: lobbies; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.lobbies (id, name, university, host_id, max_players, status, day_cycle, phase, inserted_at, updated_at) FROM stdin;
252f386f-523a-49c5-95fe-cf735249445b	Cab Survivors	FAF	11111111-1111-1111-1111-111111111111	8	open	1	day	2026-09-24 11:46:25.480262	2026-09-24 11:46:25.480262
03fb2c79-8f6e-461f-94c9-3ddc5940f49f	Block 3 Holdouts	FAF	33333333-3333-3333-3333-333333333333	4	in_game	2	night	2026-09-24 11:46:25.483409	2026-09-24 11:46:25.483409
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sessions (id, lobby_id, status, cycle, cycle_number, cycle_duration_seconds, semester_length_cycles, map_id, cycle_ends_at, started_at, ended_at, inserted_at, updated_at) FROM stdin;
82c633dd-37f6-4c22-8de4-8c0c74ffe0a2	03fb2c79-8f6e-461f-94c9-3ddc5940f49f	RUNNING	NIGHT	2	300	14	5f1d9a10-0000-4000-8000-000000000005	2026-09-24 11:51:25.484165	2026-09-24 11:36:25.484165	\N	2026-09-24 11:46:25.486544	2026-09-24 11:46:25.486544
\.


--
-- Data for Name: actions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.actions (id, session_id, lobby_id, player_id, actor_type, action_type, target, duration_seconds, status, started_at, completes_at, reward, meta, inserted_at, updated_at) FROM stdin;
95f12c33-fcb1-4fdd-85bb-afd5899e12d7	82c633dd-37f6-4c22-8de4-8c0c74ffe0a2	03fb2c79-8f6e-461f-94c9-3ddc5940f49f	33333333-3333-3333-3333-333333333333	player	chop_bench	bench-room-A1	600	in_progress	2026-09-24 11:45:25.484165	2026-09-24 11:55:25.484165	\N	{}	2026-09-24 11:46:25.489103	2026-09-24 11:46:25.489103
\.


--
-- Data for Name: encounters; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.encounters (id, session_id, lobby_id, player_id, zombie_type, room_id, exam_requested, exam_id, inserted_at, updated_at) FROM stdin;
\.


--
-- Data for Name: lobby_players; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.lobby_players (id, lobby_id, player_id, joined_at, inserted_at, updated_at) FROM stdin;
7ea6db3f-9f10-4496-bf01-5a5208fac417	252f386f-523a-49c5-95fe-cf735249445b	11111111-1111-1111-1111-111111111111	2026-09-24 11:46:25.482164	2026-09-24 11:46:25.482173	2026-09-24 11:46:25.482173
b6d921a2-a9b9-48e9-a530-dd662a125660	252f386f-523a-49c5-95fe-cf735249445b	22222222-2222-2222-2222-222222222222	2026-09-24 11:46:25.482849	2026-09-24 11:46:25.482861	2026-09-24 11:46:25.482861
ea9dc9c4-8394-439c-9f11-241f340e32bf	03fb2c79-8f6e-461f-94c9-3ddc5940f49f	33333333-3333-3333-3333-333333333333	2026-09-24 11:46:25.483707	2026-09-24 11:46:25.483711	2026-09-24 11:46:25.483711
f18f9dd6-4fd4-49bd-bf78-bd89e2e88f93	03fb2c79-8f6e-461f-94c9-3ddc5940f49f	11111111-1111-1111-1111-111111111111	2026-09-24 11:46:25.483924	2026-09-24 11:46:25.483927	2026-09-24 11:46:25.483927
\.


--
-- Data for Name: session_players; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.session_players (id, session_id, player_id, health, current_room_id, alive, xp, inserted_at, updated_at) FROM stdin;
2fb06f04-d468-405a-acb4-d239a3e99655	82c633dd-37f6-4c22-8de4-8c0c74ffe0a2	33333333-3333-3333-3333-333333333333	100	a1000000-0000-4000-8000-000000000001	t	120	2026-09-24 11:46:25.487549	2026-09-24 11:46:25.487549
4c890102-9f75-409d-ac55-8c3d84bc921f	82c633dd-37f6-4c22-8de4-8c0c74ffe0a2	11111111-1111-1111-1111-111111111111	80	a1000000-0000-4000-8000-000000000002	t	45	2026-09-24 11:46:25.488173	2026-09-24 11:46:25.488173
\.


--
-- Data for Name: trades; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.trades (id, lobby_id, from_player_id, to_player_id, offer, request, cross_university, status, inserted_at, updated_at) FROM stdin;
\.


--
-- Data for Name: zombies; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.zombies (id, session_id, zombie_type, room_id, health, damage, cycle_number, alive, inserted_at, updated_at) FROM stdin;
7d0c0d34-6825-4a0d-8906-b6c1757ba3f6	82c633dd-37f6-4c22-8de4-8c0c74ffe0a2	STUDENT	a1000000-0000-4000-8000-000000000001	40	8	2	t	2026-09-24 11:46:25.489719	2026-09-24 11:46:25.489719
88af0d2d-4732-411c-a60c-2a4cabb9fe61	82c633dd-37f6-4c22-8de4-8c0c74ffe0a2	PROFESSOR	a1000000-0000-4000-8000-000000000002	90	20	2	t	2026-09-24 11:46:25.490368	2026-09-24 11:46:25.490368
\.


--
-- PostgreSQL database dump complete
--

\unrestrict aGBHdkYdftGlY3aaInGdthqETnh4lQZ3FxcS9Dt6fxBhhDg2bBhRMF6ehmtrhCL


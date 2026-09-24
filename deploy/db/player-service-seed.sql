--
-- PostgreSQL database dump
--

\restrict R0yhT6PibXyg4wQqyAVpKxZsleuoTQ1WRKlIkuAG6j1bbUT4eOJe6ZAV4YrbESX

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
-- Data for Name: players; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.players (id, username, email, password_hash, university, title, avatar, status, inserted_at, updated_at) FROM stdin;
86d2cab8-f8e9-4888-b3cd-07c78192083c	undead_survivor	alice@faf.university	$2b$12$I.ZijXOsYZ8B/XvCajJFturVSC.GykxIi6Om7xLQvG3uuEOJPFkXS	FAF	Survivor of the Pumpkin	axe_wielding	active	2026-09-24 11:52:35	2026-09-24 11:52:35
f407642b-18b5-4072-8260-d80b3c4e120f	kiki	kiki@faf.university	$2b$12$f77z2JvmdQ9CnawsXwU9QuJr/xItazkS0kAFjVj9cduTldzr7h/mS	FAF	Survivor of the Pumpkin	axe_wielding	active	2026-09-24 11:52:35	2026-09-24 11:52:35
2b564a3e-48f4-42eb-82c3-79959b224042	pumpkin_slayer	carol@faf.university	$2b$12$DLRq5wcG8oetLCMZIjVqG.9t9be5dGvHy7OY6Zhxy5RxasJmCqWeO	FAF	Survivor of the Pumpkin	axe_wielding	active	2026-09-24 11:52:35	2026-09-24 11:52:35
\.


--
-- Data for Name: friendships; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.friendships (id, requester_id, addressee_id, status, created_at, responded_at) FROM stdin;
\.


--
-- Data for Name: idempotency_keys; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.idempotency_keys (operation_id, scope, response, status_code, created_at, expires_at) FROM stdin;
bdc2fbb4-497e-4a2c-8a34-f0502ec33cc2	grant_item	{"code": "COFFEE", "item_id": "59184617-3e33-42a5-8d03-1cd8bc87a06f", "quantity": 3}	201	2026-09-24 11:52:35.757651	2026-09-25 11:52:35.757651
601f09e9-bab8-459b-b8be-a726a3ac0c76	grant_item	{"code": "ENERGY_DRINK", "item_id": "6aba8273-32ca-4900-a170-332939d269d6", "quantity": 1}	201	2026-09-24 11:52:35.764607	2026-09-25 11:52:35.764607
180f758c-eae8-491b-b171-d3381f40a2cd	grant_item	{"code": "DAVIDAN_SANDWICH", "item_id": "a46f20ee-bca6-408e-a373-8f38afee0ff7", "quantity": 2}	201	2026-09-24 11:52:35.767652	2026-09-25 11:52:35.767652
c47dbc40-279f-4cd5-8e2e-32cb746e4253	grant_item	{"code": "IMPROVISED_AXE", "item_id": "1366aea0-569c-4cd9-8a04-768dcccdd7cd", "quantity": 1}	201	2026-09-24 11:52:35.770076	2026-09-25 11:52:35.770076
fb386aa5-f6ef-432b-aad0-f856d785358c	grant_item	{"code": "COFFEE", "item_id": "14d01446-1899-4a2f-af16-5ef4cbf32c7d", "quantity": 1}	201	2026-09-24 11:52:35.77212	2026-09-25 11:52:35.77212
355a4cb7-9c82-4084-91d2-03217db8fa18	grant_item	{"code": "ENERGY_DRINK", "item_id": "c9fe2755-42a2-4b50-b07a-77b0088eaa60", "quantity": 2}	201	2026-09-24 11:52:35.773245	2026-09-25 11:52:35.773245
9c4630a9-53a4-4362-a9a0-9d4b2edd4672	grant_item	{"code": "ZOMBIE_DETECTOR", "item_id": "54280124-972c-4608-8779-1d021b7f331b", "quantity": 1}	201	2026-09-24 11:52:35.774409	2026-09-25 11:52:35.774409
7f0fb70a-3adc-48c1-bf5a-257f85b0ab01	grant_item	{"code": "PUMPKIN_HELMET", "item_id": "cd64e5b5-017b-4d2f-b4ef-59db32d517e5", "quantity": 1}	201	2026-09-24 11:52:35.775431	2026-09-25 11:52:35.775431
\.


--
-- Data for Name: inventory_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.inventory_items (id, player_id, code, type, name, quantity, locked_in_trade_id, inserted_at, updated_at) FROM stdin;
59184617-3e33-42a5-8d03-1cd8bc87a06f	86d2cab8-f8e9-4888-b3cd-07c78192083c	COFFEE	consumable	Coffee	3	\N	2026-09-24 11:52:35	2026-09-24 11:52:35
6aba8273-32ca-4900-a170-332939d269d6	86d2cab8-f8e9-4888-b3cd-07c78192083c	ENERGY_DRINK	consumable	Energy Drink	1	\N	2026-09-24 11:52:35	2026-09-24 11:52:35
a46f20ee-bca6-408e-a373-8f38afee0ff7	86d2cab8-f8e9-4888-b3cd-07c78192083c	DAVIDAN_SANDWICH	consumable	Davidan Sandwich	2	\N	2026-09-24 11:52:35	2026-09-24 11:52:35
1366aea0-569c-4cd9-8a04-768dcccdd7cd	86d2cab8-f8e9-4888-b3cd-07c78192083c	IMPROVISED_AXE	equipment	Improvised Axe	1	\N	2026-09-24 11:52:35	2026-09-24 11:52:35
14d01446-1899-4a2f-af16-5ef4cbf32c7d	f407642b-18b5-4072-8260-d80b3c4e120f	COFFEE	consumable	Coffee	1	\N	2026-09-24 11:52:35	2026-09-24 11:52:35
c9fe2755-42a2-4b50-b07a-77b0088eaa60	f407642b-18b5-4072-8260-d80b3c4e120f	ENERGY_DRINK	consumable	Energy Drink	2	\N	2026-09-24 11:52:35	2026-09-24 11:52:35
54280124-972c-4608-8779-1d021b7f331b	2b564a3e-48f4-42eb-82c3-79959b224042	ZOMBIE_DETECTOR	equipment	Zombie Detector	1	\N	2026-09-24 11:52:35	2026-09-24 11:52:35
cd64e5b5-017b-4d2f-b4ef-59db32d517e5	2b564a3e-48f4-42eb-82c3-79959b224042	PUMPKIN_HELMET	cosmetic	Pumpkin Helmet	1	\N	2026-09-24 11:52:35	2026-09-24 11:52:35
\.


--
-- Data for Name: mock_invocations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mock_invocations (id, mock_name, payload, result, inserted_at) FROM stdin;
\.


--
-- Data for Name: player_levels; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.player_levels (player_id, xp, level, updated_at) FROM stdin;
\.


--
-- Data for Name: presence; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.presence (player_id, status, lobby_id, updated_at) FROM stdin;
\.


--
-- Data for Name: trades; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.trades (id, from_player_id, to_player_id, status, offered_items, requested_items, created_at, expires_at, completed_at) FROM stdin;
\.


--
-- Data for Name: xp_ledger; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.xp_ledger (id, player_id, delta, reason, source_service, operation_id, xp_after, level_after, leveled_up, inserted_at, updated_at) FROM stdin;
\.


--
-- PostgreSQL database dump complete
--

\unrestrict R0yhT6PibXyg4wQqyAVpKxZsleuoTQ1WRKlIkuAG6j1bbUT4eOJe6ZAV4YrbESX


--
-- PostgreSQL database dump
--

\restrict F9Lefj7QVdE1JtXyw7rZ4ZogS7z7awqmka4Ipqv2aHsMnfTcbWv4z0cAMfTiOq2

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
-- Data for Name: resource_entities; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.resource_entities (id, entity_type, entity_id) FROM stdin;
1	player	player-uuid-123
2	zombie	zombie-uuid-001
3	base	base-uuid-001
4	crafting_job	job-uuid-001
\.


--
-- Data for Name: entity_resources; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.entity_resources (id, entity_id_ref, entity_type, entity_id, item_id, count) FROM stdin;
\.


--
-- Data for Name: processed_events; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.processed_events (event_id, scope, response, created_at) FROM stdin;
\.


--
-- Data for Name: resource_points; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.resource_points (point_id, room_id, resource, amount, max_amount, created_at, updated_at) FROM stdin;
point-uuid-001	lab-204	metal-01	12	30	2026-09-24 01:55:59.934526	2026-09-24 01:55:59.934526
point-uuid-002	canteen	food-01	30	50	2026-09-24 01:55:59.938954	2026-09-24 01:55:59.938954
point-uuid-003	lab-204	wood-01	6	20	2026-09-24 01:55:59.943791	2026-09-24 01:55:59.943791
\.


--
-- Data for Name: resource_transactions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.resource_transactions (transaction_id, event_id, type, source, target, items_transferred, status, created_at) FROM stdin;
\.


--
-- Data for Name: schema_info; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.schema_info (version) FROM stdin;
1
\.


--
-- Name: entity_resources_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.entity_resources_id_seq', 1, false);


--
-- Name: resource_entities_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.resource_entities_id_seq', 4, true);


--
-- PostgreSQL database dump complete
--

\unrestrict F9Lefj7QVdE1JtXyw7rZ4ZogS7z7awqmka4Ipqv2aHsMnfTcbWv4z0cAMfTiOq2


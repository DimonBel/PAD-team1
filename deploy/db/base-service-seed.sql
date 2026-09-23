--
-- PostgreSQL database dump
--

\restrict se6QqJsMtsbSuiwsW1prBG2hAz6fcXAazwbDBWCKB8dMDcLpJ1LjP0wp102Fk6v

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
-- Data for Name: upgrades; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.upgrades (id, category, name, cost, requires, effect, created_at, updated_at) FROM stdin;
workbench	facility	Workbench	[{"item_id":"wood-01","count":8},{"item_id":"metal-01","count":4}]	{"base_level":1}	unlocks crafting at the base	2026-09-23 06:01:22.319622	2026-09-23 06:01:22.319622
coffee_machine	facility	Coffee Machine	[{"item_id":"metal-01","count":6},{"item_id":"electronics-01","count":1}]	{"base_level":1}	restores stamina faster	2026-09-23 06:01:22.319622	2026-09-23 06:01:22.319622
infirmary	facility	Infirmary	[{"item_id":"wood-01","count":12},{"item_id":"chemicals-01","count":3}]	{"base_level":2}	heals players between runs	2026-09-23 06:01:22.319622	2026-09-23 06:01:22.319622
watchtower	facility	Watchtower	[{"item_id":"wood-01","count":20},{"item_id":"metal-01","count":8}]	{"base_level":3}	reveals zombies one room away	2026-09-23 06:01:22.319622	2026-09-23 06:01:22.319622
room_expansion	expansion	Room Expansion	[{"item_id":"wood-01","count":10}]	{"base_level":1}	annex one more room	2026-09-23 06:01:22.319622	2026-09-23 06:01:22.319622
storage_t2	storage	Storage tier 2	[{"item_id":"wood-01","count":12}]	{"base_level":1,"after_capacity":50,"capacity_gain":30}	+30 capacity	2026-09-23 06:01:22.319622	2026-09-23 06:01:22.319622
storage_t3	storage	Storage tier 3	[{"item_id":"wood-01","count":24},{"item_id":"metal-01","count":6}]	{"base_level":2,"after_capacity":80,"capacity_gain":40}	+40 capacity	2026-09-23 06:01:22.319622	2026-09-23 06:01:22.319622
\.


--
-- PostgreSQL database dump complete
--

\unrestrict se6QqJsMtsbSuiwsW1prBG2hAz6fcXAazwbDBWCKB8dMDcLpJ1LjP0wp102Fk6v


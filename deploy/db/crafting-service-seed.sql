--
-- PostgreSQL database dump
--

\restrict EnU6zSWC9UeumtbQaHBqSoZ56TB235FYo8tR6hhCkWHWxuYM7TkjU3iddNz7rcX

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
-- Data for Name: recipes; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.recipes (id, name, inputs, output, craft_time_seconds, requires, created_at, updated_at) FROM stdin;
barricade_kit	Barricade Kit	[{"item_id":"wood-01","count":3},{"item_id":"metal-01","count":1}]	{"code":"BARRICADE_KIT","type":"equipment","quantity":1}	60	{"player_level":1,"facility":"workbench"}	2026-09-23 06:04:10.20146	2026-09-23 06:04:10.20146
improvised_weapon	Improvised Weapon	[{"item_id":"paper-01","count":2},{"item_id":"metal-01","count":2}]	{"code":"IMPROVISED_WEAPON","type":"equipment","quantity":1}	90	{"player_level":2,"facility":"workbench"}	2026-09-23 06:04:10.20146	2026-09-23 06:04:10.20146
energy_booster	Energy Booster	[{"item_id":"food-01","count":2},{"item_id":"chemicals-01","count":1}]	{"code":"ENERGY_BOOSTER","type":"consumable","quantity":1}	30	{"player_level":1}	2026-09-23 06:04:10.20146	2026-09-23 06:04:10.20146
zombie_detector	Zombie Detector	[{"item_id":"metal-01","count":4},{"item_id":"electronics-01","count":2}]	{"code":"ZOMBIE_DETECTOR","type":"equipment","quantity":1}	180	{"zone_id":"zone-lab-wing","player_level":5}	2026-09-23 06:04:10.20146	2026-09-23 06:04:10.20146
exam_cheat_sheet	Exam Cheat Sheet	[{"item_id":"paper-01","count":3},{"item_id":"wood-01","count":1}]	{"code":"EXAM_CHEAT_SHEET","type":"consumable","quantity":1}	45	{"course_id":"math-101"}	2026-09-23 06:04:10.20146	2026-09-23 06:04:10.20146
\.


--
-- PostgreSQL database dump complete
--

\unrestrict EnU6zSWC9UeumtbQaHBqSoZ56TB235FYo8tR6hhCkWHWxuYM7TkjU3iddNz7rcX


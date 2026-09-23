--
-- PostgreSQL database dump
--

\restrict hViRUfaSdaddoxGklqvQelyG0Jj2jOQXpEuNTgFxE9aOJYr0R5LQpa867Xqz3Ye

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
-- Data for Name: academic_records; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.academic_records (player_id, grades, achievements, inserted_at, updated_at) FROM stdin;
player-1	{"{\\"grade\\": 100, \\"status\\": \\"passed\\", \\"exam_id\\": \\"44444444-4444-4444-4444-444444444441\\", \\"course_id\\": \\"math-101\\"}"}	{}	2026-09-23 21:03:21	2026-09-23 21:03:21
player-2	{"{\\"grade\\": 0, \\"status\\": \\"failed\\", \\"exam_id\\": \\"44444444-4444-4444-4444-444444444442\\", \\"course_id\\": \\"chem-201\\"}"}	{}	2026-09-23 21:03:21	2026-09-23 21:03:21
\.


--
-- Data for Name: courses; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.courses (course_id, name, required_exam_ids, inserted_at, updated_at) FROM stdin;
math-101	Calculus I	{44444444-4444-4444-4444-444444444441}	2026-09-23 21:03:21	2026-09-23 21:03:21
chem-201	Chemistry I	{44444444-4444-4444-4444-444444444442}	2026-09-23 21:03:21	2026-09-23 21:03:21
\.


--
-- Data for Name: exams; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.exams (id, course_id, title, difficulty, questions, inserted_at, updated_at) FROM stdin;
44444444-4444-4444-4444-444444444441	math-101	Calculus Final	hard	{"{\\"text\\": \\"2 + 2 = ?\\", \\"options\\": [\\"3\\", \\"4\\", \\"5\\"], \\"question_id\\": \\"q-1\\", \\"correct_answer\\": \\"4\\"}","{\\"text\\": \\"3 + 3 = ?\\", \\"options\\": [\\"5\\", \\"6\\", \\"7\\"], \\"question_id\\": \\"q-2\\", \\"correct_answer\\": \\"6\\"}"}	2026-09-23 21:03:21	2026-09-23 21:03:21
44444444-4444-4444-4444-444444444442	chem-201	Chemistry Midterm	medium	{"{\\"text\\": \\"H2O is commonly known as?\\", \\"options\\": [\\"salt\\", \\"water\\", \\"sugar\\"], \\"question_id\\": \\"q-1\\", \\"correct_answer\\": \\"water\\"}"}	2026-09-23 21:03:21	2026-09-23 21:03:21
\.


--
-- Data for Name: exam_attempts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.exam_attempts (id, exam_id, course_id, player_id, status, expires_at, answers, score, passed, graded_at, inserted_at, updated_at) FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.schema_migrations (version, inserted_at) FROM stdin;
20260920170325	2026-09-23 21:03:05
20260920170326	2026-09-23 21:03:05
20260920193027	2026-09-23 21:03:06
20260920194838	2026-09-23 21:03:06
\.


--
-- PostgreSQL database dump complete
--

\unrestrict hViRUfaSdaddoxGklqvQelyG0Jj2jOQXpEuNTgFxE9aOJYr0R5LQpa867Xqz3Ye


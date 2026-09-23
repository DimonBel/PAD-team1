--
-- PostgreSQL database dump
--

\restrict CetbtXb8usIrg6bvhBesuS8ood5Cc8eZtPnUn2h6MYnsAyUvtvLmHplvnwzhwiF

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
-- Name: academic_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.academic_records (
    player_id character varying(255) NOT NULL,
    grades jsonb[] DEFAULT ARRAY[]::jsonb[] NOT NULL,
    achievements jsonb[] DEFAULT ARRAY[]::jsonb[] NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: courses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.courses (
    course_id character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    required_exam_ids character varying(255)[] DEFAULT ARRAY[]::character varying[] NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: exam_attempts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.exam_attempts (
    id uuid NOT NULL,
    exam_id uuid NOT NULL,
    course_id character varying(255) NOT NULL,
    player_id character varying(255) NOT NULL,
    status character varying(255) DEFAULT 'in_progress'::character varying NOT NULL,
    expires_at timestamp(0) without time zone NOT NULL,
    answers jsonb[] DEFAULT ARRAY[]::jsonb[] NOT NULL,
    score integer,
    passed boolean,
    graded_at timestamp(0) without time zone,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: exams; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.exams (
    id uuid NOT NULL,
    course_id character varying(255) NOT NULL,
    title character varying(255) NOT NULL,
    difficulty character varying(255) NOT NULL,
    questions jsonb[] DEFAULT ARRAY[]::jsonb[] NOT NULL,
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
-- Name: academic_records academic_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.academic_records
    ADD CONSTRAINT academic_records_pkey PRIMARY KEY (player_id);


--
-- Name: courses courses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.courses
    ADD CONSTRAINT courses_pkey PRIMARY KEY (course_id);


--
-- Name: exam_attempts exam_attempts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exam_attempts
    ADD CONSTRAINT exam_attempts_pkey PRIMARY KEY (id);


--
-- Name: exams exams_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exams
    ADD CONSTRAINT exams_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: exam_attempts_exam_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX exam_attempts_exam_id_index ON public.exam_attempts USING btree (exam_id);


--
-- Name: exam_attempts_player_id_status_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX exam_attempts_player_id_status_index ON public.exam_attempts USING btree (player_id, status);


--
-- Name: exams_course_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX exams_course_id_index ON public.exams USING btree (course_id);


--
-- Name: exam_attempts exam_attempts_exam_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exam_attempts
    ADD CONSTRAINT exam_attempts_exam_id_fkey FOREIGN KEY (exam_id) REFERENCES public.exams(id) ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--

\unrestrict CetbtXb8usIrg6bvhBesuS8ood5Cc8eZtPnUn2h6MYnsAyUvtvLmHplvnwzhwiF


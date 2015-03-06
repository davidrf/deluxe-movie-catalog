--
-- Name: actors; Type: TABLE; Schema: public; Owner: -; Tablespace:
--
CREATE TABLE actors (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);
--
-- Name: cast_members; Type: TABLE; Schema: public; Owner: -; Tablespace:
--
CREATE TABLE cast_members (
    id integer NOT NULL,
    movie_id integer NOT NULL,
    actor_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    "character" character varying(255)
);
--
-- Name: genres; Type: TABLE; Schema: public; Owner: -; Tablespace:
--
CREATE TABLE genres (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);
--
-- Name: studios; Type: TABLE; Schema: public; Owner: -; Tablespace:
--
CREATE TABLE studios (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);
--
-- Name: movies; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE movies (
    id integer NOT NULL,
    title character varying(255) NOT NULL,
    year integer NOT NULL,
    synopsis text,
    rating integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    genre_id integer NOT NULL,
    studio_id integer
);

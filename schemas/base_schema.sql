--
-- PostgreSQL database dump
--

\restrict BTNut6luQPS8B3ymzeAHV19kJKJvmq9hanr4I17RBB94YAM0zGMqAKXMVt0jy3g

-- Dumped from database version 15.15
-- Dumped by pg_dump version 15.15

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
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: unaccent; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;


--
-- Name: EXTENSION unaccent; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION unaccent IS 'text search dictionary that removes accents';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: app_platform_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.app_platform_enum AS ENUM (
    'android',
    'ios'
);


--
-- Name: appareil_type_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.appareil_type_enum AS ENUM (
    'mobile',
    'web'
);


--
-- Name: entite_type_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.entite_type_enum AS ENUM (
    'Services',
    'Offres'
);


--
-- Name: epreuves_type_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.epreuves_type_enum AS ENUM (
    'Interrogation',
    'Devoirs',
    'Concours',
    'Examens'
);


--
-- Name: likes_type_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.likes_type_enum AS ENUM (
    'like',
    'dislike'
);


--
-- Name: parcours_media_type_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.parcours_media_type_enum AS ENUM (
    'image',
    'video'
);


--
-- Name: publicites_type_media_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.publicites_type_media_enum AS ENUM (
    'Image',
    'Video'
);


--
-- Name: ressources_type_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.ressources_type_enum AS ENUM (
    'Quiz',
    'Exercices',
    'Document'
);


--
-- Name: services_status_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.services_status_enum AS ENUM (
    'pending_approval',
    'declined',
    'approved',
    'active',
    'inactive'
);


--
-- Name: utilisateurs_role_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.utilisateurs_role_enum AS ENUM (
    'admin',
    'étudiant',
    'professeur',
    'autre'
);


--
-- Name: utilisateurs_sexe_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.utilisateurs_sexe_enum AS ENUM (
    'M',
    'F',
    'Autre'
);


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: _competencesTooffres; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."_competencesTooffres" (
    "A" integer NOT NULL,
    "B" integer NOT NULL
);


--
-- Name: _competencesToprestataires; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."_competencesToprestataires" (
    "A" integer NOT NULL,
    "B" integer NOT NULL
);


--
-- Name: _prisma_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public._prisma_migrations (
    id character varying(36) NOT NULL,
    checksum character varying(64) NOT NULL,
    finished_at timestamp with time zone,
    migration_name character varying(255) NOT NULL,
    logs text,
    rolled_back_at timestamp with time zone,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    applied_steps_count integer DEFAULT 0 NOT NULL
);


--
-- Name: app_versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.app_versions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    platform public.app_platform_enum NOT NULL,
    version character varying(50) NOT NULL,
    minimum_required_version character varying(50) NOT NULL,
    update_url text NOT NULL,
    force_update boolean DEFAULT false,
    release_notes jsonb,
    is_active boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: avis; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.avis (
    id integer NOT NULL,
    utilisateur_id integer NOT NULL,
    note integer DEFAULT 5 NOT NULL,
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    avisable_id integer NOT NULL,
    avisable_type public.entite_type_enum NOT NULL,
    comment text
);


--
-- Name: avis_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.avis_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: avis_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.avis_id_seq OWNED BY public.avis.id;


--
-- Name: blacklisted_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.blacklisted_tokens (
    id integer NOT NULL,
    token text NOT NULL,
    date_expiration timestamp with time zone NOT NULL,
    date_creation timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: blacklisted_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.blacklisted_tokens_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: blacklisted_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.blacklisted_tokens_id_seq OWNED BY public.blacklisted_tokens.id;


--
-- Name: categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.categories (
    id integer NOT NULL,
    nom character varying(100) NOT NULL,
    slug character varying(100) NOT NULL,
    description text,
    couleur character varying(7),
    icone text,
    is_active boolean DEFAULT true,
    ordre integer DEFAULT 0,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.categories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.categories_id_seq OWNED BY public.categories.id;


--
-- Name: commentaire_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.commentaire_users (
    id integer NOT NULL,
    commentable_id bigint NOT NULL,
    commentable_type text NOT NULL,
    commentaire_id integer,
    content text NOT NULL,
    user_id integer NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    deleted_at timestamp(3) without time zone
);


--
-- Name: commentaire_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.commentaire_users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: commentaire_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.commentaire_users_id_seq OWNED BY public.commentaire_users.id;


--
-- Name: commentaires; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.commentaires (
    id integer NOT NULL,
    parcours_id integer NOT NULL,
    utilisateur_id integer NOT NULL,
    contenu text NOT NULL,
    date_commentaire timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    parent_id integer
);


--
-- Name: commentaires_closure; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.commentaires_closure (
    id_ancestor integer NOT NULL,
    id_descendant integer NOT NULL,
    depth integer DEFAULT 0 NOT NULL
);


--
-- Name: commentaires_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.commentaires_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: commentaires_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.commentaires_id_seq OWNED BY public.commentaires.id;


--
-- Name: competences; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.competences (
    id integer NOT NULL,
    nom character varying(100) NOT NULL,
    slug character varying(100) NOT NULL,
    description text
);


--
-- Name: competences_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.competences_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: competences_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.competences_id_seq OWNED BY public.competences.id;


--
-- Name: concours; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.concours (
    id integer NOT NULL,
    titre character varying(255) NOT NULL,
    lieu character varying(255),
    url text,
    annee integer,
    nombre_page integer DEFAULT 0,
    nombre_telechargements integer DEFAULT 0
);


--
-- Name: concours_examens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.concours_examens_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: concours_examens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.concours_examens_id_seq OWNED BY public.concours.id;


--
-- Name: contacts_professionnels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.contacts_professionnels (
    id integer NOT NULL,
    nom character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    telephone character varying(50),
    message text,
    reseaux_sociaux jsonb,
    actif boolean DEFAULT true,
    date_creation timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: contacts_professionnels_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.contacts_professionnels_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contacts_professionnels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.contacts_professionnels_id_seq OWNED BY public.contacts_professionnels.id;


--
-- Name: desabonnement_email; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.desabonnement_email (
    id integer NOT NULL,
    utilisateur_uuid uuid NOT NULL,
    date_creation timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: desabonnement_email_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.desabonnement_email_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: desabonnement_email_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.desabonnement_email_id_seq OWNED BY public.desabonnement_email.id;


--
-- Name: epreuves; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.epreuves (
    id integer NOT NULL,
    titre character varying(255) NOT NULL,
    url text NOT NULL,
    professeur_id integer NOT NULL,
    matiere_id integer NOT NULL,
    duree_minutes integer NOT NULL,
    date_creation timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    date_publication timestamp with time zone,
    type public.epreuves_type_enum,
    nombre_pages integer DEFAULT 0 NOT NULL,
    nombre_telechargements integer DEFAULT 0 NOT NULL
);


--
-- Name: epreuves_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.epreuves_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: epreuves_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.epreuves_id_seq OWNED BY public.epreuves.id;


--
-- Name: etablissements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.etablissements (
    id integer NOT NULL,
    nom character varying(255) NOT NULL,
    ville character varying(100),
    code_postal character varying(20),
    logo text
);


--
-- Name: etablissements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.etablissements_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: etablissements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.etablissements_id_seq OWNED BY public.etablissements.id;


--
-- Name: evenements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.evenements (
    id integer NOT NULL,
    titre character varying(255) NOT NULL,
    description text,
    date timestamp with time zone,
    lieu character varying(255),
    lien_inscription text,
    image text,
    actif boolean DEFAULT true,
    date_creation timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: evenements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.evenements_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: evenements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.evenements_id_seq OWNED BY public.evenements.id;


--
-- Name: favoris; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favoris (
    id integer NOT NULL,
    parcours_id integer NOT NULL,
    utilisateur_id integer NOT NULL,
    date_favoris timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: favoris_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.favoris_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: favoris_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.favoris_id_seq OWNED BY public.favoris.id;


--
-- Name: filieres; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.filieres (
    id integer NOT NULL,
    nom character varying(255) NOT NULL,
    etablissement_id integer NOT NULL
);


--
-- Name: filieres_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.filieres_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: filieres_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.filieres_id_seq OWNED BY public.filieres.id;


--
-- Name: forums; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.forums (
    id integer NOT NULL,
    theme text NOT NULL,
    content text NOT NULL,
    photo text,
    user_id integer NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    deleted_at timestamp(3) without time zone
);


--
-- Name: forums_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.forums_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: forums_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.forums_id_seq OWNED BY public.forums.id;


--
-- Name: like_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.like_users (
    id integer NOT NULL,
    likeable_id bigint NOT NULL,
    likeable_type text NOT NULL,
    user_id integer NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: like_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.like_users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: like_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.like_users_id_seq OWNED BY public.like_users.id;


--
-- Name: likes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.likes (
    id integer NOT NULL,
    parcours_id integer,
    commentaire_id integer,
    utilisateur_id integer NOT NULL,
    date_like timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    date_dislike timestamp with time zone,
    type public.likes_type_enum DEFAULT 'like'::public.likes_type_enum
);


--
-- Name: likes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.likes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: likes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.likes_id_seq OWNED BY public.likes.id;


--
-- Name: matieres; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.matieres (
    id integer NOT NULL,
    nom character varying(255) NOT NULL,
    description text,
    niveau_etude_id integer NOT NULL,
    filiere_id integer NOT NULL
);


--
-- Name: matieres_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.matieres_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: matieres_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.matieres_id_seq OWNED BY public.matieres.id;


--
-- Name: niveau_etude; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.niveau_etude (
    id integer NOT NULL,
    nom character varying(100) NOT NULL,
    duree_mois integer,
    filiere_id integer NOT NULL
);


--
-- Name: niveau_etude_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.niveau_etude_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: niveau_etude_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.niveau_etude_id_seq OWNED BY public.niveau_etude.id;


--
-- Name: notification_utilisateurs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notification_utilisateurs (
    id integer NOT NULL,
    notification_id integer NOT NULL,
    utilisateur_id integer NOT NULL,
    is_read boolean DEFAULT false,
    read_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: notification_utilisateurs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.notification_utilisateurs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notification_utilisateurs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.notification_utilisateurs_id_seq OWNED BY public.notification_utilisateurs.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notifications (
    id integer NOT NULL,
    title character varying(255) NOT NULL,
    body text NOT NULL,
    type character varying(50) DEFAULT 'other'::character varying,
    priority character varying(50) DEFAULT 'normal'::character varying,
    data jsonb,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    expires_at timestamp without time zone,
    sender_id integer,
    CONSTRAINT notifications_priority_check CHECK (((priority)::text = ANY ((ARRAY['high'::character varying, 'normal'::character varying, 'low'::character varying])::text[]))),
    CONSTRAINT notifications_type_check CHECK (((type)::text = ANY ((ARRAY['system'::character varying, 'comment'::character varying, 'like'::character varying, 'parcours'::character varying, 'follow'::character varying, 'other'::character varying])::text[])))
);


--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.notifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.notifications_id_seq OWNED BY public.notifications.id;


--
-- Name: offres; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.offres (
    id integer NOT NULL,
    titre character varying(255) NOT NULL,
    description text NOT NULL,
    type_id integer NOT NULL,
    prix numeric(10,2),
    temps character varying(100),
    image_couverture text,
    utilisateur_id integer NOT NULL,
    status public.services_status_enum DEFAULT 'pending_approval'::public.services_status_enum NOT NULL,
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: offres_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.offres_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: offres_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.offres_id_seq OWNED BY public.offres.id;


--
-- Name: opportunites; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.opportunites (
    id integer NOT NULL,
    titre character varying(255) NOT NULL,
    type character varying(50) NOT NULL,
    organisme character varying(255),
    lieu character varying(100),
    date_publication date,
    image text,
    lien_postuler text,
    actif boolean DEFAULT true,
    date_creation timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT opportunites_type_check CHECK (((type)::text = ANY ((ARRAY['Bourses'::character varying, 'Stages'::character varying])::text[])))
);


--
-- Name: opportunites_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.opportunites_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: opportunites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.opportunites_id_seq OWNED BY public.opportunites.id;


--
-- Name: parcours; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.parcours (
    id integer NOT NULL,
    titre character varying(255) NOT NULL,
    image_couverture character varying(500),
    lien_video character varying(500),
    type_media public.parcours_media_type_enum NOT NULL,
    description text NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    category_id integer
);


--
-- Name: parcours_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.parcours_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: parcours_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.parcours_id_seq OWNED BY public.parcours.id;


--
-- Name: prestataires; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.prestataires (
    id integer NOT NULL,
    nom character varying(100) NOT NULL,
    prenom character varying(100) NOT NULL,
    utilisateur_id integer NOT NULL,
    photo_profil text,
    photo_identite text,
    biographie text,
    domaine_competence character varying(255),
    lien_portfolio character varying(255),
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: prestataires_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.prestataires_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: prestataires_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.prestataires_id_seq OWNED BY public.prestataires.id;


--
-- Name: publicites; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.publicites (
    id integer NOT NULL,
    titre character varying(255) NOT NULL,
    image text,
    media text,
    ordre integer DEFAULT 0,
    actif boolean DEFAULT true,
    date_creation timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    type_media public.publicites_type_media_enum,
    lien_inscription text
);


--
-- Name: publicites_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.publicites_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: publicites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.publicites_id_seq OWNED BY public.publicites.id;


--
-- Name: recruteurs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.recruteurs (
    id integer NOT NULL,
    numero_ifu character varying(100),
    nom character varying(100) NOT NULL,
    nom_recruteur character varying(100) NOT NULL,
    prenom character varying(100) NOT NULL,
    utilisateur_id integer NOT NULL,
    photo_profil text,
    photo_identite text,
    adresse character varying(255),
    telephone character varying(50),
    biographie text,
    status public.services_status_enum DEFAULT 'pending_approval'::public.services_status_enum NOT NULL,
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: recruteurs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.recruteurs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: recruteurs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.recruteurs_id_seq OWNED BY public.recruteurs.id;


--
-- Name: refresh_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.refresh_tokens (
    id integer NOT NULL,
    utilisateur_id integer NOT NULL,
    token character varying(255) NOT NULL,
    date_creation timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    date_expiration timestamp with time zone NOT NULL,
    appareil public.appareil_type_enum
);


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.refresh_tokens_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.refresh_tokens_id_seq OWNED BY public.refresh_tokens.id;


--
-- Name: ressources; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ressources (
    id integer NOT NULL,
    titre character varying(255) NOT NULL,
    type public.ressources_type_enum NOT NULL,
    url text NOT NULL,
    professeur_id integer NOT NULL,
    matiere_id integer NOT NULL,
    date_creation timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    date_publication timestamp with time zone,
    nombre_pages integer DEFAULT 0 NOT NULL,
    nombre_telechargements integer DEFAULT 0 NOT NULL
);


--
-- Name: ressources_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ressources_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ressources_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ressources_id_seq OWNED BY public.ressources.id;


--
-- Name: services; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.services (
    id integer NOT NULL,
    titre character varying(255) NOT NULL,
    description text NOT NULL,
    localisation character varying(255) NOT NULL,
    utilisateur_id integer NOT NULL,
    tarif numeric(10,2),
    type_id integer NOT NULL,
    status public.services_status_enum DEFAULT 'pending_approval'::public.services_status_enum NOT NULL,
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    image_couverture text,
    livrable text,
    disponibilite integer
);


--
-- Name: services_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.services_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: services_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.services_id_seq OWNED BY public.services.id;


--
-- Name: types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.types (
    id integer NOT NULL,
    nom character varying(255) NOT NULL,
    slug character varying(255) NOT NULL,
    description text,
    entite_type public.entite_type_enum DEFAULT 'Services'::public.entite_type_enum NOT NULL
);


--
-- Name: types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.types_id_seq OWNED BY public.types.id;


--
-- Name: utilisateurs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.utilisateurs (
    id integer NOT NULL,
    nom character varying(100) NOT NULL,
    prenom character varying(100) NOT NULL,
    pseudo character varying(100),
    email character varying(255) NOT NULL,
    mot_de_passe character varying(255) NOT NULL,
    photo text,
    etablissement_id integer,
    filiere_id integer,
    niveau_etude_id integer,
    sexe public.utilisateurs_sexe_enum,
    telephone character varying(50),
    role public.utilisateurs_role_enum,
    fcm_token text,
    est_desactive boolean DEFAULT false,
    date_suppression_prevue timestamp without time zone,
    date_creation timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    date_expiration_code timestamp without time zone,
    mon_code_parrainage text,
    parrain_id integer,
    uuid uuid DEFAULT gen_random_uuid(),
    digit_code character varying(6),
    verifier boolean DEFAULT false
);


--
-- Name: utilisateurs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.utilisateurs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: utilisateurs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.utilisateurs_id_seq OWNED BY public.utilisateurs.id;


--
-- Name: avis id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.avis ALTER COLUMN id SET DEFAULT nextval('public.avis_id_seq'::regclass);


--
-- Name: blacklisted_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blacklisted_tokens ALTER COLUMN id SET DEFAULT nextval('public.blacklisted_tokens_id_seq'::regclass);


--
-- Name: categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories ALTER COLUMN id SET DEFAULT nextval('public.categories_id_seq'::regclass);


--
-- Name: commentaire_users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.commentaire_users ALTER COLUMN id SET DEFAULT nextval('public.commentaire_users_id_seq'::regclass);


--
-- Name: commentaires id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.commentaires ALTER COLUMN id SET DEFAULT nextval('public.commentaires_id_seq'::regclass);


--
-- Name: competences id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.competences ALTER COLUMN id SET DEFAULT nextval('public.competences_id_seq'::regclass);


--
-- Name: concours id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.concours ALTER COLUMN id SET DEFAULT nextval('public.concours_examens_id_seq'::regclass);


--
-- Name: contacts_professionnels id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contacts_professionnels ALTER COLUMN id SET DEFAULT nextval('public.contacts_professionnels_id_seq'::regclass);


--
-- Name: desabonnement_email id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.desabonnement_email ALTER COLUMN id SET DEFAULT nextval('public.desabonnement_email_id_seq'::regclass);


--
-- Name: epreuves id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.epreuves ALTER COLUMN id SET DEFAULT nextval('public.epreuves_id_seq'::regclass);


--
-- Name: etablissements id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.etablissements ALTER COLUMN id SET DEFAULT nextval('public.etablissements_id_seq'::regclass);


--
-- Name: evenements id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.evenements ALTER COLUMN id SET DEFAULT nextval('public.evenements_id_seq'::regclass);


--
-- Name: favoris id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favoris ALTER COLUMN id SET DEFAULT nextval('public.favoris_id_seq'::regclass);


--
-- Name: filieres id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.filieres ALTER COLUMN id SET DEFAULT nextval('public.filieres_id_seq'::regclass);


--
-- Name: forums id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forums ALTER COLUMN id SET DEFAULT nextval('public.forums_id_seq'::regclass);


--
-- Name: like_users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.like_users ALTER COLUMN id SET DEFAULT nextval('public.like_users_id_seq'::regclass);


--
-- Name: likes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.likes ALTER COLUMN id SET DEFAULT nextval('public.likes_id_seq'::regclass);


--
-- Name: matieres id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.matieres ALTER COLUMN id SET DEFAULT nextval('public.matieres_id_seq'::regclass);


--
-- Name: niveau_etude id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.niveau_etude ALTER COLUMN id SET DEFAULT nextval('public.niveau_etude_id_seq'::regclass);


--
-- Name: notification_utilisateurs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification_utilisateurs ALTER COLUMN id SET DEFAULT nextval('public.notification_utilisateurs_id_seq'::regclass);


--
-- Name: notifications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications ALTER COLUMN id SET DEFAULT nextval('public.notifications_id_seq'::regclass);


--
-- Name: offres id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.offres ALTER COLUMN id SET DEFAULT nextval('public.offres_id_seq'::regclass);


--
-- Name: opportunites id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.opportunites ALTER COLUMN id SET DEFAULT nextval('public.opportunites_id_seq'::regclass);


--
-- Name: parcours id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parcours ALTER COLUMN id SET DEFAULT nextval('public.parcours_id_seq'::regclass);


--
-- Name: prestataires id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prestataires ALTER COLUMN id SET DEFAULT nextval('public.prestataires_id_seq'::regclass);


--
-- Name: publicites id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publicites ALTER COLUMN id SET DEFAULT nextval('public.publicites_id_seq'::regclass);


--
-- Name: recruteurs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recruteurs ALTER COLUMN id SET DEFAULT nextval('public.recruteurs_id_seq'::regclass);


--
-- Name: refresh_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refresh_tokens ALTER COLUMN id SET DEFAULT nextval('public.refresh_tokens_id_seq'::regclass);


--
-- Name: ressources id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ressources ALTER COLUMN id SET DEFAULT nextval('public.ressources_id_seq'::regclass);


--
-- Name: services id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.services ALTER COLUMN id SET DEFAULT nextval('public.services_id_seq'::regclass);


--
-- Name: types id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.types ALTER COLUMN id SET DEFAULT nextval('public.types_id_seq'::regclass);


--
-- Name: utilisateurs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.utilisateurs ALTER COLUMN id SET DEFAULT nextval('public.utilisateurs_id_seq'::regclass);


--
-- Name: _competencesTooffres _competencesTooffres_AB_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."_competencesTooffres"
    ADD CONSTRAINT "_competencesTooffres_AB_pkey" PRIMARY KEY ("A", "B");


--
-- Name: _competencesToprestataires _competencesToprestataires_AB_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."_competencesToprestataires"
    ADD CONSTRAINT "_competencesToprestataires_AB_pkey" PRIMARY KEY ("A", "B");


--
-- Name: _prisma_migrations _prisma_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public._prisma_migrations
    ADD CONSTRAINT _prisma_migrations_pkey PRIMARY KEY (id);


--
-- Name: app_versions app_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.app_versions
    ADD CONSTRAINT app_versions_pkey PRIMARY KEY (id);


--
-- Name: avis avis_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.avis
    ADD CONSTRAINT avis_pkey PRIMARY KEY (id);


--
-- Name: blacklisted_tokens blacklisted_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blacklisted_tokens
    ADD CONSTRAINT blacklisted_tokens_pkey PRIMARY KEY (id);


--
-- Name: blacklisted_tokens blacklisted_tokens_token_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blacklisted_tokens
    ADD CONSTRAINT blacklisted_tokens_token_key UNIQUE (token);


--
-- Name: categories categories_nom_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_nom_key UNIQUE (nom);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: categories categories_slug_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_slug_key UNIQUE (slug);


--
-- Name: commentaire_users commentaire_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.commentaire_users
    ADD CONSTRAINT commentaire_users_pkey PRIMARY KEY (id);


--
-- Name: commentaires_closure commentaires_closure_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.commentaires_closure
    ADD CONSTRAINT commentaires_closure_pkey PRIMARY KEY (id_ancestor, id_descendant);


--
-- Name: commentaires commentaires_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.commentaires
    ADD CONSTRAINT commentaires_pkey PRIMARY KEY (id);


--
-- Name: competences competences_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.competences
    ADD CONSTRAINT competences_pkey PRIMARY KEY (id);


--
-- Name: concours concours_examens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.concours
    ADD CONSTRAINT concours_examens_pkey PRIMARY KEY (id);


--
-- Name: contacts_professionnels contacts_professionnels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contacts_professionnels
    ADD CONSTRAINT contacts_professionnels_pkey PRIMARY KEY (id);


--
-- Name: desabonnement_email desabonnement_email_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.desabonnement_email
    ADD CONSTRAINT desabonnement_email_pkey PRIMARY KEY (id);


--
-- Name: epreuves epreuves_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.epreuves
    ADD CONSTRAINT epreuves_pkey PRIMARY KEY (id);


--
-- Name: etablissements etablissements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.etablissements
    ADD CONSTRAINT etablissements_pkey PRIMARY KEY (id);


--
-- Name: evenements evenements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.evenements
    ADD CONSTRAINT evenements_pkey PRIMARY KEY (id);


--
-- Name: favoris favoris_parcours_id_utilisateur_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favoris
    ADD CONSTRAINT favoris_parcours_id_utilisateur_id_key UNIQUE (parcours_id, utilisateur_id);


--
-- Name: favoris favoris_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favoris
    ADD CONSTRAINT favoris_pkey PRIMARY KEY (id);


--
-- Name: filieres filieres_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.filieres
    ADD CONSTRAINT filieres_pkey PRIMARY KEY (id);


--
-- Name: forums forums_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forums
    ADD CONSTRAINT forums_pkey PRIMARY KEY (id);


--
-- Name: like_users like_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.like_users
    ADD CONSTRAINT like_users_pkey PRIMARY KEY (id);


--
-- Name: likes likes_commentaire_id_utilisateur_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.likes
    ADD CONSTRAINT likes_commentaire_id_utilisateur_id_key UNIQUE (commentaire_id, utilisateur_id);


--
-- Name: likes likes_parcours_id_utilisateur_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.likes
    ADD CONSTRAINT likes_parcours_id_utilisateur_id_key UNIQUE (parcours_id, utilisateur_id);


--
-- Name: likes likes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.likes
    ADD CONSTRAINT likes_pkey PRIMARY KEY (id);


--
-- Name: matieres matieres_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.matieres
    ADD CONSTRAINT matieres_pkey PRIMARY KEY (id);


--
-- Name: niveau_etude niveau_etude_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.niveau_etude
    ADD CONSTRAINT niveau_etude_pkey PRIMARY KEY (id);


--
-- Name: notification_utilisateurs notification_utilisateurs_notification_id_utilisateur_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification_utilisateurs
    ADD CONSTRAINT notification_utilisateurs_notification_id_utilisateur_id_key UNIQUE (notification_id, utilisateur_id);


--
-- Name: notification_utilisateurs notification_utilisateurs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification_utilisateurs
    ADD CONSTRAINT notification_utilisateurs_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: offres offres_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.offres
    ADD CONSTRAINT offres_pkey PRIMARY KEY (id);


--
-- Name: opportunites opportunites_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.opportunites
    ADD CONSTRAINT opportunites_pkey PRIMARY KEY (id);


--
-- Name: parcours parcours_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parcours
    ADD CONSTRAINT parcours_pkey PRIMARY KEY (id);


--
-- Name: prestataires prestataires_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prestataires
    ADD CONSTRAINT prestataires_pkey PRIMARY KEY (id);


--
-- Name: publicites publicites_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publicites
    ADD CONSTRAINT publicites_pkey PRIMARY KEY (id);


--
-- Name: recruteurs recruteurs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recruteurs
    ADD CONSTRAINT recruteurs_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_token_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_token_key UNIQUE (token);


--
-- Name: ressources ressources_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ressources
    ADD CONSTRAINT ressources_pkey PRIMARY KEY (id);


--
-- Name: services services_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_pkey PRIMARY KEY (id);


--
-- Name: types types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.types
    ADD CONSTRAINT types_pkey PRIMARY KEY (id);


--
-- Name: utilisateurs utilisateurs_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.utilisateurs
    ADD CONSTRAINT utilisateurs_email_key UNIQUE (email);


--
-- Name: utilisateurs utilisateurs_mon_code_parrainage_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.utilisateurs
    ADD CONSTRAINT utilisateurs_mon_code_parrainage_key UNIQUE (mon_code_parrainage);


--
-- Name: utilisateurs utilisateurs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.utilisateurs
    ADD CONSTRAINT utilisateurs_pkey PRIMARY KEY (id);


--
-- Name: _competencesTooffres_B_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "_competencesTooffres_B_index" ON public."_competencesTooffres" USING btree ("B");


--
-- Name: _competencesToprestataires_B_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "_competencesToprestataires_B_index" ON public."_competencesToprestataires" USING btree ("B");


--
-- Name: competences_slug_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX competences_slug_key ON public.competences USING btree (slug);


--
-- Name: desabonnement_email_utilisateur_uuid_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX desabonnement_email_utilisateur_uuid_key ON public.desabonnement_email USING btree (utilisateur_uuid);


--
-- Name: idx_commentaires_closure_ancestor; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_commentaires_closure_ancestor ON public.commentaires_closure USING btree (id_ancestor);


--
-- Name: idx_commentaires_closure_depth; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_commentaires_closure_depth ON public.commentaires_closure USING btree (depth);


--
-- Name: idx_commentaires_closure_descendant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_commentaires_closure_descendant ON public.commentaires_closure USING btree (id_descendant);


--
-- Name: prestataires_utilisateur_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX prestataires_utilisateur_id_key ON public.prestataires USING btree (utilisateur_id);


--
-- Name: recruteurs_utilisateur_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX recruteurs_utilisateur_id_key ON public.recruteurs USING btree (utilisateur_id);


--
-- Name: types_slug_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX types_slug_key ON public.types USING btree (slug);


--
-- Name: utilisateurs_uuid_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX utilisateurs_uuid_key ON public.utilisateurs USING btree (uuid);


--
-- Name: _competencesTooffres _competencesTooffres_A_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."_competencesTooffres"
    ADD CONSTRAINT "_competencesTooffres_A_fkey" FOREIGN KEY ("A") REFERENCES public.competences(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: _competencesTooffres _competencesTooffres_B_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."_competencesTooffres"
    ADD CONSTRAINT "_competencesTooffres_B_fkey" FOREIGN KEY ("B") REFERENCES public.offres(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: _competencesToprestataires _competencesToprestataires_A_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."_competencesToprestataires"
    ADD CONSTRAINT "_competencesToprestataires_A_fkey" FOREIGN KEY ("A") REFERENCES public.competences(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: _competencesToprestataires _competencesToprestataires_B_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."_competencesToprestataires"
    ADD CONSTRAINT "_competencesToprestataires_B_fkey" FOREIGN KEY ("B") REFERENCES public.prestataires(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: avis avis_utilisateur_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.avis
    ADD CONSTRAINT avis_utilisateur_id_fkey FOREIGN KEY (utilisateur_id) REFERENCES public.utilisateurs(id) ON DELETE CASCADE;


--
-- Name: commentaire_users commentaire_users_commentaire_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.commentaire_users
    ADD CONSTRAINT commentaire_users_commentaire_id_fkey FOREIGN KEY (commentaire_id) REFERENCES public.commentaire_users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: commentaire_users commentaire_users_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.commentaire_users
    ADD CONSTRAINT commentaire_users_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.utilisateurs(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: commentaires_closure commentaires_closure_id_ancestor_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.commentaires_closure
    ADD CONSTRAINT commentaires_closure_id_ancestor_fkey FOREIGN KEY (id_ancestor) REFERENCES public.commentaires(id) ON DELETE CASCADE;


--
-- Name: commentaires_closure commentaires_closure_id_descendant_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.commentaires_closure
    ADD CONSTRAINT commentaires_closure_id_descendant_fkey FOREIGN KEY (id_descendant) REFERENCES public.commentaires(id) ON DELETE CASCADE;


--
-- Name: commentaires commentaires_parcours_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.commentaires
    ADD CONSTRAINT commentaires_parcours_id_fkey FOREIGN KEY (parcours_id) REFERENCES public.parcours(id);


--
-- Name: commentaires commentaires_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.commentaires
    ADD CONSTRAINT commentaires_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.commentaires(id);


--
-- Name: commentaires commentaires_utilisateur_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.commentaires
    ADD CONSTRAINT commentaires_utilisateur_id_fkey FOREIGN KEY (utilisateur_id) REFERENCES public.utilisateurs(id);


--
-- Name: desabonnement_email desabonnement_email_utilisateur_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.desabonnement_email
    ADD CONSTRAINT desabonnement_email_utilisateur_uuid_fkey FOREIGN KEY (utilisateur_uuid) REFERENCES public.utilisateurs(uuid) ON DELETE CASCADE;


--
-- Name: epreuves epreuves_matiere_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.epreuves
    ADD CONSTRAINT epreuves_matiere_id_fkey FOREIGN KEY (matiere_id) REFERENCES public.matieres(id);


--
-- Name: epreuves epreuves_professeur_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.epreuves
    ADD CONSTRAINT epreuves_professeur_id_fkey FOREIGN KEY (professeur_id) REFERENCES public.utilisateurs(id);


--
-- Name: favoris favoris_parcours_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favoris
    ADD CONSTRAINT favoris_parcours_id_fkey FOREIGN KEY (parcours_id) REFERENCES public.parcours(id) ON DELETE CASCADE;


--
-- Name: favoris favoris_utilisateur_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favoris
    ADD CONSTRAINT favoris_utilisateur_id_fkey FOREIGN KEY (utilisateur_id) REFERENCES public.utilisateurs(id);


--
-- Name: filieres filieres_etablissement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.filieres
    ADD CONSTRAINT filieres_etablissement_id_fkey FOREIGN KEY (etablissement_id) REFERENCES public.etablissements(id);


--
-- Name: parcours fk_parcours_categories; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parcours
    ADD CONSTRAINT fk_parcours_categories FOREIGN KEY (category_id) REFERENCES public.categories(id) ON DELETE SET NULL;


--
-- Name: forums forums_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forums
    ADD CONSTRAINT forums_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.utilisateurs(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: like_users like_users_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.like_users
    ADD CONSTRAINT like_users_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.utilisateurs(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: likes likes_commentaire_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.likes
    ADD CONSTRAINT likes_commentaire_id_fkey FOREIGN KEY (commentaire_id) REFERENCES public.commentaires(id);


--
-- Name: likes likes_parcours_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.likes
    ADD CONSTRAINT likes_parcours_id_fkey FOREIGN KEY (parcours_id) REFERENCES public.parcours(id);


--
-- Name: likes likes_utilisateur_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.likes
    ADD CONSTRAINT likes_utilisateur_id_fkey FOREIGN KEY (utilisateur_id) REFERENCES public.utilisateurs(id);


--
-- Name: matieres matieres_filiere_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.matieres
    ADD CONSTRAINT matieres_filiere_id_fkey FOREIGN KEY (filiere_id) REFERENCES public.filieres(id);


--
-- Name: matieres matieres_niveau_etude_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.matieres
    ADD CONSTRAINT matieres_niveau_etude_id_fkey FOREIGN KEY (niveau_etude_id) REFERENCES public.niveau_etude(id);


--
-- Name: niveau_etude niveau_etude_filiere_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.niveau_etude
    ADD CONSTRAINT niveau_etude_filiere_id_fkey FOREIGN KEY (filiere_id) REFERENCES public.filieres(id);


--
-- Name: notification_utilisateurs notification_utilisateurs_notification_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification_utilisateurs
    ADD CONSTRAINT notification_utilisateurs_notification_id_fkey FOREIGN KEY (notification_id) REFERENCES public.notifications(id) ON DELETE CASCADE;


--
-- Name: notification_utilisateurs notification_utilisateurs_utilisateur_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification_utilisateurs
    ADD CONSTRAINT notification_utilisateurs_utilisateur_id_fkey FOREIGN KEY (utilisateur_id) REFERENCES public.utilisateurs(id) ON DELETE CASCADE;


--
-- Name: offres offres_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.offres
    ADD CONSTRAINT offres_type_id_fkey FOREIGN KEY (type_id) REFERENCES public.types(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: offres offres_utilisateur_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.offres
    ADD CONSTRAINT offres_utilisateur_id_fkey FOREIGN KEY (utilisateur_id) REFERENCES public.utilisateurs(id) ON DELETE CASCADE;


--
-- Name: parcours parcours_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parcours
    ADD CONSTRAINT parcours_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id) ON DELETE SET NULL;


--
-- Name: prestataires prestataires_utilisateur_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prestataires
    ADD CONSTRAINT prestataires_utilisateur_id_fkey FOREIGN KEY (utilisateur_id) REFERENCES public.utilisateurs(id) ON DELETE CASCADE;


--
-- Name: recruteurs recruteurs_utilisateur_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recruteurs
    ADD CONSTRAINT recruteurs_utilisateur_id_fkey FOREIGN KEY (utilisateur_id) REFERENCES public.utilisateurs(id) ON DELETE CASCADE;


--
-- Name: refresh_tokens refresh_tokens_utilisateur_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_utilisateur_id_fkey FOREIGN KEY (utilisateur_id) REFERENCES public.utilisateurs(id) ON DELETE CASCADE;


--
-- Name: ressources ressources_matiere_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ressources
    ADD CONSTRAINT ressources_matiere_id_fkey FOREIGN KEY (matiere_id) REFERENCES public.matieres(id);


--
-- Name: ressources ressources_professeur_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ressources
    ADD CONSTRAINT ressources_professeur_id_fkey FOREIGN KEY (professeur_id) REFERENCES public.utilisateurs(id);


--
-- Name: services services_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_type_id_fkey FOREIGN KEY (type_id) REFERENCES public.types(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: services services_utilisateur_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_utilisateur_id_fkey FOREIGN KEY (utilisateur_id) REFERENCES public.utilisateurs(id) ON DELETE CASCADE;


--
-- Name: utilisateurs utilisateurs_etablissement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.utilisateurs
    ADD CONSTRAINT utilisateurs_etablissement_id_fkey FOREIGN KEY (etablissement_id) REFERENCES public.etablissements(id);


--
-- Name: utilisateurs utilisateurs_filiere_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.utilisateurs
    ADD CONSTRAINT utilisateurs_filiere_id_fkey FOREIGN KEY (filiere_id) REFERENCES public.filieres(id);


--
-- Name: utilisateurs utilisateurs_niveau_etude_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.utilisateurs
    ADD CONSTRAINT utilisateurs_niveau_etude_id_fkey FOREIGN KEY (niveau_etude_id) REFERENCES public.niveau_etude(id);


--
-- Name: utilisateurs utilisateurs_parrain_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.utilisateurs
    ADD CONSTRAINT utilisateurs_parrain_id_fkey FOREIGN KEY (parrain_id) REFERENCES public.utilisateurs(id);


--
-- PostgreSQL database dump complete
--

\unrestrict BTNut6luQPS8B3ymzeAHV19kJKJvmq9hanr4I17RBB94YAM0zGMqAKXMVt0jy3g


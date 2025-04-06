/*======================================================================
  Gotta Love Games Database
  Authors: Shahdad Khakpoor, Jana Van Heeswyk
  ======================================================================*/
DROP SCHEMA IF EXISTS GLG CASCADE;
CREATE SCHEMA GLG;
SET SEARCH_PATH TO GLG;

DROP TYPE IF EXISTS level_of_study_enum      CASCADE;
DROP TYPE IF EXISTS game_category_enum       CASCADE;
DROP TYPE IF EXISTS game_condition_enum      CASCADE;

CREATE TYPE level_of_study_enum AS ENUM (
    'Undergraduate', 'Graduate', 'Alumni'
);

CREATE TYPE game_category_enum AS ENUM (
    'Strategy', 'Party', 'Deck‑building', 'Role‑playing', 'Social‑deduction'
);

CREATE TYPE game_condition_enum AS ENUM (
    'New', 'Lightly‑used', 'Worn', 'Incomplete', 'Damaged'
);


/*------------------  MEMBER  -----------------------------------------*/
DROP TABLE IF EXISTS member CASCADE;
CREATE TABLE member (
    mid INT PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    email VARCHAR(200) NOT NULL UNIQUE,
    los level_of_study_enum NOT NULL
);

/*------------------  EXEC_MEMBER  (subtype of MEMBER)  ---------------*/
DROP TABLE IF EXISTS exec_member CASCADE;
CREATE TABLE exec_member (
    mid INT PRIMARY KEY REFERENCES member(mid),
    role VARCHAR(50) NOT NULL,
    role_start_date TIMESTAMP WITHOUT TIME ZONE NOT NULL
);

/*------------------  BOARD_GAME  -------------------------------------*/
DROP TABLE IF EXISTS board_game CASCADE;
CREATE TABLE board_game (
    gid INT PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    category game_category_enum NOT NULL,
    min_players INT NOT NULL CHECK (min_players >= 1),
    max_players INT NOT NULL CHECK (max_players >= min_players),
    publisher VARCHAR(100),
    release_year INT
);

/*------------------  GAME_COPY  --------------------------------------*/
DROP TABLE IF EXISTS game_copy CASCADE;
CREATE TABLE game_copy (
    cid INT PRIMARY KEY,
    gid INT NOT NULL REFERENCES board_game(gid),
    acquisition_date TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    condition game_condition_enum NOT NULL
);

/*------------------  EVENT_SERIES  -----------------------------------*/
DROP TABLE IF EXISTS event_series CASCADE;
CREATE TABLE event_series (
    series_id INT PRIMARY KEY,
    name VARCHAR(120) NOT NULL,
    start_ts TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    end_ts TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    CHECK (end_ts > start_ts)
);

/*------------------  EVENT  ------------------------------------------*/
DROP TABLE IF EXISTS event CASCADE;
CREATE TABLE event (
    eid INT PRIMARY KEY,
    series_id INT NOT NULL REFERENCES event_series(series_id),
    location VARCHAR(120) NOT NULL
);

/*------------------  EVENT_COMMITTEE  --------------------------------*/
DROP TABLE IF EXISTS event_committee CASCADE;
CREATE TABLE event_committee (
    committee_id INT PRIMARY KEY,
    event_series_name VARCHAR(120)
);

/*------------------  COMMITTEE_MEMBER  -------------------------------*/
DROP TABLE IF EXISTS committee_member CASCADE;
CREATE TABLE committee_member (
    committee_id INT NOT NULL REFERENCES event_committee(committee_id),
    exec_member_id   INT NOT NULL REFERENCES exec_member(mid),
    is_lead BOOLEAN NOT NULL DEFAULT FALSE,
    PRIMARY KEY (committee_id, exec_member_id)
);

/*  Ensure exactly one lead per committee  */
CREATE UNIQUE INDEX committee_one_lead
        ON committee_member(committee_id)
     WHERE is_lead;

/*------------------  GAME_SESSION  -----------------------------------*/
DROP TABLE IF EXISTS game_session CASCADE;
CREATE TABLE game_session (
    sid INT PRIMARY KEY,
    event INT NOT NULL REFERENCES event(eid),
    game_copy INT NOT NULL REFERENCES game_copy(cid),
    facilitator INT NOT NULL REFERENCES exec_member(mid)
);

/*------------------  SESSION_PARTICIPANT  ----------------------------*/
DROP TABLE IF EXISTS session_participant CASCADE;
CREATE TABLE session_participant (
    session INT NOT NULL REFERENCES game_session(sid),
    participant INT NOT NULL REFERENCES member(mid),
    PRIMARY KEY (session, participant)
);

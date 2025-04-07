/*======================================================================
  Gotta Love Games Database  –  schema.ddl  (Assignment 3)
  Authors: Shahdad Khakpoor, Jana Van Heeswyk
  ----------------------------------------------------------------------
  Could not :  none
  Did not   :  We did not enforce the rule that game copies marked as 'Damaged' cannot be
      scheduled in game_session.
    
  Extra constraints :
      • board_game.release_year must be between 1900 and the current year
      • exactly one lead exec per committee (partial UNIQUE index)
  Assumptions :
      • one organising committee per event series, shared by all its
        occurrences
      • each occurrence has a single calendar date; all occurrences of a
        series share the same start/end time window
======================================================================*/
DROP SCHEMA IF EXISTS A3GLG CASCADE;
CREATE SCHEMA A3GLG;
SET SEARCH_PATH TO A3GLG;

DROP TYPE IF EXISTS level_of_study_enum      CASCADE;
DROP TYPE IF EXISTS game_category_enum       CASCADE;
DROP TYPE IF EXISTS game_condition_enum      CASCADE;

CREATE TYPE level_of_study_enum AS ENUM (
    'Undergraduate','Graduate','Alumni'
);
CREATE TYPE game_category_enum AS ENUM (
    'Strategy','Party','Deck‑building','Role‑playing','Social-deduction'
);
CREATE TYPE game_condition_enum AS ENUM (
    'New','Lightly‑used','Worn','Incomplete','Damaged'
);

/*------------------  MEMBER  -----------------------------------------*/
DROP TABLE IF EXISTS member CASCADE;
CREATE TABLE member (
    mid INT PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    email VARCHAR(200) NOT NULL UNIQUE,
    los level_of_study_enum NOT NULL
);

/*------------------  EXEC_MEMBER  ------------------------------------*/
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
    min_players INT NOT NULL CHECK (min_players>=1),
    max_players INT NOT NULL CHECK (max_players>=min_players),
    publisher VARCHAR(100),
    release_year INT CHECK (release_year BETWEEN 1900
                            AND EXTRACT(YEAR FROM CURRENT_DATE))
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
    name VARCHAR(120) NOT NULL UNIQUE,
    start_ts TIME NOT NULL,
    end_ts TIME NOT NULL,
    CHECK (end_ts > start_ts)
);

/*------------------  EVENT  ------------------------------------------*/
DROP TABLE IF EXISTS event CASCADE;
CREATE TABLE event (
    eid INT PRIMARY KEY,
    series_id INT NOT NULL REFERENCES event_series(series_id),
    event_date DATE NOT NULL,
    location VARCHAR(120) NOT NULL
);

/*------------------  EVENT_COMMITTEE  --------------------------------*/
DROP TABLE IF EXISTS event_committee CASCADE;
CREATE TABLE event_committee (
    committee_id INT PRIMARY KEY,
    event_series_name VARCHAR(120) NOT NULL
        REFERENCES event_series(name)
);

/*------------------  COMMITTEE_MEMBER  -------------------------------*/
DROP TABLE IF EXISTS committee_member CASCADE;
CREATE TABLE committee_member (
    committee_id INT NOT NULL REFERENCES event_committee(committee_id),
    exec_member_id INT NOT NULL REFERENCES exec_member(mid),
    is_lead BOOLEAN NOT NULL DEFAULT FALSE,
    PRIMARY KEY (committee_id,exec_member_id)
);
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
    PRIMARY KEY (session,participant)
);

/*------------------  TRIGGERS  ---------------------------------------*/
/* Prevent facilitator overlaps and facilitator playing elsewhere */
CREATE OR REPLACE FUNCTION check_facilitator_overlap()
RETURNS TRIGGER AS $$
DECLARE
    new_date  DATE;
    new_start TIME;
    new_end   TIME;
BEGIN
    SELECT e.event_date, es.start_ts, es.end_ts
      INTO new_date, new_start, new_end
      FROM event e JOIN event_series es ON es.series_id = e.series_id
     WHERE e.eid = NEW.event;

    /* Already facilitating overlapping session */
    IF EXISTS (
        SELECT 1
          FROM game_session gs
          JOIN event e ON e.eid = gs.event
          JOIN event_series es ON es.series_id = e.series_id
         WHERE gs.facilitator = NEW.facilitator
           AND gs.sid <> COALESCE(NEW.sid,-1)
           AND e.event_date = new_date
           AND new_start < es.end_ts
           AND es.start_ts < new_end
    ) THEN
        RAISE EXCEPTION
          'Exec % is already facilitating an overlapping session',
          NEW.facilitator;
    END IF;

    /* Facilitator playing in another overlapping session */
    IF EXISTS (
        SELECT 1
          FROM session_participant sp
          JOIN game_session gs ON gs.sid = sp.session
          JOIN event e ON e.eid = gs.event
          JOIN event_series es ON es.series_id = e.series_id
         WHERE sp.participant = NEW.facilitator
           AND gs.sid <> COALESCE(NEW.sid,-1)
           AND e.event_date = new_date
           AND new_start < es.end_ts
           AND es.start_ts < new_end
    ) THEN
        RAISE EXCEPTION
          'Exec % is playing in another overlapping session',
          NEW.facilitator;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_facilitator_overlap
    BEFORE INSERT OR UPDATE ON game_session
    FOR EACH ROW EXECUTE FUNCTION check_facilitator_overlap();

/* Prevent member overlaps and member facilitating elsewhere */
CREATE OR REPLACE FUNCTION check_participant_overlap()
RETURNS TRIGGER AS $$
DECLARE
    new_date  DATE;
    new_start TIME;
    new_end   TIME;
BEGIN
    SELECT e.event_date, es.start_ts, es.end_ts
      INTO new_date, new_start, new_end
      FROM game_session gs
      JOIN event e        ON e.eid = gs.event
      JOIN event_series es ON es.series_id = e.series_id
     WHERE gs.sid = NEW.session;

    /* Member already playing another overlapping session */
    IF EXISTS (
        SELECT 1
          FROM session_participant sp
          JOIN game_session gs ON gs.sid = sp.session
          JOIN event e ON e.eid = gs.event
          JOIN event_series es ON es.series_id = e.series_id
         WHERE sp.participant = NEW.participant
           AND gs.sid <> NEW.session
           AND e.event_date = new_date
           AND new_start < es.end_ts
           AND es.start_ts < new_end
    ) THEN
        RAISE EXCEPTION
          'Member % is already playing an overlapping session',
          NEW.participant;
    END IF;

    /* Member is facilitating another overlapping session */
    IF EXISTS (
        SELECT 1
          FROM game_session gs
          JOIN event e ON e.eid = gs.event
          JOIN event_series es ON es.series_id = e.series_id
         WHERE gs.facilitator = NEW.participant
           AND gs.sid <> NEW.session
           AND e.event_date = new_date
           AND new_start < es.end_ts
           AND es.start_ts < new_end
    ) THEN
        RAISE EXCEPTION
          'Member % is facilitating an overlapping session',
          NEW.participant;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_participant_overlap
    BEFORE INSERT OR UPDATE ON session_participant
    FOR EACH ROW EXECUTE FUNCTION check_participant_overlap();

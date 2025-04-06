
/* ---------- q1.sql by Shahdad and Jana ---------- */

WITH total_members AS (
    SELECT COUNT(*) AS n FROM member
)
SELECT
    e.eid               AS event_id,
    e.event_date,
    e.location,
    ROUND( 100.0 * COUNT(DISTINCT sp.participant)
/                (SELECT n FROM total_members)
         , 2) AS participation_pct
FROM       event            e
JOIN       game_session     gs ON gs.event   = e.eid
JOIN       session_participant sp ON sp.session = gs.sid
GROUP BY e.eid, e.event_date, e.location
ORDER BY e.event_date, e.eid;
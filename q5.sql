
/* ---------- q5.sql by Shahdad and Jana ---------- */

SELECT e.eid,
       e.event_date,
       e.location,
       AVG(session_counts.participant_count) AS avg_participants
FROM event e
JOIN (
    SELECT gs.event,
           gs.sid,
           COUNT(sp.participant) AS participant_count
    FROM game_session gs
    LEFT JOIN session_participant sp ON gs.sid = sp.session
    GROUP BY gs.sid, gs.event
) AS session_counts ON e.eid = session_counts.event
GROUP BY e.eid, e.event_date, e.location
ORDER BY e.eid;
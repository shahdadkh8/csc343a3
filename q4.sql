
/* ---------- q4.sql by Shahdad and Jana ---------- */

SELECT m.mid,
       m.name,
       COUNT(DISTINCT sp.session) AS session_count
FROM member m
JOIN session_participant sp ON m.mid = sp.participant
GROUP BY m.mid, m.name
ORDER BY session_count DESC
LIMIT 1;
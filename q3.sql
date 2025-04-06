
/* ---------- q3.sql by Shahdad and Jana ---------- */


/* steps:
    1: finding all the pairs of (exec, game) and count the number of sessions by them
    2: find the maximum of those counts.
    3: returning all pairs that reach the maximum.
*/
WITH per_exec_game AS (
    SELECT
        em.mid          AS exec_id,
        m.name          AS exec_name,
        bg.gid,
        bg.title,
        COUNT(*)        AS sessions_led
    FROM       game_session   gs
    JOIN       exec_member    em ON em.mid   = gs.facilitator
    JOIN       member         m  ON m.mid    = em.mid
    JOIN       game_copy      gc ON gc.cid   = gs.game_copy
    JOIN       board_game     bg ON bg.gid   = gc.gid
    GROUP BY em.mid, m.name, bg.gid, bg.title
),
max_ct AS (
    SELECT MAX(sessions_led) AS mx FROM per_exec_game
)
SELECT
    title,
    exec_name,
    sessions_led
FROM per_exec_game, max_ct
WHERE sessions_led = mx
ORDER BY title, exec_name;

/* ---------- q2.sql by Shahdad and Jana ---------- */

SELECT
    bg.gid,
    bg.title,
    COALESCE(COUNT(gs.sid), 0) AS times_played
FROM       board_game   bg
LEFT JOIN  game_copy    gc ON gc.gid      = bg.gid
LEFT JOIN  game_session gs ON gs.game_copy = gc.cid
GROUP BY bg.gid, bg.title
ORDER BY times_played DESC, bg.title;
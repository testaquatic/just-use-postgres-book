-- 인기 있는 곡
WITH plays_cte AS (SELECT s.title, s.duration
                   FROM streaming.plays p
                            JOIN streaming.songs s on p.song_id = s.id
                   WHERE p.play_start_time::DATE BETWEEN '2024-09-15' AND '2024-09-16'
                     AND p.play_duration = s.duration)
SELECT title, count(*) AS play_count
FROM plays_cte
GROUP BY title
ORDER BY play_count DESC;

-- 인기 없는 곡
WITH plays_cte AS (SELECT s.title, s.duration, p.play_duration
                   FROM streaming.plays p
                            JOIN streaming.songs s on p.song_id = s.id
                   WHERE p.play_start_time::DATE BETWEEN '2024-09-15' AND '2024-09-16'
                     AND p.play_duration < (s.duration / 2))
SELECT title, MIN(play_duration) AS min_play_duration
FROM plays_cte
GROUP BY title
ORDER BY min_play_duration ASC
LIMIT 3;

-- 3명 이상 조건 추가
WITH plays_cte AS (SELECT s.title, s.duration, p.play_duration, p.user_id
                   FROM streaming.plays p
                            JOIN streaming.songs s on p.song_id = s.id
                   WHERE p.play_start_time::DATE BETWEEN '2024-09-15' AND '2024-09-16'
                     AND p.play_duration < (s.duration / 2)),
     user_play_counts AS (SELECT title,
                                 duration,
                                 count(DISTINCT user_id) AS user_count,
                                 min(play_duration)      AS min_play_duration,
                                 count(*)                AS total_play_count
                          FROM plays_cte
                          GROUP BY title, duration)
SELECT title, duration, min_play_duration, total_play_count
FROM user_play_counts
WHERE user_count >= 3
ORDER BY min_play_duration ASC
LIMIT 3;

-- 실행 계획
EXPLAIN(analyse, costs off, timing off)
WITH plays_cte AS (SELECT s.title, s.duration, p.play_duration, p.user_id
                   FROM streaming.plays p
                            JOIN streaming.songs s on p.song_id = s.id
                   WHERE p.play_start_time::DATE BETWEEN '2024-09-15' AND '2024-09-16'
                     AND p.play_duration < (s.duration / 2)),
     user_play_counts AS (SELECT title,
                                 duration,
                                 count(DISTINCT user_id) AS user_count,
                                 min(play_duration)      AS min_play_duration,
                                 count(*)                AS total_play_count
                          FROM plays_cte
                          GROUP BY title, duration)
SELECT title, duration, min_play_duration, total_play_count
FROM user_play_counts
WHERE user_count >= 3
ORDER BY min_play_duration ASC
LIMIT 3;


-- 데이터 조작 CTE
WITH updated_play AS (
    UPDATE streaming.plays SET play_duration = 200 WHERE id = 30
        RETURNING song_id, play_duration)
SELECT s.title,
       s.duration,
       CASE
           WHEN up.play_duration = s.duration THEN 'Moved Up the Rank'
           ELSE 'Rank Not Changed'
           END AS rank_change_status
FROM updated_play up
         JOIN streaming.songs s ON s.id = up.song_id;

-- 재생 세션 확인
SELECT song_id, play_duration
FROM streaming.plays
WHERE id = 12;

-- 동시에 실행되는 CTE
WITH updated_play AS (
    UPDATE streaming.plays SET play_duration = 150 WHERE id = 12
        RETURNING song_id, play_duration),
     current_play_duration AS (SELECT song_id, (play_duration = 150) AS is_change_visible_to_cte
                               FROM streaming.plays
                               WHERE id = 12)
SELECT is_change_visible_to_cte, (play_duration = 150) as is_change_visible_to_primary
FROM updated_play up
         JOIN current_play_duration cp ON up.song_id = cp.song_id;

-- 순차적으로 실행되는 CTE
WITH updated_play AS (
    UPDATE streaming.plays SET play_duration = 160 WHERE id = 12
        RETURNING id, song_id, play_duration),
     current_play_duration AS (SELECT song_id, (play_duration = 160) AS is_change_visible_to_cte
                               FROM updated_play
                               WHERE id = 12)
SELECT is_change_visible_to_cte, (play_duration = 160) AS is_change_visible_to_primary
FROM updated_play up
         JOIN current_play_duration cp ON up.song_id = cp.song_id;
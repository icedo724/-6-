SELECT
    일반현황.유치원명,
    일반현황.교육지원청명,
    COALESCE(특수유아수, 0) AS 특수유아수,
    COALESCE(만3세유아수, 0) + COALESCE(만4세유아수, 0) + COALESCE(만5세유아수, 0) + COALESCE(혼합유아수, 0) + COALESCE(특수유아수, 0) AS 유아수,
    ROUND(COALESCE(특수유아수, 0) / NULLIF(COALESCE(만3세유아수, 0) + COALESCE(만4세유아수, 0) + COALESCE(만5세유아수, 0) + COALESCE(혼합유아수, 0) + COALESCE(특수유아수, 0), 0), 7) AS 특수유아비율,
    ROUND(COALESCE(특수학급수, 0), 7) AS 특수학급수,
    COALESCE(특수학급수, 0) AS 특수학급총합,
    COALESCE(특수교사수, 0) AS 특수교사수,
    ROUND(COALESCE(특수유아수, 0) / NULLIF(COALESCE(특수교사수, 0), 0), 7) AS 특수교사당유아,
    ROUND(COALESCE(특수학급수, 0) / NULLIF(COALESCE(특수교사수, 0), 0), 7) AS 학급대비특수교사수,
    CASE WHEN 특수유아수 > 0 AND 특수학급수 = 0 THEN 1 ELSE 0 END AS 특수유아있지만학급없음,
    CASE WHEN 특수유아수 > 0 AND 특수교사수 = 0 THEN 1 ELSE 0 END AS 특수유아있지만교사없음,
    CASE WHEN 특수유아수 > 0 AND 특수교사수 = 0 THEN 특수유아수 ELSE NULL END AS 교사가없는특수아동
FROM 일반현황
JOIN 교직원 USING(유치원코드)
SELECT
    일반현황.교육지원청명,
    유치원코드,
    일반현황.유치원명,
    일반현황.주소,
    COALESCE(특수유아수, 0) AS 특수유아수,
    COALESCE(특수교사수, 0) AS 특수교사수,
    COALESCE(특수학급수, 0) AS 특수학급수,
    CASE WHEN 특수유아수 > 0 THEN 1 ELSE 0 END AS 특수아동보유여부,
    CASE WHEN 특수학급수 > 0 THEN 1 ELSE 0 END AS 특수학급보유여부,
    CASE WHEN 특수교사수 > 0 THEN 1 ELSE 0 END AS 특수교사보유여부,
    COALESCE(만3세유아수, 0) + COALESCE(만4세유아수, 0) + COALESCE(만5세유아수, 0) + COALESCE(혼합유아수, 0) + COALESCE(특수유아수, 0) 유아수,
    ROUND(COALESCE(특수유아수, 0) / NULLIF(COALESCE(만3세유아수, 0) + COALESCE(만4세유아수, 0) + COALESCE(만5세유아수, 0) + COALESCE(혼합유아수, 0) + COALESCE(특수유아수, 0), 0), 7) 특수유아비율,
    ROUND(COALESCE(특수유아수, 0) / NULLIF(COALESCE(특수교사수, 0), 0), 7) AS 특수교사당특수아동수,
    CASE WHEN 특수유아수 > 0 AND 특수학급수 = 0 THEN 1 ELSE 0 END AS 특수유아있지만학급없음,
    CASE WHEN 특수유아수 > 0 AND 특수교사수 = 0 THEN 1 ELSE 0 END AS 특수유아있지만교사없음,
    CASE WHEN 특수유아수 > 0 AND 특수교사수 = 0 THEN 특수유아수 ELSE NULL END AS 교사가없는특수아동
FROM 일반현황
JOIN 교직원 USING(유치원코드)
WHERE 일반현황.교육지원청명 LIKE '성동광진교육지원청'
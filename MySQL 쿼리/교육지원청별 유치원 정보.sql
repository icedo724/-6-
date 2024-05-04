WITH 특수교사정보 AS (
	SELECT 교육지원청명, SUM(COALESCE(특수교사수, 0)) AS 특수교사
    FROM 교직원
    GROUP BY 1)

SELECT
    교육지원청명,
    SUM(COALESCE(특수유아수, 0)) AS 특수유아수계,
    SUM(만3세유아수+만4세유아수+만5세유아수+혼합유아수+COALESCE(특수유아수, 0)) AS 유아수계,
    ROUND(SUM(COALESCE(특수유아수, 0)) / sum(만3세유아수+만4세유아수+만5세유아수+혼합유아수+COALESCE(특수유아수, 0)), 7) AS 특수유아비율,
    ROUND(AVG(COALESCE(특수학급수, 0)), 7) AS 특수학급수평균,
    SUM(COALESCE(특수학급수, 0)) AS 특수학급총합,
    특수교사,
    ROUND(SUM(COALESCE(특수유아수, 0)) / 특수교사, 7) AS 특수교사당유아,
    ROUND(SUM(COALESCE(특수학급수, 0)) / 특수교사, 7) AS 학급대비특수교사수,
    COUNT(CASE WHEN 특수학급수 IS NOT NULL THEN 1 END) AS 특수학급보유유치원수,
    COUNT(*) AS 교육청별유치원수
FROM 일반현황
JOIN 특수교사정보 USING(교육지원청명)
GROUP BY 1
ORDER BY 2 DESC, 3 DESC, 4 DESC, 5 DESC, 6 DESC, 7 DESC
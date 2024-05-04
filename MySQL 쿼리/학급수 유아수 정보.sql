SELECT 
    유치원명, 
    유치원코드, 
    COALESCE(만3세학급수, 0) + COALESCE(만4세학급수, 0) + COALESCE(만5세학급수, 0) + COALESCE(혼합학급수, 0) + COALESCE(특수학급수, 0) AS 총학급수,
    COALESCE(만3세유아수, 0) + COALESCE(만4세유아수, 0) + COALESCE(만5세유아수, 0) + COALESCE(혼합유아수, 0) + COALESCE(특수유아수, 0) AS 총유아수,
    ROUND((COALESCE(만3세유아수, 0) + COALESCE(만4세유아수, 0) + COALESCE(만5세유아수, 0) + COALESCE(혼합유아수, 0) + COALESCE(특수유아수, 0)) / (NULLIF(COALESCE(만3세학급수, 0) + COALESCE(만4세학급수, 0) + COALESCE(만5세학급수, 0) + COALESCE(혼합학급수, 0) + COALESCE(특수학급수, 0), 0)), 1) AS 학급당유아수
FROM 
    일반현황;
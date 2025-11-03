-- hymns 테이블 리팩토링: id 컬럼 제거, number를 PRIMARY KEY로 변경
-- 찬송가 번호(number)는 이미 UNIQUE하고 실제 참조 키로 사용되므로 이를 PK로 사용

-- Step 1: 기존 PRIMARY KEY 제거
ALTER TABLE hymns DROP CONSTRAINT IF EXISTS hymns_pkey;

-- Step 2: id 컬럼 제거
ALTER TABLE hymns DROP COLUMN IF EXISTS id;

-- Step 3: number를 PRIMARY KEY로 설정
ALTER TABLE hymns ADD PRIMARY KEY (number);

-- 참고: number 컬럼은 이미 UNIQUE NOT NULL이므로 PK로 사용 가능
-- 이제 hymns.number가 찬송가의 유일한 식별자가 됨 (1-645)
